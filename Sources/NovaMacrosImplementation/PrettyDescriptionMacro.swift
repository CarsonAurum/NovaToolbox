//
//  PrettyDescriptionMacro.swift
//  NovaToolbox
//
//  Created by Carson Rau on 5/8/25.
//

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct PrettyDescriptionMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // Ensure the macro is used on a struct
        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            context.diagnose(Diagnostic(node: node, message: PrettyDescriptionDiagnostic.notStruct))
            return []
        }

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
                return "        if let value = \(prop.name) { parts.append(\"\(prop.name): \\(value)\") }"
            } else {
                return "        parts.append(\"\(prop.name): \\(\(prop.name))\")"
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

enum PrettyDescriptionDiagnostic: DiagnosticMessage {
    case notStruct

    var message: String {
        switch self {
        case .notStruct:
            return "‘@PrettyDescription’ can only be applied to struct declarations."
        }
    }

    var diagnosticID: MessageID {
        MessageID(domain: "PrettyDescriptionMacro", id: "notStruct")
    }

    var severity: DiagnosticSeverity { .error }
}
