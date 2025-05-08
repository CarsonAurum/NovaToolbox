//
//  DictionaryExprSyntax++.swift
//  NovaToolbox
//
//  Created by Carson Rau on 5/7/25.
//

#if canImport(SwiftSyntax)
import SwiftSyntax

extension DictionaryExprSyntax {
    public var stringDictionary: [String: String]? {
        guard let elements = content.as(DictionaryElementListSyntax.self) else { return nil }
        return elements.reduce(into: [String: String]()) {
            guard let key = $1.key.as(StringLiteralExprSyntax.self),
                  let value = $1.value.as(StringLiteralExprSyntax.self) else {
                return
            }
            $0.updateValue(value.rawValue, forKey: key.rawValue)
        }
    }
}

#endif
