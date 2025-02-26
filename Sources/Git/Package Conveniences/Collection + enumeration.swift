//
// Collection + enumeration.swift
//
// Written by Ky on 2025-02-17.
// Copyright waived. No rights reserved.
//
// This file is part of libgit2.swift, distributed under the Fair License.
// For full terms, see the included LICENSE file.
//

import Foundation



internal extension Collection {
    func enumeratedWithIndices() -> Zip2Sequence<Indices, Self> {
        zip(indices, self)
    }
}
