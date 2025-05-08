//
//  PrettyDescriptionMacro.swift
//  NovaToolbox
//
//  Created by Carson Rau on 5/8/25.
//

@attached(member, names: named(description))
public macro PrettyDescription() = #externalMacro(module: "NovaMacrosImplementation", type: "PrettyDescriptionMacro")
