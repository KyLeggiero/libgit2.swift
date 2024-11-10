//
// swap.swift
//
// Written by Ky on 2024-11-09.
// Copyright waived. No rights reserved.
//
// This file is part of libgit2.swift, distributed under the Free License.
// For full terms, see the included LICENSE file.
//

import Foundation



internal func swap<T>(a: inout T, b: inout T) {
    (b, a) = (a, b)
}
