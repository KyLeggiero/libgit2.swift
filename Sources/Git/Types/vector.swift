//
// vector.swift
//
// Written by Ky on 2024-11-11.
// Copyright waived. No rights reserved.
//
// This file is part of libgit2.swift, distributed under the Free License.
// For full terms, see the included LICENSE file.
//

import Foundation



@available(*, unavailable, renamed: "ArbitraryArray")
public typealias git_vector = ArbitraryArray



public typealias ArbitraryArray = Array<any Sendable>



public typealias git_vector_cmp = @Sendable (AnyRefProtocol, AnyRefProtocol) -> CInt
