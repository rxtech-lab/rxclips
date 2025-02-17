//
//  JSEngineMicro.swift
//  JSEngine
//
//  Created by Qiwei Li on 2/17/25.
//

@attached(member)
public macro JSEngineProtocol() = #externalMacro(module: "JSEngineMacros", type: "JSEngineProtocolMacro")

@attached(member)
public macro JSEngine() = #externalMacro(module: "JSEngineMacros", type: "JSEngineMacro")
