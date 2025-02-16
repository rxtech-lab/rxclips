//
//  Engine.swift
//  rxsnippet
//
//  Created by Qiwei Li on 2/16/25.
//

import AppKit
import Common
import JSEngine
import SwiftUI

@Observable class Engine: NSObject {
    var editorColor: Color = .red
    var jsEngine: JSEngine?

    func initialize() {
        jsEngine = JSEngine(apiHandler: self)
    }
}

extension Engine: APIProtocol {
    func openFolder() -> String {
        // Create a synchronization primitive
        let semaphore = DispatchSemaphore(value: 0)
        var resultPath = ""

        // Dispatch to main thread
        DispatchQueue.main.async {
            let dialog = NSOpenPanel()
            dialog.title = "Choose a .js file"

            let result = dialog.runModal()
            if result == .OK {
                resultPath = dialog.url?.path ?? ""
            }

            semaphore.signal()
        }

        // Wait for the main thread operation to complete
        semaphore.wait()
        return resultPath
    }

    func setEditorColor(_ color: String) {
        editorColor = Color(color)
    }
}
