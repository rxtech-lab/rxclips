//
//  Engine.swift
//  rxsnippet
//
//  Created by Qiwei Li on 2/16/25.
//

import AppKit
import Common
import JavaScriptCore
import JSEngine
import JSEngineMacro
import SwiftUI

@JSBridgeProtocol
@objc protocol TestApiProtocol: JSExport, APIProtocol {
    func setEditorColor(color: String) -> String
    func openFolder() async throws -> String
}

@JSBridge
@Observable class Engine: NSObject, TestApiProtocol {
    var editorColor: Color = .red
    var jsEngine: JSEngine<Engine>? = nil
    var context: JSContext!

    func initializeJSExport(context: JSContext) -> Void {
        self.context = context
    }

    func initialize() {
        jsEngine = JSEngine(apiHandler: self)
    }

    func setEditorColor(color: String) -> String {
        editorColor = Color(hex: color)
        return color
    }

    @MainActor
    func openFolder() async throws -> String {
        return await withCheckedContinuation { continuation in
            let panel = NSOpenPanel()
            panel.canChooseFiles = false
            panel.canChooseDirectories = true
            panel.allowsMultipleSelection = false
            panel.begin { response in
                if response == .OK {
                    continuation.resume(returning: panel.url!.path)
                } else {
                    continuation.resume(returning: "")
                }
            }
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
