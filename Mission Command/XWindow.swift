//
//  XWindow.swift
//  Mission Command
//
//  Created by josh on 3/31/26.
//

import SwiftUI
import Defaults

// Stub

class XWindow: NSPanel {
	init() {
		super.init(contentRect: .init(), styleMask: .borderless, backing: .buffered, defer: true)
	}
	
	enum Scale: String, CaseIterable, Defaults.Serializable {
		case small = "Small"
		case medium = "Medium"
		case large = "Large"
	}
}

struct XWindowView: View {
	var body: some View {
		Image(systemName: "xmark")
	}
	
}
