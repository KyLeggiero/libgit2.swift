//
// global functionality.swift
//
// Written by Ky on 2024-12-09.
// Copyright waived. No rights reserved.
//
// This file is part of libgit2.swift, distributed under the Fair License.
// For full terms, see the included LICENSE file.
//

import Foundation



// MARK: - Migration

@available(*, unavailable, message: "Use Swift's builtin random")
public func git_rand_global_init() -> CInt { fatalError("use Swift's builtin random") }

@available(*, unavailable, message: "Use Swift's builtin random")
public func git_rand_seed(_: __uint64_t) { fatalError("use Swift's builtin random") }

@available(*, unavailable, renamed: "UInt.random(in:)", message: "Use Swift's builtin random")
public func git_rand_next() -> __uint64_t { fatalError("use Swift's builtin random") }
