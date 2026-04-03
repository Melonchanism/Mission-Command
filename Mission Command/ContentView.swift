//
//  ContentView.swift
//  Mission Command
//
//  Created by josh on 3/29/26.
//

import Defaults
import SwiftUI

struct ContentView: View {

	@Default(.xWindowEnabled) var xWindowEnabled
	@Default(.xWindowScale) var xWindowScale
	@Default(.showMenuBarExtra) var showMenuBarExtra

	var body: some View {
		Form {
			Section("Keyboard Shortcuts") {
				KeyboardShortcutView(action: KeybindManager.shared.closeKeyboardAction)
				KeyboardShortcutView(action: KeybindManager.shared.minimizeKeyboardAction)
				KeyboardShortcutView(action: KeybindManager.shared.quitKeyboardAction)
			}
			Section("X window") {
				Toggle("Enabled", isOn: $xWindowEnabled)
				Picker("Scale", selection: $xWindowScale) {
					ForEach(XWindow.Scale.allCases, id: \.rawValue) { Text($0.rawValue).tag($0) }
				}
			}
			Section("Other") {
				Toggle("Show Menu Bar Item", isOn: $showMenuBarExtra)
			}
		}
		.formStyle(.grouped)
	}
}

struct KeyboardShortcutView: View {
	var action: KeyboardAction
	@State var active = false
	@FocusState var focusState: KeyboardAction?

	var body: some View {
		HStack {
			Text(action.description)
			Button(action: { KeybindManager.shared.val = action }) {
				HStack {
					if action.shortcut.modifiers.contains(.command) { KeyView(key: "􀆔") }
					if action.shortcut.modifiers.contains(.option) { KeyView(key: "􀆕") }
					if action.shortcut.modifiers.contains(.control) { KeyView(key: "􀆍") }
					if action.shortcut.modifiers.contains(.shift) { KeyView(key: "􀆝") }
					if action.shortcut.modifiers.contains(.globe) { KeyView(key: "􀆪") }
					KeyView(key: action.shortcut.key)
				}
				.padding(8)
				.background { RoundedRectangle(cornerRadius: 4).stroke(.tertiary).background(.quinary) }
			}
			.focused($focusState, equals: action)
			.buttonStyle(.plain)
			.popover(isPresented: .constant($focusState.wrappedValue == action)) {
				Text("Press esc to cancel")
					.padding()
					.interactiveDismissDisabled()
			}
			.frame(maxWidth: .infinity, alignment: .trailing)
			.onChange(of: KeybindManager.shared.val) {
				focusState = KeybindManager.shared.val
			}
			.onChange(of: focusState) {
				if focusState != KeybindManager.shared.val {
					focusState = nil
				}
			}
		}
	}
}

struct KeyView: View {
	var key: String

	var body: some View {
		Text(key)
			.padding(4)
			.background { RoundedRectangle(cornerRadius: 4).fill(.quaternary).stroke(.tertiary) }
	}
}

#Preview {
	ContentView()
		.frame(width: 400)
		.fixedSize()
}
