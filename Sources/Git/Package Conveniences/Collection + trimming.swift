//
// Collection + trimming.swift
// Some conveniences for using ranges with collections
//
// Written by Ky on 2025-01-16.
// Copyright waived. No rights reserved.
//
// This file is part of libgit2.swift, distributed under the Fair License.
// For full terms, see the included LICENSE file.
//

import Foundation



internal extension BidirectionalCollection {
    func trimmingPrefixAndSuffix(while predicate: (Element) throws -> Bool) rethrows -> SubSequence {
        try trimmingPrefix(while: predicate)
            .trimmingSuffix(while: predicate)
    }
    
    
    func trimmingSuffix(while predicate: (Element) throws -> Bool) rethrows -> SubSequence {
        self[...(try _startOfSuffix(while: predicate))]
    }
}



private extension BidirectionalCollection {
    func _startOfSuffix<Thrown: Error>(while predicate: (Element) throws(Thrown) -> Bool) rethrows -> Index {
        try lastIndex(where: { try !predicate($0) }) ?? startIndex
    }
}
