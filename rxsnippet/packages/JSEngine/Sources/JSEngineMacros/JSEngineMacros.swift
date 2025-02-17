//
//  JSEngineClassMacros.swift
//  JSEngine
//
//  Created by Qiwei Li on 2/17/25.
//
import SwiftSyntax
import SwiftSyntaxMacros

public struct JSEngineMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let classDecl = declaration.as(ClassDeclSyntax.self) else {
            context.addDiagnostics(from: MacroError.invalidDeclaration, node: node)
            return []
        }

        var newMembers: [DeclSyntax] = []

        for member in classDecl.memberBlock.members {
            guard let funcDecl = member.decl.as(FunctionDeclSyntax.self),
                funcDecl.signature.effectSpecifiers?.asyncSpecifier != nil
            else {
                continue
            }

            let functionName = funcDecl.name.text

            // Extract parameters
            let parameters = funcDecl.signature.parameterClause.parameters
            let parameterList = parameters.map { param in
                "\(param.firstName.text): \(param.type)"
            }.joined(separator: ", ")

            let jsParameterList = parameters.map { param in
                "\(param.firstName.text): \(param.firstName.text)"
            }.joined(separator: ", ")

            // Add resolve helper
            let resolveHelper = try FunctionDeclSyntax(
                """
                private func resolve\(raw: functionName.capitalized)(with value: String) {
                    context.globalObject.setObject(value, forKeyedSubscript: "\(raw: functionName)Result" as NSString)
                    context.evaluateScript("resolve\(raw: functionName.capitalized)(\(raw: functionName)Result);")
                }
                """)

            // Add reject helper
            let rejectHelper = try FunctionDeclSyntax(
                """
                private func reject\(raw: functionName.capitalized)(with error: Error) {
                    context.globalObject.setObject(
                        error.localizedDescription, forKeyedSubscript: "errorMessage" as NSString)
                    context.evaluateScript("reject\(raw: functionName.capitalized)(new Error(errorMessage));")
                }
                """)

            // Add JSValue returning function
            let jsValueFunc = try FunctionDeclSyntax(
                """
                func \(raw: functionName)(\(raw: parameterList)) -> JSValue {
                    let promise = context.evaluateScript(
                        \"\"\"
                            new Promise((resolve, reject) => {
                                globalThis.resolve\(raw: functionName.capitalized) = resolve;
                                globalThis.reject\(raw: functionName.capitalized) = reject;
                            });
                        \"\"\")!

                    Task {
                        do {
                            let result: String = try await \(raw: functionName)(\(raw: jsParameterList))
                            resolve\(raw: functionName.capitalized)(with: result)
                        } catch {
                            reject\(raw: functionName.capitalized)(with: error)
                        }
                    }

                    return promise
                }
                """)

            newMembers.append(contentsOf: [
                DeclSyntax(resolveHelper),
                DeclSyntax(rejectHelper),
                DeclSyntax(jsValueFunc),
            ])
        }

        return newMembers
    }
}
