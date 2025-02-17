//
//  JSEngineMicroProtocolTests.swift
//  JSEngine
//
//  Created by Qiwei Li on 2/17/25.
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(JSEngineMacros)
    import JSEngineMacros

    let testMacros: [String: Macro.Type] = [
        "JSBridgeProtocol": JSEngineProtocolMacro.self
    ]
#endif

final class JSEngineMacroProtocolTests: XCTestCase {
    func testMacroWithoutParameters() throws {
        #if canImport(JSEngineMacros)
            assertMacroExpansion(
                """
                @JSBridgeProtocol
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
        #else
            throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testMacroWithParameters() throws {
        #if canImport(JSEngineMacros)
            assertMacroExpansion(
                """
                @JSBridgeProtocol
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
        #else
            throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testMacroWithoutAsync() throws {
        #if canImport(JSEngineMacros)
            assertMacroExpansion(
                """
                @JSBridgeProtocol
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
        #else
            throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testMacroWithoutAsyncAndWithAsync() throws {
        #if canImport(JSEngineMacros)
            assertMacroExpansion(
                """
                @JSBridgeProtocol
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
        #else
            throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
