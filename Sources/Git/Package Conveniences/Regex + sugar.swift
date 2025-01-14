//
// Regex + sugar.swift
//
// Written by Ky on 2024-12-30.
// Copyright waived. No rights reserved.
//
// This file is part of libgit2.swift, distributed under the Fair License.
// For full terms, see the included LICENSE file.
//

import Foundation



internal func ~= <S: StringProtocol> (lhs: String, rhs: Regex<S>) throws(GitError) -> Bool {
    try rhs.hasMatch(in: lhs)
}



internal extension Regex {
    func hasMatch(in needle: String) throws(GitError) -> Bool {
        do {
            return try nil != firstMatch(in: needle)
        }
        catch {
            throw .init(error)
        }
    }
}
