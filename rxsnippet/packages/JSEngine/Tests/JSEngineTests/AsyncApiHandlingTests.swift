import Common
import JavaScriptCore
import Testing

@testable import JSEngine
import JSEngineMacro

@objc class CustomType: NSObject {
    @objc var value: String

    init(value: String) {
        self.value = value
    }
}

@JSBridgeProtocol
@objc protocol TestApiProtocol: JSExport, APIProtocol {
    func openFolder() async throws -> String
    func getName(name: String) -> String
    func getDefaultName(_ parameter: String) -> String
    func getCustomType() -> CustomType
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

    func getCustomType() -> CustomType {
        return CustomType(value: "CustomType")
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

    @Test func customTypeTest() async throws {
        let code = """
        async function handle(api) {
         const name = await api.getCustomType();
         return name
        }
        """

        let result: CustomType = try await engine.execute(code: code)
        #expect(result.value == "CustomType")
    }
}
