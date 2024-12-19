//
// alloc functionality.swift
//
// Written by Ky on 2024-12-08.
// Copyright waived. No rights reserved.
//
// This file is part of libgit2.swift, distributed under the Fair License.
// For full terms, see the included LICENSE file.
//

import Foundation



@available(*, unavailable, message: "No need for allocators in Swift")
func git_allocator_global_init() -> CInt { fatalError() }
