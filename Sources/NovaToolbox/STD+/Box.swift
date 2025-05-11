//
//  Box.swift
//  NovaToolbox
//
//  Created by Carson Rau on 5/7/25.
//

public final class Box<T> {
    public let value: T
    public init(_ value: T) {
        self.value = value
    }
}

extension Box: Equatable where T: Equatable {
    public static func == (lhs: Box<T>, rhs: Box<T>) -> Bool {
        lhs.value == rhs.value
    }
}

extension Box: Codable where T: Codable {
    public convenience init(from decoder: Decoder) throws {
        try self.init(.init(from: decoder))
    }
    public func encode(to encoder: Encoder) throws {
        try value.encode(to: encoder)
    }
}

extension Box: Hashable where T: Hashable {
    public func hash(into hasher: inout Hasher) {
        value.hash(into: &hasher)
    }
}

extension Box: Sendable where T: Sendable {
    
}

extension Box: CustomStringConvertible where T: CustomStringConvertible {
    public var description: String {
        "[BOX: \(value.description)]"
    }
}

extension Box: Sequence where T: Sequence {
    public func makeIterator() -> T.Iterator {
        value.makeIterator()
    }
}
