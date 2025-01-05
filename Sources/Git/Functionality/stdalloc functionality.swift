//
// stdalloc functionality.swift
// Analogous to `util/hash/sha.h`, `util/hash/common_crypto.h` & `util/hash/common_crypto.c`
//
// Written by Ky on 2024-12-26.
// Copyright waived. No rights reserved.
//
// This file is part of libgit2.swift, distributed under the Fair License.
// For full terms, see the included LICENSE file.
//

import Foundation


@inline(__always)
public func stdalloc__realloc(_ ptr: UnsafeMutableRawPointer?, size: size_t, file: String = #file, line: CInt = #line) -> UnsafeMutableRawPointer
{
    realloc(ptr, size);
}
