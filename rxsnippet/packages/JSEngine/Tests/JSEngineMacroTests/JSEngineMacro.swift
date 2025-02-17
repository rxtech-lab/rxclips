import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(JSEngineMacros)
    import JSEngineMacros

    private let testMacros: [String: Macro.Type] = [
        "JSEngineMacro": JSEngineMacro.self
    ]
#endif

final class JSEngineMacroTests: XCTestCase {
    func testMacroWithoutParameters() throws {
        assertMacroExpansion(
            """
            @JSEngineMacro
            class TestApi: NSObject, TestApiProtocol {
                func openFolder() async throws -> String {
                    return "/path/to/folder"
                }
            }
            """,
            expandedSource: """
            class TestApi: NSObject, TestApiProtocol {
                func openFolder() async throws -> String {
                    return "/path/to/folder"
                }

                private func resolveOpenfolder(with value: String) {
                    context.globalObject.setObject(value, forKeyedSubscript: "openFolderResult" as NSString)
                    context.evaluateScript("resolveOpenfolder(openFolderResult);")
                }

                private func rejectOpenfolder(with error: Error) {
                    context.globalObject.setObject(
                        error.localizedDescription, forKeyedSubscript: "errorMessage" as NSString)
                    context.evaluateScript("rejectOpenfolder(new Error(errorMessage));")
                }

                func openFolder() -> JSValue {
                    let promise = context.evaluateScript(
                        \"\"\"
                            new Promise((resolve, reject) => {
                                globalThis.resolveOpenfolder = resolve;
                                globalThis.rejectOpenfolder = reject;
                            });
                        \"\"\")!

                    Task {
                        do {
                            let result: String = try await openFolder()
                            resolveOpenfolder(with: result)
                        } catch {
                            rejectOpenfolder(with: error)
                        }
                    }

                    return promise
                }
            }
            """,
            macros: testMacros
        )
    }

    func testMacroWithParameters() throws {
        assertMacroExpansion(
            """
            @JSEngineMacro
            class TestApi: NSObject, TestApiProtocol {
                func openFolder(name: String) async throws -> String {
                    return "/path/to/folder"
                }
            }
            """,
            expandedSource: """
            class TestApi: NSObject, TestApiProtocol {
                func openFolder(name: String) async throws -> String {
                    return "/path/to/folder"
                }

                private func resolveOpenfolder(with value: String) {
                    context.globalObject.setObject(value, forKeyedSubscript: "openFolderResult" as NSString)
                    context.evaluateScript("resolveOpenfolder(openFolderResult);")
                }

                private func rejectOpenfolder(with error: Error) {
                    context.globalObject.setObject(
                        error.localizedDescription, forKeyedSubscript: "errorMessage" as NSString)
                    context.evaluateScript("rejectOpenfolder(new Error(errorMessage));")
                }

                func openFolder(name: String) -> JSValue {
                    let promise = context.evaluateScript(
                        \"\"\"
                            new Promise((resolve, reject) => {
                                globalThis.resolveOpenfolder = resolve;
                                globalThis.rejectOpenfolder = reject;
                            });
                        \"\"\")!

                    Task {
                        do {
                            let result: String = try await openFolder(name: name)
                            resolveOpenfolder(with: result)
                        } catch {
                            rejectOpenfolder(with: error)
                        }
                    }

                    return promise
                }
            }
            """,
            macros: testMacros
        )
    }

    func testMacroWithoutAsyncFunction() throws {
        assertMacroExpansion(
            """
            @JSEngineMacro
            class TestApi: NSObject, TestApiProtocol {
                func openFolder(name: String) -> String {
                    return "/path/to/folder"
                }
            }
            """,
            expandedSource: """
            class TestApi: NSObject, TestApiProtocol {
                func openFolder(name: String) -> String {
                    return "/path/to/folder"
                }
            }
            """,
            macros: testMacros
        )
    }
}
