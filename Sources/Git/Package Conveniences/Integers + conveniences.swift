//
// Integers + conveniences.swift
//
// Written by Ky on 2025-02-26.
// Copyright waived. No rights reserved.
//
// This file is part of libgit2.swift, distributed under the Fair License.
// For full terms, see the included LICENSE file.
//

import Foundation



internal extension AdditiveArithmetic {
    
    /// Returns this number, unless it's zero, in which case this returns `nil`
    var nonZeroOrNil: Self? {
        switch self {
        case .zero: return nil
        default:    return self
        }
    }
}
