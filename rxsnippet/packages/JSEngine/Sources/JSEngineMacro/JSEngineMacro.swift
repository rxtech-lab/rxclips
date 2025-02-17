//
//  JSEngineMicro.swift
//  JSEngine
//
//  Created by Qiwei Li on 2/17/25.
//

@freestanding(expression)
public macro stringify<T>(_ value: T) -> (T, String) = #externalMacro(module: "JSEngineMicroMacros", type: "StringifyMacro")
