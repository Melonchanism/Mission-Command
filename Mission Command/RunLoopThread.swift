//
//  RunLoopThread.swift
//  Mission Command
//
//  Created by josh on 4/3/26.
//

import AppKit

let runLoopThread = Thread {
	var mcm: MissionControl?
	var clickTap: EventTap?
	var keyTap: EventTap?
	var moveTap: EventTap?

	var hoveredWindow: MCWindow?

	clickTap = EventTap(events: [.otherMouseDown, .otherMouseUp]) {
		proxy,
		type,
		event in
		print("click")
		switch event.type {
		case .otherMouseDown:
			return nil
		case .otherMouseUp:
			mcm?.windows.first { $0.frame.contains(event.location) }?.close()
			return nil
		default:
			break
		}
		return Unmanaged.passUnretained(event)
	}

	keyTap = EventTap(events: [.keyDown, .keyUp]) { proxy, type, event in
		DispatchQueue.main.async {
			if let nsEvent = NSEvent(cgEvent: event), event.type == .keyUp {
				let char = nsEvent.charactersIgnoringModifiers?.lowercased()
				let modifiers = KeyboardShortcut.Modifiers(rawValue: event.flags.rawValue)
				let kbm = KeybindManager.shared
				let cs = kbm.closeKeyboardAction.shortcut
				let ms = kbm.minimizeKeyboardAction.shortcut
				let qs = kbm.quitKeyboardAction.shortcut
				if cs.key == char && !cs.modifiers.isDisjoint(with: modifiers) {
					hoveredWindow?.close()
				} else if ms.key == char && !ms.modifiers.isDisjoint(with: modifiers) {
					hoveredWindow?.minimize()
				} else if qs.key == char && !qs.modifiers.isDisjoint(with: modifiers) {
					hoveredWindow?.quit()
				}
			}
		}
		return Unmanaged.passUnretained(event)
	}

	mcm = MissionControl { state, oldState, mcm in
		if state == .application || state == .windows {
			clickTap?.enable()
			keyTap?.enable()
			moveTap?.enable()
		} else {
			clickTap?.disable()
			keyTap?.disable()
			moveTap?.disable()
			if state != oldState {
				let oldPos = CGSCurrentInputPointerPosition()
				CGEvent(
					mouseEventSource: nil,
					mouseType: .otherMouseUp,
					mouseCursorPosition: .zero,
					mouseButton: .center
				)?.post(tap: .cghidEventTap)
				CGWarpMouseCursorPosition(oldPos)
			}
		}
	}

	moveTap = EventTap(events: [.mouseMoved]) { proxy, type, event in
		guard let mcm = mcm else { return Unmanaged.passUnretained(event) }
		hoveredWindow = mcm.windows.first { $0.frame.contains(event.location) }
		return Unmanaged.passUnretained(event)
	}
	CFRunLoopRun()
}
