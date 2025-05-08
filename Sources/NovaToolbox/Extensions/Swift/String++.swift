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
    
    /// Converts a lower-camel-case string into a space-separated, title-cased string.
    ///
    ///     "thisIsATest".lowerCamelCaseToTitleCase()   // → "This Is A Test"
    ///     "anotherExampleHere".lowerCamelCaseToTitleCase()  // → "Another Example Here"
    ///
    /// - Returns: A `Title Cased` string.
    public func toTitleCase() -> String {
        // 1) Insert spaces before uppercase letters
        var withSpaces = ""
        for character in self {
            if character.isUppercase {
                withSpaces.append(" ")
            }
            withSpaces.append(character)
        }

        // 2) Walk through spaced string and title-case each word
        var result = ""
        var shouldCapitalizeNext = true
        
        for character in withSpaces {
            if character.isWhitespace {
                // Preserve spaces and mark that next letter starts a new word
                result.append(character)
                shouldCapitalizeNext = true
            } else {
                let s = String(character)
                if shouldCapitalizeNext {
                    // Uppercase first letter of each word
                    result.append(contentsOf: s.uppercased())
                } else {
                    // Lowercase all other letters
                    result.append(contentsOf: s.lowercased())
                }
                shouldCapitalizeNext = false
            }
        }
        
        return result
    }
}
