//
//  CodingKeysMacro.swift
//  NovaToolbox
//
//  Created by Carson Rau on 4/24/25.
//

public enum CodingKeysOption {
    case all
    case select([String])
    case exclude([String])
    case custom([String: String])
}

@attached(member, names: named(CodingKeys))
public macro CodingKeys(_ type: CodingKeysOption = .all)
    = #externalMacro(module: "NovaMacrosImplementation", type: "CodingKeysMacro")
