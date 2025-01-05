//
// enum OptionSet.swift
//
// Written by Ky on 2025-01-03.
// Copyright waived. No rights reserved.
//
// This file is part of libgit2.swift, distributed under the Fair License.
// For full terms, see the included LICENSE file.
//

import Foundation



/// Apply this to an `enum` to automatically make it an ``OptionSet``
public protocol AutoOptionSet: RawRepresentable, OptionSet, CaseIterable, AnyEnumProtocol
where RawValue: FixedWidthInteger, Element == Self
{
    static var __empty: Self { get }
}



public extension AutoOptionSet {
    
    init(rawValue: RawValue) {
        self = Self.allCases.first { $0.rawValue == rawValue }
            ?? .__empty
    }
    
    
    static func calculateRawValueAfterLastOption() -> RawValue {
        let shift = allCases.lazy.map(\.rawValue).max()?.trailingZeroBitCount ?? allCases.count
        return 1 << min(shift, RawValue.max.bitWidth - 1)
    }
}
