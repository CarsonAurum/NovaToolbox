//
//  ArrayExprSyntax++.swift
//  NovaToolbox
//
//  Created by Carson Rau on 5/7/25.
//

#if canImport(SwiftSyntax)
import SwiftSyntax

extension ArrayExprSyntax {
    public var stringArray: [String]? {
        elements.reduce(into: [String]()) {
            guard let str = $1.expression.as(StringLiteralExprSyntax.self) else { return }
            $0.append(str.rawValue)
        }
    }
}
#endif
