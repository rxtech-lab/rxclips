//
//  JSEngine.swift
//  JSEngine
//
//  Created by Qiwei Li on 2/17/25.
//
import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct JSEngineMicroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        JSEngineProtocolMacro.self,
        JSEngineMacro.self
    ]
}
