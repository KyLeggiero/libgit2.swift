//
// vector.swift
//
// Written by Ky on 2024-11-11.
// Copyright waived. No rights reserved.
//
// This file is part of libgit2.swift, distributed under the Fair License.
// For full terms, see the included LICENSE file.
//

import Foundation



public typealias ArbitraryArray = [any AnyTypeProtocol]

public typealias VectorComparator = @Sendable (AnyRefProtocol, AnyRefProtocol) -> CInt



// MARK: - Migration

@available(*, unavailable, renamed: "VectorComparator")
public typealias git_vector_cmp = VectorComparator

@available(*, unavailable, renamed: "ArbitraryArray")
public typealias git_vector = ArbitraryArray
