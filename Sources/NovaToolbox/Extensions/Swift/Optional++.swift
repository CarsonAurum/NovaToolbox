//
//  Optional++.swift
//  NovaToolbox
//
//  Created by Carson Rau on 5/6/25.
//

extension Optional {
    
    /// A Boolean value indicating whether this Optional contains a non‑nil value.
    ///
    /// - Returns: `true` if the Optional has a value; otherwise, `false`.
    @inlinable
    public var isSome: Bool { self != nil }
    
    /// A Boolean value indicating whether this Optional is nil.
    /// 
    /// - Returns: `true` if the Optional is nil; otherwise, `false`.
    @inlinable
    public var isNone: Bool { self == nil }
}
