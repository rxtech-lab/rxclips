import Common
import JavaScriptCore

public struct JSEngine {
    private let apiHandler: APIProtocol
    public init(
        apiHandler: APIProtocol
    ) {
        self.apiHandler = apiHandler
    }

    private func setupContextWithGlobals() throws -> JSContext {
        guard let context = JSContext() else {
            throw JSEngineError.contextNotInitialized
        }
        let console = JSValue(newObjectIn: context)
        let consoleLog: @convention(block) (String) -> Void = { message in
            print("JS Log:", message)
        }
        console?.setObject(consoleLog, forKeyedSubscript: "log" as NSString)
        context.setObject(console, forKeyedSubscript: "console" as NSString)

        return context
    }

    /**
     * Converts a JavaScript value to a specified Swift type
     *
     * - Parameters:
     *   - jsValue: The JavaScript value to convert
     *
     * - Returns: The converted value of type T
     *
     * - Throws:
     *   - JSError.functionWithoutReturn if the value is nil or conversion fails
     *   - JSError.typeConversionFailed if the target type is not supported
     */
    private func mapJSValueToSwiftType<T>(_ jsValue: JSValue?) throws -> T {
        guard let jsValue = jsValue else {
            throw JSEngineError.functionWithoutReturn
        }

        switch T.self {
        case is String.Type:
            guard let stringValue = jsValue.toString() else {
                throw JSEngineError.typeConversionFailed
            }
            return stringValue as! T
        case is Int.Type:
            return jsValue.toInt32() as! T
        case is Double.Type:
            return jsValue.toDouble() as! T
        case is Bool.Type:
            return jsValue.toBool() as! T
        case is [String].Type:
            guard let array = jsValue.toArray() as? [String] else {
                throw JSEngineError.typeConversionFailed
            }
            return array as! T
        case is [Int].Type:
            guard let array = jsValue.toArray() as? [Int] else {
                throw JSEngineError.typeConversionFailed
            }
            return array as! T
        case is [Any].Type:
            guard let array = jsValue.toArray() else {
                throw JSEngineError.typeConversionFailed
            }
            return array as! T
        case is [String: Any].Type:
            guard let dict = jsValue.toDictionary() else {
                throw JSEngineError.typeConversionFailed
            }
            return dict as! T
        case let type as Decodable.Type:
            // Convert JSValue to JSON string
            guard let jsonObject = jsValue.toObject(),
                  let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject)
            else {
                throw JSEngineError.typeConversionFailed
            }

            // Decode JSON to Codable type
            do {
                let decoder = JSONDecoder()
                let decoded = try decoder.decode(type, from: jsonData)
                return decoded as! T
            } catch {
                print("Error decoding JSON:", error)
                throw JSEngineError.typeConversionFailed
            }
        default:
            throw JSEngineError.typeConversionFailed
        }
    }

    public func execute<T>(code: String, withArguments: [Any] = []) async throws -> T {
        let context = try setupContextWithGlobals()

        context.evaluateScript(code)
        // Get the handle function from the global scope
        guard let handleFunc = context.globalObject?.objectForKeyedSubscript("handle") else {
            throw JSEngineError.functionNotFound
        }

        let result = try await handleFunc.call(withArguments: [apiHandler])
        print("Result from async function:", result?.toString() ?? "No result")

        return try mapJSValueToSwiftType(result)
    }
}
