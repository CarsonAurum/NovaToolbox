//
//  String++.swift
//  NovaToolbox
//
//  Created by Carson Rau on 5/7/25.
//

extension String {
    public func toSnakeCase() -> String {
        guard !isEmpty else { return self }
        var result = ""
        for char in self {
            if char.isUppercase {
                result.append("_")
                result.append(char.lowercased())
            } else {
                result.append(char)
            }
        }
        return result
    }
}
