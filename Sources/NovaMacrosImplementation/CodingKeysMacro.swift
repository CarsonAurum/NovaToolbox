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
        
        // Generate CodingKeys enum
        let generator = CodingKeysGenerator(option: option, properties: properties)
        let decl = generator
            .generate()
            .formatted()
            .as(EnumDeclSyntax.self)!
        return [
            DeclSyntax(decl)
        ]
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
        case .noArgument:
            return "'@CodingKeys' requires at least one argument."
        case .invalidArgument:
            return "Invalid argument provided to '@CodingKeys' macro."
        case .nonexistentProperty(let structName, let propertyName):
            return "Struct '\(structName)' has no property named '\(propertyName)'."
        }
    }

    var diagnosticID: MessageID {
        switch self {
        case .notStruct:
            return MessageID(domain: "CodingKeysMacro", id: "notStruct")
        case .notCodable:
            return MessageID(domain: "CodingKeysMacro", id: "notCodable")
        case .noArgument:
            return MessageID(domain: "CodingKeysMacro", id: "noArgument")
        case .invalidArgument:
            return MessageID(domain: "CodingKeysMacro", id: "invalidArgument")
        case .nonexistentProperty:
            return MessageID(domain: "CodingKeysMacro", id: "nonexistentProperty")
        }
    }

    var severity: DiagnosticSeverity { .error }
}

// MARK: - CodingKeysOption

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

// MARK: - CodingKeysGenerator

fileprivate struct CodingKeysGenerator {
    let option: CodingKeysOption
    let properties: [String]
    
    func generate() -> EnumDeclSyntax {
        EnumDeclSyntax(
            name: .identifier("CodingKeys"),
            inheritanceClause: InheritanceClauseSyntax {
                InheritedTypeSyntax(type: TypeSyntax(stringLiteral: "String"))
                InheritedTypeSyntax(type: TypeSyntax(stringLiteral: "CodingKey"))
            }) {
                MemberBlockItemListSyntax(
                    generateStrategy().map { strat in
                        MemberBlockItemSyntax(decl: EnumCaseDeclSyntax(elements: EnumCaseElementListSyntax(arrayLiteral: strat.enumCaseElementSyntax())))}
                )
        }
    }
    
    func generateStrategy() -> [CodingKeysStrategy] {
        properties.map {
            switch option {
            case .all:
                return .equal($0, $0.toSnakeCase())
            case .select(let selectedProperties):
                if selectedProperties.contains($0) {
                    return .equal($0, $0.toSnakeCase())
                } else {
                    return .skip($0)
                }
            case .exclude(let excludedProperties):
                if excludedProperties.contains($0) {
                    return .skip($0)
                } else {
                    return .equal($0, $0.toSnakeCase())
                }
            case .custom(let customNames):
                if customNames.map(\.key).contains($0),
                   let value = customNames[$0] {
                    return .equal($0, value)
                } else {
                    return .equal($0, $0.toSnakeCase())
                }
            }
        }
        .map { (strategy: CodingKeysStrategy) in
            switch strategy {
            case .equal(let key, let value):
                if key == value { return .skip(key) }
            default:
                break
            }
            return strategy
        }
    }
}

extension CodingKeysGenerator {
    enum CodingKeysStrategy {
        case equal(String, String)
        case skip(String)
        
        func enumCaseElementSyntax() -> EnumCaseElementSyntax {
            switch self {
            case .equal(let caseName, let value):
                EnumCaseElementSyntax(
                    name: .identifier(caseName),
                    rawValue: InitializerClauseSyntax(
                        equal: .equalToken(),
                        value: StringLiteralExprSyntax(content: value)))
            case .skip(let caseName):
                EnumCaseElementSyntax(name: .identifier(caseName))
            }
        }
    }
}
