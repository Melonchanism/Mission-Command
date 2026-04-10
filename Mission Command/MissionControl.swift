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

	var element: AXUIElement?
	var observer: AXObserver?

	var windows: [MCWindow] = []

	typealias CallbackFn = ((_ state: State, _ proxy: MissionControl) -> Void)
	var callback: CallbackFn

	var cancellables: Set<AnyCancellable>

	var dockPid: pid_t = 0

	init(callback: @escaping CallbackFn) {
		self.state = .none
		self.callback = callback
		self.cancellables = .init()
		updateDockPid()
		initAXObservers()
		NSWorkspace.shared.notificationCenter.publisher(for: NSWorkspace.activeSpaceDidChangeNotification)
			.sink { _ in
				print("Workspace Changed")
				self.updateWindows()
			}
			.store(in: &cancellables)
		NotificationCenter.default.publisher(
			for: .init("NSApplicationDockDidRestartNotification")
		).sink { notification in
			self.updateDockPid()
			self.initAXObservers()
		}
		.store(in: &cancellables)
	}
	
	func updateDockPid() {
		dockPid = NSRunningApplication.runningApplications(
			withBundleIdentifier: "com.apple.dock"
		).first?.processIdentifier ?? 0
	}
	
	func initAXObservers() {
		self.element = AXUIElementCreateApplication(dockPid)
		guard AXObserverCreate(dockPid, observerCallback, &observer) == .success else { return }
		for notification in [kAXExposeExit, kAXExposeShowDesktop, kAXExposeShowAllWindows, kAXExposeShowFrontWindows] {
			AXObserverAddNotification(observer!, element!, notification, Unmanaged.passUnretained(self).toOpaque())
		}
		CFRunLoopAddSource(CFRunLoopGetMain(), AXObserverGetRunLoopSource(observer!), .defaultMode)
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
