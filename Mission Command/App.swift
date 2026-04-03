//
//  Mission_CommandApp.swift
//  Mission Command
//
//  Created by josh on 3/29/26.
//

import SwiftUI
import Defaults

@main
struct Mission_CommandApp: App {
	@NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
	
	@Environment(\.openSettings) var openSettings
	
	@Default(.showMenuBarExtra) var showMenuBarExtra

	var body: some Scene {
		Settings {
			ContentView()
				.frame(width: 400)
				.fixedSize()
		}
		MenuBarExtra("Mission Command", systemImage: "text.and.command.macwindow", isInserted: $showMenuBarExtra) {
				Button("Settings") { openSettings() }.keyboardShortcut(",", modifiers: .command)
				Button("Quit") { NSApp.terminate(nil) }.keyboardShortcut("q", modifiers: .command)
			}
	}
}

class AppDelegate: NSObject, NSApplicationDelegate {
	@Environment(\.openSettings) var openSettings

	func applicationDidFinishLaunching(_ notification: Notification) {
		if NSAppleEventManager.shared().currentAppleEvent?.paramDescriptor(forKeyword: keyAEPropData)?.enumCodeValue
			!= keyAELaunchedAsLogInItem
		{
			openSettings()
		}
		runLoopThread.start()
	}
}
