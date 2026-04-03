//
//  MCWindow.swift
//  Mission Command
//
//  Created by josh on 3/31/26.
//

import ApplicationServices
import SwiftUI

let ownerBlackList = [""]

struct MCWindow {
	var frame: CGRect
	var wid: UInt32
	var pid: Int
	var layer: Int
	var ownerName: String

	var element: AXUIElement
	var axWindow: AXUIElement?

	var closable: Bool = false
	var minimizable: Bool = false

	init?(cfVal: CFTypeRef) {
		let dict = cfVal as! [String: Any]
		self.frame = .init(dictionaryRepresentation: dict["kCGWindowBounds"] as! CFDictionary)!
		self.pid = dict["kCGWindowOwnerPID"] as! Int
		self.wid = dict["kCGWindowNumber"] as! UInt32
		self.layer = dict["kCGWindowLayer"] as! Int
		self.ownerName = dict["kCGWindowOwnerName"] as! String

		let pos = self.frame.origin
		if pos.y == 0 || pos.x == 0 || self.frame.height < 2 || self.frame.width < 2 { return nil }

		self.element = AXUIElementCreateApplication(pid_t(self.pid))
		var result = [] as CFTypeRef?
		AXUIElementCopyAttributeValue(self.element, kAXWindowsAttribute as CFString, &result)
		if let windowList = result as? [AXUIElement], windowList.count > 0 {
			windowList.forEach { window in
				var wid: UInt32 = 0
				_AXUIElementGetWindow(window, &wid)
				if wid == self.wid {
					var closeButton: CFTypeRef?
					AXUIElementCopyAttributeValue(window, kAXCloseButtonAttribute as CFString, &closeButton)
					self.closable = closeButton != nil

					var minimizeIsSettable: DarwinBoolean = false
					AXUIElementIsAttributeSettable(window, kAXMinimizedAttribute as CFString, &minimizeIsSettable)
					self.minimizable = minimizeIsSettable.boolValue

					self.axWindow = window
				}
			}
		}
		if self.axWindow == nil { return nil }
	}

	func quit() {
		NSRunningApplication(processIdentifier: pid_t(self.pid))?.terminate()
	}

	func minimize() {
		AXUIElementSetAttributeValue(self.axWindow!, kAXMinimizedAttribute as CFString, kCFBooleanTrue)
	}

	func close() {
		DispatchQueue.main.async {
			var closeButton: CFTypeRef?
			AXUIElementCopyAttributeValue(self.axWindow!, kAXCloseButtonAttribute as CFString, &closeButton)
			guard closeButton != nil else { return }
			AXUIElementPerformAction(closeButton as! AXUIElement, kAXPressAction as CFString)
		}
	}
}
