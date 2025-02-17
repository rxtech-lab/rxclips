//
//  JSEngineMicros.swift
//  JSEngine
//
//  Created by Qiwei Li on 2/17/25.
//
import SwiftCompilerPlugin
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

public struct JSEngineProtocolMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let protocolDecl = declaration.as(ProtocolDeclSyntax.self) else {
            context.diagnose(
                Diagnostic(
                    node: node,
                    message: MacroExpansionErrorMessage(
                        "JSEngineProtocolMacro must be applied to a protocol"
                    )
                )
            )
            return []
        }

        var newMembers: [DeclSyntax] = []

        for member in protocolDecl.memberBlock.members {
            guard let funcDecl = member.decl.as(FunctionDeclSyntax.self),
                  funcDecl.signature.effectSpecifiers?.asyncSpecifier != nil
            else {
                continue
            }

            var signature = funcDecl.signature
            // change return type to JSValue
            signature.returnClause = ReturnClauseSyntax(
                type: TypeSyntax(
                    "JSValue"
                )
            )
            // delete async specifier and throw specifier
            signature.effectSpecifiers = nil

            // Create function declaration without leading trivia
            let newFunc = FunctionDeclSyntax(
                leadingTrivia: funcDecl.leadingTrivia,
                name: funcDecl.name,
                signature: signature,
                trailingTrivia: funcDecl.trailingTrivia
            )

            newMembers.append(DeclSyntax(newFunc))
        }

        return newMembers
    }
}
