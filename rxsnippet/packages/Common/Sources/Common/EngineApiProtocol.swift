import Foundation
import JavaScriptCore

@objc public protocol APIProtocol: JSExport {
    func setEditorColor(_ color: String)
    func openFolder() -> String
}
