//
//  String++.swift
//  NovaToolbox
//
//  Created by Carson Rau on 5/7/25.
//

extension String {
    
    /// Converts a `lowerCamelCaseString` to `snake_case`.
    ///
    /// This method transforms any uppercase characters into lowercase and inserts underscores before them. If the string is empty, it returns the original string.
    ///
    ///     let result = "someCamelCaseString".toSnakeCase()    // "some_camel_case_string"
    ///     let result = "".toSnakeCase()                       // ""
    ///
    /// - Returns: A new string in `snake_case` format.
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
    
    /// In-place conversion from `lowerCamelCaseString` to `snake_case`.
    /// 
    /// - SeeAlso: ``String/toSnakeCase()``
    public mutating func snakeCased() {
        self = toSnakeCase()
    }
}
