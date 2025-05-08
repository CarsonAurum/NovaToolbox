//
//  Comparable++.swift
//  NovaToolbox
//
//  Created by Carson Rau on 5/8/25.
//

extension Comparable {
    
    /// Returns the value clamped to the specified range.
    ///
    /// This method ensures the value is not less than the lower bound or greater than the upper bound of the range.
    ///
    ///     let value = 10.clamp(to: 0...5)   // Returns 5.
    ///
    /// - Parameter range: The closed range to clamp the value within.
    /// - Returns: The value, constrained to the given range.
    public func clamp(to range: ClosedRange<Self>) -> Self {
        max(range.lowerBound, min(range.upperBound, self))
    }
    
    /// Clamps the value to the specified closed range in place.
    ///
    /// - SeeAlso: ``Comparable/clamp(to:)``
    ///
    /// - Parameter range: The closed range to clamp the value within.
    public mutating func clamped(to range: ClosedRange<Self>) {
        self = clamp(to: range)
    }
    
    /// Returns a boolean indicating whether the value lies within the specified closed range.
    ///
    ///     let inRange = 3.isBetween(1...5)    // Returns true
    ///
    /// - Parameter range: The closed range to test.
    /// - Returns: `true` if the value is within the range (inclusive); otherwise, `false`.
    public func isBetween(_ range: ClosedRange<Self>) -> Bool {
        range ~= self
    }
}
