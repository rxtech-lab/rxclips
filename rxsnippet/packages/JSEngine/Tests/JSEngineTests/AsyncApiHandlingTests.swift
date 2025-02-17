import Common
import JavaScriptCore
import Testing

@testable import JSEngine

@objc public protocol TestApiProtocol: JSExport, APIProtocol {
    func openFolder() -> JSValue
    func openFolder() async throws -> String
}

class TestApi: NSObject, TestApiProtocol {
    let context: JSContext

    required init(context: JSContext) {
        self.context = context
        super.init()
    }

    private func resolvePromise(with value: String) {
        context.globalObject.setObject(value, forKeyedSubscript: "folderPath" as NSString)
        context.evaluateScript("resolveOpenFolder(folderPath);")
    }

    private func rejectPromise(with error: Error) {
        context.globalObject.setObject(
            error.localizedDescription, forKeyedSubscript: "errorMessage" as NSString)
        context.evaluateScript("rejectOpenFolder(new Error(errorMessage));")
    }

    func openFolder() -> JSValue {
        let promise = context.evaluateScript(
            """
                new Promise((resolve, reject) => {
                    globalThis.resolveOpenFolder = resolve;
                    globalThis.rejectOpenFolder = reject;
                });
            """)!

        // Start async task
        Task {
            do {
                let result: String = try await openFolder()
                resolvePromise(with: result)
            } catch {
                rejectPromise(with: error)
            }
        }

        return promise
    }

    func openFolder() async throws -> String {
        return "/path/to/folder"
    }
}

@Suite("Async API Handling")
struct AsyncApiHandlingTests {
    let engine: JSEngine<TestApi>

    init() {
        engine = JSEngine<TestApi>(apiHandler: TestApi.self)
    }

    @Test func simpleAsyncApiTest() async throws {
        let code = """
        async function handle(api) {
         console.log("Opening folder...");
         const folder = await api.openFolder();
         return folder
        }
        """

        let result: String = try await engine.execute(code: code)
        #expect(result == "/path/to/folder")
    }
}
