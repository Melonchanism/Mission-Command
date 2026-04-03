//
//  Prefs.swift
//  Mission Command
//
//  Created by josh on 3/30/26.
//

import Carbon
import Defaults

extension Defaults.Keys {
	static let closeKeyboardAction = Defaults.Key<KeyboardAction>(
		"closeAction",
		default: .init(description: "Close Window", shortcut: .init(key: "w", modifiers: .command))
	)
	static let minimizeKeyboardAction = Defaults.Key<KeyboardAction>(
		"minimizeAction",
		default: .init(description: "Minimize Window", shortcut: .init(key: "m", modifiers: .command))
	)
	static let quitKeyboardAction = Defaults.Key<KeyboardAction>(
		"quitAction",
		default: .init(description: "Quit App", shortcut: .init(key: "q", modifiers: .command))
	)
	static let xWindowEnabled = Defaults.Key<Bool>("xWindowEnabled", default: true)
	static let xWindowScale = Defaults.Key<XWindow.Scale>("xWindowScale", default: .medium)
	
	static let showMenuBarExtra = Defaults.Key<Bool>("showMenuBarExtra", default: true)
}
