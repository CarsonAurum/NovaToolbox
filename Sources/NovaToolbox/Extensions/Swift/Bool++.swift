//
//  Bool++.swift
//  NovaToolbox
//
//  Created by Carson Rau on 5/8/25.
//

extension Bool {
    
    /// Returns an integer representation of the boolean: 1 for `true` or 0 for `false`.
    ///
    /// Example:
    ///     let flag = true
    ///     let value = flag.int // returns 1
    ///
    /// - Returns: 1 if the boolean is `true`; otherwise, 0.
    @inlinable
    public var int: Int { self ? 1 : 0 }
    
    /// Returns a string representation of the boolean: "true" for `true` or "false" for `false`.
    ///
    /// Example:
    ///     let flag = false
    ///     let text = flag.string // returns "false"
    ///
    /// - Returns: "true" if the boolean is `true`; otherwise, "false".
    @inlinable
    public var string: String { self ? "true" : "false" }
}

extension Bool {
    /// Returns the result of the given expression if the boolean is `false`; otherwise, returns `nil`.
    ///
    ///     let fallback = false.or("default")    // returns "default"
    ///     let none = true.or("default")         // returns nil
    ///
    /// - Parameter value: The expression to evaluate when `self` is `false`.
    /// - Returns: The result of `value()` if `self` is `false`; otherwise, `nil`.
    @inlinable
    public func or<A>(_ value: @autoclosure () throws -> A) rethrows -> A? {
        !self ? try value() : nil
    }
    
    /// Returns the optional result of the given expression if the boolean is `false`; otherwise, returns `nil`.
    ///
    ///     func fetchOptional() -> Int? { nil }
    ///     let result = false.or(fetchOptional())    // returns nil (or Int? from fetchOptional())
    ///     let none = true.or(fetchOptional())       // returns nil
    ///
    /// - Parameter value: The optional expression to evaluate when `self` is `false`.
    /// - Returns: The optional result of `value()` if `self` is `false`; otherwise, `nil`.
    @inlinable
    public func or<A>(_ value: @autoclosure () throws -> A?) rethrows -> A? {
        !self ? try value() : nil
    }
    
    /// Returns the result of the given expression if the boolean is `true`; otherwise, returns `nil`.
    ///
    ///     let greeting = true.then("Hello")    // returns "Hello"
    ///     let none = false.then("Hello")       // returns nil
    ///
    /// - Parameter value: The expression to evaluate when `self` is `true`.
    /// - Returns: The result of `value()` if `self` is `true`; otherwise, `nil`.
    @inlinable
    public func then<A>(_ value: @autoclosure () throws -> A) rethrows -> A? {
        self ? try value() : nil
    }
    
    /// Returns the optional result of the given expression if the boolean is `true`; otherwise, returns `nil`.
    ///
    ///     func fetchOptionalGreeting() -> String? { "Hi" }
    ///     let greeting = true.then(fetchOptionalGreeting())    // returns "Hi"
    ///     let none = false.then(fetchOptionalGreeting())       // returns nil
    ///
    /// - Parameter value: The optional expression to evaluate when `self` is `true`.
    /// - Returns: The optional result of `value()` if `self` is `true`; otherwise, `nil`.
    @inlinable
    public func then<A>(_ value: @autoclosure () throws -> A?) rethrows -> A? {
        self ? try value() : nil
    }
}
