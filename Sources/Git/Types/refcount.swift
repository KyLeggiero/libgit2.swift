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



public struct RefCount: AnyStructProtocol {
    public var refcount: Atomic32
    public weak var owner: (any Sendable & AnyObject)?
}



// MARK: - Migration

@available(*, unavailable, renamed: "RefCount")
public typealias git_refcount = RefCount
