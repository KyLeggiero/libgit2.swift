//
// refdb.swift
//
// Written by Ky on 2024-11-11.
// Copyright waived. No rights reserved.
//
// This file is part of libgit2.swift, distributed under the Fair License.
// For full terms, see the included LICENSE file.
//

import Foundation

@preconcurrency import SafePointer



public struct ReferenceDatabase: AnyStructProtocol {
    public var refCount: RefCount
    public weak var repo: SafePointer<Repository>?
    public var backend: ReferenceDatabase.Backend
}



// MARK: - Migration

@available(*, unavailable, renamed: "ReferenceDatabase")
public typealias git_refdb = ReferenceDatabase

public extension ReferenceDatabase {
    @available(*, unavailable, renamed: "refCount")
    var rc: git_refcount { refCount }
}
