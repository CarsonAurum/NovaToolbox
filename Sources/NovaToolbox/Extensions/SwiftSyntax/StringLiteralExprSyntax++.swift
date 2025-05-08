//
//  StringLiteralExprSyntax++.swift
//  NovaToolbox
//
//  Created by Carson Rau on 5/7/25.
//

#if canImport(SwiftSyntax)
import SwiftSyntax

extension StringLiteralExprSyntax {
    public var rawValue: String {
        segments
            .compactMap { $0.as(StringSegmentSyntax.self) }
            .map(\.content.text)
            .joined()
    }
}
#endif
