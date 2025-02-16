//
//  rxsnippetApp.swift
//  rxsnippet
//
//  Created by Qiwei Li on 2/16/25.
//

import SwiftUI

@main
struct rxsnippetApp: App {
    @State private var engine = Engine()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    engine.initialize()
                }
                .environment(engine)
        }
    }
}
