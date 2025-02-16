//
//  ContentView.swift
//  rxsnippet
//
//  Created by Qiwei Li on 2/16/25.
//

import SwiftUI

struct ContentView: View {
    @State private var isShowingFilePicker = false
    @State private var fileContent: String?

    @Environment(Engine.self) var engine

    var body: some View {
        Form {
            Text("Editor Color: \(engine.editorColor.description)")
                .background(engine.editorColor)

            Button("Import File") {
                isShowingFilePicker.toggle()
            }

            if let fileContent = fileContent {
                Button("Run") {
                    Task {
                        let result: String = try! await engine.jsEngine!.execute(code: fileContent)
                        print(result)
                    }
                }
            }
        }
        .fileImporter(isPresented: $isShowingFilePicker, allowedContentTypes: [.javaScript], onCompletion: { result in
            switch result {
                case .success(let directory):
                    // gain access to the directory
                    let gotAccess = directory.startAccessingSecurityScopedResource()
                    if !gotAccess { return }
                    // access the directory URL
                    // (read templates in the directory, make a bookmark, etc.)
                    fileContent = try! String(contentsOf: directory, encoding: .utf8)
                    // release access
                    directory.stopAccessingSecurityScopedResource()
                case .failure(let error):
                    // handle error
                    print(error)
            }
        })
        .padding()
    }
}
