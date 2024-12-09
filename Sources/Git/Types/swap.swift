//
// swap.swift
//
// Written by Ky on 2024-11-09.
// Copyright waived. No rights reserved.
//
// This file is part of libgit2.swift, distributed under the Fair License.
// For full terms, see the included LICENSE file.
//

import Foundation



/// Swaps the two given values
///
/// ```swift
/// var a = "world"
/// var b = "Hello"
///
/// print(a, b) // world Hello
///
/// swap(&a, &b)
///
/// print(a, b) // Hello world
/// ```
///
/// - Parameters:
///   - a: The first value which will become the second
///   - b: The second value which will become the first
public func swap<T>(a: inout T, b: inout T) {
    (b, a) = (a, b)
}
