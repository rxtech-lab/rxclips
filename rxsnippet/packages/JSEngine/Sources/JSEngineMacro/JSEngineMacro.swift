//
//  JSEngineMicro.swift
//  JSEngine
//
//  Created by Qiwei Li on 2/17/25.
//

@attached(member)
public macro JSBridgeProtocol() = #externalMacro(module: "JSEngineMacros", type: "JSEngineProtocolMacro")
