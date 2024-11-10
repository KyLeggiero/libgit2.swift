//
// refcount.swift
//
// Written by Ky on 2024-11-10.
// Copyright waived. No rights reserved.
//
// This file is part of libgit2.swift, distributed under the Free License.
// For full terms, see the included LICENSE file.
//

import Foundation


@available(*, unavailable, renamed: "RefCount")
typealias git_refcount = RefCount
struct RefCount: Sendable {
    var refcount: Atomic32
    var owner: (any Sendable)?
}
