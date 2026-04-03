//
//  EventTap.swift
//  Mission Command
//
//  Created by josh on 3/29/26.
//

import ApplicationServices
import Cocoa

class EventTap {
	var eventTap: CFMachPort!
	typealias CallbackFn = (_ proxy: CGEventTapProxy, _ type: CGEventType, _ event: CGEvent)
	-> Unmanaged<CGEvent>?
	var callback: CallbackFn
	var events: [CGEventType]

	init?(events: [CGEventType], callback: @escaping CallbackFn) {
		self.callback = callback
		self.events = events
		
		var eventMask: CGEventMask = 0
		for event in events {
			eventMask |= 1 << event.rawValue
		}

		self.eventTap = CGEvent.tapCreate(
			tap: .cghidEventTap,
			place: .headInsertEventTap,
			options: .defaultTap,
			eventsOfInterest: eventMask,
			callback: eventCallback,
			userInfo: Unmanaged.passRetained(self).toOpaque()
		)

		guard eventTap != nil else {
			print("Failed to create tap. AX may be disabled. Retrying in 5 seconds...")
			return nil
		}

		CFRunLoopAddSource(
			CFRunLoopGetCurrent(),
			CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0),
			.commonModes
		)
		disable()
	}

	func enable() {
		CGEvent.tapEnable(tap: eventTap, enable: true)
	}

	func disable() {
		CGEvent.tapEnable(tap: eventTap, enable: false)
	}
}

func eventCallback(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, refcon: UnsafeMutableRawPointer?)
	-> Unmanaged<CGEvent>?
{
	let eventTap = Unmanaged<EventTap>.fromOpaque(refcon!).takeUnretainedValue()
	if eventTap.events.contains(type) {
		return eventTap.callback(proxy, type, event)
	}
	return Unmanaged.passUnretained(event)
}
