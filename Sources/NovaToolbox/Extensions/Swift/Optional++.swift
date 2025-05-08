//
//  Optional++.swift
//  NovaToolbox
//
//  Created by Carson Rau on 5/6/25.
//

extension Optional {
    
    @inlinable
    public var isSome: Bool { self != nil }
    
    @inlinable
    public var isNone: Bool { self == nil }
}
