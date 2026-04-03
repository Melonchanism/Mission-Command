//
//  KeyboardShortcut.swift
//  Mission Command
//
//  Created by josh on 3/30/26.
//

import SwiftUI
import Defaults
import DefaultsMacros

// Maybe switch to classes because pointer shenanegans

class KeyboardAction: Equatable, Codable, Hashable, Defaults.Serializable {
	var description: String
	var shortcut: KeyboardShortcut
	
	init(description: String, shortcut: KeyboardShortcut) {
		self.description = description
		self.shortcut = shortcut
	}
	
	static func == (rhs: KeyboardAction, lhs: KeyboardAction) -> Bool {
		return rhs.description == lhs.description
	}
	
	func hash(into hasher: inout Hasher) {
			hasher.combine(description)
			hasher.combine(shortcut)
	}
}

struct KeyboardShortcut: Equatable, Hashable, Codable, Defaults.Serializable {
	var key: String
	var modifiers: Modifiers
	
	init(key: String, modifiers: Modifiers) {
		self.key = key
		self.modifiers = modifiers
	}
	

	struct Modifiers: Equatable, Hashable, OptionSet, Codable {
		var rawValue: UInt64
		
		static var command = Self(rawValue: CGEventFlags.maskCommand.rawValue)
		static var option = Self(rawValue: CGEventFlags.maskAlternate.rawValue)
		static var control = Self(rawValue: CGEventFlags.maskControl.rawValue)
		static var shift = Self(rawValue: CGEventFlags.maskShift.rawValue)
		static var globe = Self(rawValue: CGEventFlags.maskSecondaryFn.rawValue)
	}
}

@Observable class KeybindManager {

	static var shared = KeybindManager()

	@ObservableDefault(.closeKeyboardAction) @ObservationIgnored var closeKeyboardAction: KeyboardAction
	@ObservableDefault(.minimizeKeyboardAction) @ObservationIgnored var minimizeKeyboardAction: KeyboardAction
	@ObservableDefault(.quitKeyboardAction) @ObservationIgnored var quitKeyboardAction: KeyboardAction

	var eventTap: EventTap?

	var val: KeyboardAction? {
		didSet {
			if val != nil {
				eventTap?.enable()
			} else {
				eventTap?.disable()
			}
		}
	}

	init() {
		eventTap = EventTap(events: [.keyDown]) { proxy, type, event in
			DispatchQueue.main.async {
				if let nsEvent = NSEvent(cgEvent: event) {
					if nsEvent.characters != "\u{1B}" {
						self.val?.shortcut.modifiers = .init(rawValue: event.flags.rawValue)
						self.val?.shortcut.key = nsEvent.charactersIgnoringModifiers?.lowercased() ?? "a"
					}
					self.val = nil
				}
			}
			return nil
		}
	}
}
