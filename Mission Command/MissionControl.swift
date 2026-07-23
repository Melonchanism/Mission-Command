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
	
	var dummyWindow: NSWindow?
	var dummyWindowDelegate: WindowDelegate?

	typealias CallbackFn = ((_ state: State, _ proxy: MissionControl) -> Void)
	var callback: CallbackFn

	var timer: Timer?
	var cancellables: Set<AnyCancellable>

	var ptr: UnsafeMutableRawPointer { Unmanaged.passUnretained(self).toOpaque() }

	init(callback: @escaping CallbackFn) {
		self.state = .none
		self.callback = callback
		self.cancellables = .init()
		NSWorkspace.shared.notificationCenter.publisher(
			for: NSWorkspace.activeSpaceDidChangeNotification
		)
		.sink { _ in
			print("Workspace Changed")
			self.updateWindows()
		}
		.store(in: &cancellables)
		
		DispatchQueue.main.async { [self] in
			dummyWindow = NSWindow()
			dummyWindowDelegate = WindowDelegate(mc: self)
			dummyWindow?.delegate = dummyWindowDelegate
			dummyWindow?.setFrame(.init(x: 0, y: 0, width: 40, height: 40), display: true)
			dummyWindow?.ignoresMouseEvents = true
			dummyWindow?.alphaValue = 0
			dummyWindow?.collectionBehavior = [
				.transient,
				.canJoinAllSpaces,
				.fullScreenAuxiliary,
				.canJoinAllApplications,
			]
			dummyWindow?.styleMask = [.borderless]
			dummyWindow?.orderFrontRegardless()
		}
	}

	func startTimer() {
		self.timer = Timer(timeInterval: 0.2, repeats: true) { _ in
			self.updateWindows()
		}
		RunLoop.current.add(timer!, forMode: .common)
	}

	func stopTimer() {
		self.timer?.invalidate()
		self.timer = nil
	}

	func updateWindows() {
		clearWindows()

		guard
			let windowInfoList =
				CGWindowListCopyWindowInfo([.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID)
				as? [CFTypeRef]
		else { return }

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

class WindowDelegate: NSObject, NSWindowDelegate {
	var mc: MissionControl
	init(mc: MissionControl) {
		self.mc = mc
		super.init()
	}
	
	func windowDidChangeOcclusionState(_ notification: Notification) {
		let window = notification.object as! NSWindow
		print("occlusion", window.occlusionState)
		if window.occlusionState.rawValue == 8192 {
			mc.state = .windows
			mc.callback(.windows, mc)
			mc.updateWindows()
			mc.startTimer()
		} else {
			mc.state = .none
			mc.callback(.none, mc)
			mc.clearWindows()
			mc.stopTimer()
		}
	}
}
