//
//  Macros.swift
//  NovaToolbox
//
//  Created by Carson Rau on 5/7/25.
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct CodingKeysPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        CodingKeysMacro.self
    ]
}
