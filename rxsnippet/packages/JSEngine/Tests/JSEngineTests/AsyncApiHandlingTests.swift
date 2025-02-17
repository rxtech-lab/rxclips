import Common
import JavaScriptCore
import Testing

@testable import JSEngine
import JSEngineMacro

@JSBridgeProtocol
@objc public protocol TestApiProtocol: JSExport, APIProtocol {
    func openFolder() async throws -> String
    func getName(name: String) -> String
}

@JSBridge
class TestApi: NSObject, TestApiProtocol {
    let context: JSContext

    required init(context: JSContext) {
        self.context = context
        super.init()
    }

    func openFolder() async throws -> String {
        return "/path/to/folder"
    }

    func getName(name: String) -> String {
        return name
    }

    func getDefaultName(_ parameter: String) -> String {
        return parameter
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

    @Test func simpleAsyncApiTest2() async throws {
        let code = """
        async function handle(api) {
         const name = await api.getName("Hi");
         return name
        }
        """

        let result: String = try await engine.execute(code: code)
        #expect(result == "Hi")
    }

    @Test func simpleAsyncApiTest3() async throws {
        let code = """
        async function handle(api) {
         const name = await api.getDefaultName("Hi");
         return name
        }
        """

        let result: String = try await engine.execute(code: code)
        #expect(result == "Hi")
    }
}
