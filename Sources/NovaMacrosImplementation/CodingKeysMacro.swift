//
//  CodingKeysMacro.swift
//  NovaToolbox
//
//  Created by Carson Rau on 4/24/25.
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

// Diagnostic definitions for @CodingKeys macro
enum CodingKeysDiagnostic: DiagnosticMessage {
    case notStruct
    case notCodable
    case test(String)

    var message: String {
        switch self {
        case .notStruct:
            return "‘@CodingKeys’ can only be applied to struct declarations."
        case .notCodable:
            return "Structs annotated with ‘@CodingKeys’ must conform to ‘Codable’."
        case .test(let string):
            return string
        }
    }

    var diagnosticID: MessageID {
        switch self {
        case .notStruct:
            return MessageID(domain: "CodingKeysMacro", id: "notStruct")
        case .notCodable:
            return MessageID(domain: "CodingKeysMacro", id: "notCodable")
        case .test(let value):
            return MessageID(domain: "CodingKeysMacro", id: "test")
        }
    }

    var severity: DiagnosticSeverity { .error }
}

// Convert camelCase to snake_case
fileprivate extension String {
    func toSnakeCase() -> String {
        guard !isEmpty else { return self }
        var result = ""
        for character in self {
            if character.isUppercase {
                result.append("_")
                result.append(character.lowercased())
            } else {
                result.append(character)
            }
        }
        return result
    }
}

public struct CodingKeysMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // Ensure the macro is used on a struct
        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            context.diagnose(Diagnostic(node: node, message: CodingKeysDiagnostic.notStruct))
            return []
        }
        
        // Ensure the struct conforms to Codable
        let conformsToCodable = protocols
            .map { $0.trimmedDescription }
            .contains("Codable")
        if !conformsToCodable {
            context.diagnose(Diagnostic(node: node, message: CodingKeysDiagnostic.test(protocols.description)))
            return []
        }
        return []
    }
}
