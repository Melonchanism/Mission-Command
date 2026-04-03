//
//  MissionControl.swift
//  yabai-swift
//
//  Created by josh on 3/26/26.
//

import AppKit
import Combine

class MissionControl {
	var state: State

	var element: AXUIElement
	var observer: AXObserver?

	var windows: [MCWindow] = []

	typealias CallbackFn = ((_ state: State, _ proxy: MissionControl) -> Void)
	var callback: CallbackFn

	var cancellable: AnyCancellable?

	static var dockPid: pid_t {
		NSRunningApplication.runningApplications(
			withBundleIdentifier: "com.apple.dock"
		).first?.processIdentifier ?? 0
	}

	init(callback: @escaping CallbackFn) {
		self.state = .none
		self.callback = callback
		self.element = AXUIElementCreateApplication(MissionControl.dockPid)
		guard AXObserverCreate(MissionControl.dockPid, observerCallback, &observer) == .success else { return }
		for notification in [kAXExposeExit, kAXExposeShowDesktop, kAXExposeShowAllWindows, kAXExposeShowFrontWindows] {
			AXObserverAddNotification(observer!, element, notification, Unmanaged.passUnretained(self).toOpaque())
		}
		CFRunLoopAddSource(CFRunLoopGetMain(), AXObserverGetRunLoopSource(observer!), .defaultMode)

		cancellable = NSWorkspace.shared.notificationCenter.publisher(for: NSWorkspace.activeSpaceDidChangeNotification)
			.sink { _ in
				print("Workspace Changed")
				self.updateWindows()
			}
	}

	func updateWindows() {
		clearWindows()
		
		let windowInfoList = CGWindowListCopyWindowInfo([.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID)! as [CFTypeRef]
		for info in windowInfoList {
			guard let window = MCWindow(cfVal: info) else { continue }
			windows.append(window)
		}
	}

	func clearWindows() {
		windows = []
	}

	enum State: Int {
		case none
		case windows
		case application
		case front
		case desktop
	}
}

func observerCallback(
	observer: AXObserver,
	element: AXUIElement,
	notification: CFString,
	context: UnsafeMutableRawPointer?
) {
	let mcm = Unmanaged<MissionControl>.fromOpaque(context!).takeUnretainedValue()
	switch notification {
	case kAXExposeShowFrontWindows:
		mcm.updateWindows()
		mcm.state = .application
		break
	case kAXExposeShowAllWindows:
		mcm.updateWindows()
		mcm.state = .windows
		break
	case kAXExposeShowDesktop:
		mcm.clearWindows()
		mcm.state = .desktop
		break
	case kAXExposeExit:
		mcm.clearWindows()
		mcm.state = .none
		break
	default:
		break
	}
	mcm.callback(mcm.state, mcm)
	print(mcm.state)
}

var kAXExposeShowAllWindows = "AXExposeShowAllWindows" as CFString
var kAXExposeShowFrontWindows = "AXExposeShowFrontWindows" as CFString
var kAXExposeShowDesktop = "AXExposeShowDesktop" as CFString
var kAXExposeExit = "AXExposeExit" as CFString
