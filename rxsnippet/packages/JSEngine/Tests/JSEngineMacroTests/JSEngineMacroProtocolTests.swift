//
//  JSEngineMicroProtocolTests.swift
//  JSEngine
//
//  Created by Qiwei Li on 2/17/25.
//

import JSEngineMacros
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

private let testMacros: [String: Macro.Type] = [
    "JSEngineProtocol": JSEngineProtocolMacro.self
]

final class JSEngineMacroProtocolTests: XCTestCase {
    func testMacroWithoutParameters() throws {
        assertMacroExpansion(
            """
            @JSEngineProtocol
            @objc public protocol TestApiProtocol: JSExport, APIProtocol {
                func openFolder() async throws -> String
            }
            """,
            expandedSource: """
            @objc public protocol TestApiProtocol: JSExport, APIProtocol {
                func openFolder() async throws -> String

                func openFolder() -> JSValue
            }
            """,
            macros: testMacros
        )
    }

    func testMacroWithParameters() throws {
        assertMacroExpansion(
            """
            @JSEngineProtocol
            @objc public protocol TestApiProtocol: JSExport, APIProtocol {
                func openFolder(name: String) async throws -> String
            }
            """,
            expandedSource: """
            @objc public protocol TestApiProtocol: JSExport, APIProtocol {
                func openFolder(name: String) async throws -> String

                func openFolder(name: String) -> JSValue
            }
            """,
            macros: testMacros
        )
    }

    func testMacroWithoutAsync() throws {
        assertMacroExpansion(
            """
            @JSEngineProtocol
            @objc public protocol TestApiProtocol: JSExport, APIProtocol {
                func openFolder() -> String
            }
            """,
            expandedSource: """
            @objc public protocol TestApiProtocol: JSExport, APIProtocol {
                func openFolder() -> String
            }
            """,
            macros: testMacros
        )
    }

    func testMacroWithoutAsyncAndWithAsync() throws {
        assertMacroExpansion(
            """
            @JSEngineProtocol
            @objc public protocol TestApiProtocol: JSExport, APIProtocol {
                func openFolder() -> String
                func openFolder2() async throws -> String
            }
            """,
            expandedSource: """
            @objc public protocol TestApiProtocol: JSExport, APIProtocol {
                func openFolder() -> String
                func openFolder2() async throws -> String

                func openFolder2() -> JSValue
            }
            """,
            macros: testMacros
        )
    }

    func testMacroOnClass() throws {
        assertMacroExpansion(
            """
            @JSEngineProtocol
            class TestApiClass: NSObject {

            }
            """, expandedSource: """
            class TestApiClass: NSObject {

            }
            """,
            diagnostics: [
                .init(message: "JSEngineProtocolMacro must be applied to a protocol", line: 1, column: 1)
            ],
            macros: testMacros
        )
    }
}
