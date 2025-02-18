//
//  SimpleApiHandlingTests.swift
//  JSEngine
//
//  Created by Qiwei Li on 2/18/25.
//

import Common
import JavaScriptCore
import Testing

@testable import JSEngine
import JSEngineMacro

@JSBridgeProtocol
@objc private protocol TestApiProtocol: JSExport, APIProtocol {
    func ok() -> Void
}

@JSBridge
private class TestApi: NSObject, TestApiProtocol {
    func initializeJSExport(context: JSContext) -> Void {
        self.context = context
    }

    var context: JSContext!

    func ok() -> Void {}
}

@Suite("Simple Api Handling Tests")
private struct SimpleApiHandlingTests {
    let engine: JSEngine<TestApi>

    init() {
        engine = JSEngine<TestApi>(apiHandler: TestApi())
    }

    @Test func voidFunctionTest() async throws {
        let code = """
        async function handle(api) {
         api.ok()
         return "ok"
        }
        """

        let result: String = try await engine.execute(code: code, functionName: "handle")
        #expect(result == "ok")
    }
}
