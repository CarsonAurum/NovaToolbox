//
//  PrettyDescriptionMacro.swift
//  NovaToolbox
//
//  Created by Carson Rau on 5/8/25.
//

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics
import SwiftSyntaxBuilder

public struct PrettyDescriptionMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        
        // Handle enum types
        if let enumDecl = declaration.as(EnumDeclSyntax.self) {
            // Ensure the enum conforms to CustomStringConvertible
            guard let inheritanceClause = enumDecl.inheritanceClause,
                  inheritanceClause.inheritedTypes
                      .map(\.type.trimmedDescription)
                      .contains("CustomStringConvertible")
            else {
                context.diagnose(Diagnostic(node: node, message: PrettyDescriptionDiagnostic.notCustomStringConvertible))
                return []
            }

            // Generate description via raw string literal with interpolation
            let caseLines = enumDecl.memberBlock.members.flatMap { member -> [String] in
                guard let enumCase = member.decl.as(EnumCaseDeclSyntax.self) else { return [] }
                return enumCase.elements.map { element in
                    let name = element.name.text
                    if element.parameterClause != nil {
                        let varName = name.prefix(1).lowercased() + name.dropFirst()
                        return "case let .\(name)(\(varName)): return \"\(name.toTitleCase()): [\\(\(varName))]\""
                    } else {
                        return "case .\(name): return \"\(name.toTitleCase())\""
                    }
                }
            }
            
            let lines = caseLines.map { "    \($0)" }.joined(separator: "\n")

            let source = #"""
            public var description: String {
                switch self {
            \#(lines)
                }
            }
            """#

            return [DeclSyntax(stringLiteral: source)]
        }

        // Handle struct types
        
        // Ensure the macro is used on a struct
        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            context.diagnose(Diagnostic(node: node, message: PrettyDescriptionDiagnostic.notStruct))
            return []
        }
        
        // Check for CustomStringConvertible conformance
        guard let inheritanceClause = structDecl.inheritanceClause else {
            context.diagnose(Diagnostic(node: node, message: PrettyDescriptionDiagnostic.notCustomStringConvertible))
            return []
        }
        let conformsToCustomStringConvertible = inheritanceClause.inheritedTypes
            .map(\.type.trimmedDescription)
            .contains("CustomStringConvertible")
        if !conformsToCustomStringConvertible {
            context.diagnose(Diagnostic(node: node, message: PrettyDescriptionDiagnostic.notCustomStringConvertible))
            return []
        }
        
        // Handle OptionSet conformance by listing contained options
        let conformsToOptionSet = inheritanceClause.inheritedTypes
            .map(\.type.trimmedDescription)
            .contains("OptionSet")
        
        if conformsToOptionSet {
            // Collect all static let options defined within the struct
            var optionNames: [String] = []
            for member in structDecl.memberBlock.members {
                if let varDecl = member.decl.as(VariableDeclSyntax.self),
                   varDecl.modifiers.contains(where: { $0.name.text == "static" }) == true,
                   let binding = varDecl.bindings.first,
                   let id = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier {
                    optionNames.append(id.text)
                }
            }

            // Build the body of the description property for OptionSet
            let optionLines = optionNames.map { name in
                "if self.contains(.\(name)) { parts.append(\"\(name.toTitleCase())\") }"
            }.joined(separator: "\n")

            let optionSource = """
            public var description: String {
                var parts: [String] = []
                \(optionLines)
                return "[\\(parts.joined(separator: \", \"))]"
            }
            """

            let optionDecl = DeclSyntax(stringLiteral: optionSource)
            return [optionDecl]
        } else {
            // Collect each property name and whether it's optional
            var properties: [(name: String, isOptional: Bool)] = []
            for member in structDecl.memberBlock.members {
                if let varDecl = member.decl.as(VariableDeclSyntax.self),
                   let binding = varDecl.bindings.first,
                   let id = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier {
                    let isOptional = binding.typeAnnotation?.type.description.hasSuffix("?") ?? false
                    properties.append((name: id.text, isOptional: isOptional))
                }
            }
            
            // Build the body of the description property
            let lines = properties.map { prop in
                if prop.isOptional {
                    return "if let value = \(prop.name) { parts.append(\"\(prop.name): \\(value)\") }"
                } else {
                    return "parts.append(\"\(prop.name): \\(\(prop.name))\")"
                }
            }.joined(separator: "\n")
            
            let source = """
            public var description: String {
                var parts: [String] = []
                \(lines)
                return "[\\(parts.joined(separator: " || "))]"
            }
            """
            
            // Parse into a DeclSyntax
            let decl = DeclSyntax(stringLiteral: source)
            return [decl]
        }
    }
}

enum PrettyDescriptionDiagnostic: DiagnosticMessage {
    case notStruct
    case notCustomStringConvertible

    var message: String {
        switch self {
        case .notStruct:
            return "‘@PrettyDescription’ can only be applied to struct/enum declarations."
        case .notCustomStringConvertible:
            return "Types annotated with '@PrettyDescription' must conform to 'CustomStringConvertible'"
        }
    }

    var diagnosticID: MessageID {
        switch self {
        case .notStruct:
            MessageID(domain: "PrettyDescriptionMacro", id: "notStruct")
        case .notCustomStringConvertible:
            MessageID(domain: "PrettyDescriptionMacro", id: "notCustomStringConvertible")
        }
    }

    var severity: DiagnosticSeverity { .error }
}
