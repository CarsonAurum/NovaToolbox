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
import NovaToolbox

fileprivate enum CodingKeysOption {
    case all
    case select([String])
    case exclude([String])
    case custom([String: String])
    
    var properties: [String] {
        switch self {
        case .all: []
        case .select(let arr), .exclude(let arr): arr
        case .custom(let dict): .init(dict.keys)
        }
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
        if let inheritanceClause = structDecl.inheritanceClause {
            let conformsToCodable = inheritanceClause.inheritedTypes
                .map { $0.trimmedDescription }
                .contains("Codable")
            if !conformsToCodable {
                context.diagnose(Diagnostic(node: node, message: CodingKeysDiagnostic.notCodable))
                return []
            }
        }
        
        // Parse the argument associated with the macro.
        var option: CodingKeysOption
        guard case .argumentList(let arguments) = node.arguments,
              let firstElement = arguments.first?.expression else {
            context.diagnose(Diagnostic(node: node, message: CodingKeysDiagnostic.noArgument))
            return []
        }
        
        if let memberAccess = firstElement.as(MemberAccessExprSyntax.self) {
            if memberAccess.declName.baseName.trimmedDescription == "all" {
                option = .all
            } else {
                context.diagnose(Diagnostic(node: node, message: CodingKeysDiagnostic.noArgument))
                return []
            }
        } else if let functionCall = firstElement.as(FunctionCallExprSyntax.self) {
            guard let caseName = functionCall.calledExpression.as(MemberAccessExprSyntax.self)?.declName.baseName.text,
                  let expression = functionCall.arguments.first?.expression else {
                context.diagnose(Diagnostic(node: node, message: CodingKeysDiagnostic.noArgument))
                return []
            }
            if let arrayExpr = expression.as(ArrayExprSyntax.self),
               let stringArray = arrayExpr.stringArray {
                switch caseName {
                case "select":
                    option = .select(stringArray)
                case "exclude":
                    option = .exclude(stringArray)
                default:
                    context.diagnose(Diagnostic(node: node, message: CodingKeysDiagnostic.invalidArgument))
                    return []
                }
            } else if let dictExpr = expression.as(DictionaryExprSyntax.self),
                      let stringDict = dictExpr.stringDictionary {
                if caseName == "custom" {
                    option = .custom(stringDict)
                } else {
                    context.diagnose(Diagnostic(node: node, message: CodingKeysDiagnostic.invalidArgument))
                    return []
                }
            } else {
                context.diagnose(Diagnostic(node: node, message: CodingKeysDiagnostic.invalidArgument))
                return []
            }
        } else {
            context.diagnose(Diagnostic(node: node, message: CodingKeysDiagnostic.invalidArgument))
            return []
        }
        
        // Get Properties of attached struct
        var properties = [String]()
        for decl in structDecl.memberBlock.members.map(\.decl) {
            if let varDecl = decl.as((VariableDeclSyntax).self) {
                properties.append(contentsOf: varDecl.bindings.compactMap {
                    $0.pattern.as(IdentifierPatternSyntax.self)?.identifier.text
                })
            }
        }
        
        // Check for invalid properties in the option
        let invalidProperties = option.properties.compactMap {
            if !properties.contains($0) {
                return $0
            } else {
                return nil
            }
        }
        if !invalidProperties.isEmpty {
            context.diagnose(Diagnostic(node: node, message: CodingKeysDiagnostic.nonexistentProperty(
                structName: structDecl.name.text,
                propertyName: invalidProperties.joined(separator: ", "))
            ))
            return []
        }
        
        return []
    }
    
    
}

// MARK: - DiagnosticMessage

enum CodingKeysDiagnostic: DiagnosticMessage {
    case notStruct
    case notCodable
    case noArgument
    case invalidArgument
    case nonexistentProperty(structName: String, propertyName: String)

    var message: String {
        switch self {
        case .notStruct:
            return "‘@CodingKeys’ can only be applied to struct declarations."
        case .notCodable:
            return "Structs annotated with ‘@CodingKeys’ must conform to ‘Codable’."
        default:
            fatalError()
        }
    }

    var diagnosticID: MessageID {
        switch self {
        case .notStruct:
            return MessageID(domain: "CodingKeysMacro", id: "notStruct")
        case .notCodable:
            return MessageID(domain: "CodingKeysMacro", id: "notCodable")
        default:
            fatalError()
        }
    }

    var severity: DiagnosticSeverity { .error }
}
