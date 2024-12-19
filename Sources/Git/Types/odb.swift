//
// odb.swift
//
// Written by Ky on 2024-11-10.
// Copyright waived. No rights reserved.
//
// This file is part of libgit2.swift, distributed under the Fair License.
// For full terms, see the included LICENSE file.
//

import Foundation



public struct ObjectDatabase: AnyStructProtocol {
    public var refCount: RefCount
    public var options: Options
    public var backends: ArbitraryArray
    public var ownCache: Cache
    public var cgraph: CommitGraph
    public var do_fsync: CUnsignedInt = 1
}



public extension ObjectDatabase {
    struct Options: AnyStructProtocol {
        var version: CUnsignedInt
        var oidKind: Oid.Kind
    }
}



// MARK: - Migration

@available(*, unavailable, renamed: "ObjectDatabase")
public typealias git_odb = ObjectDatabase

@available(*, unavailable, renamed: "ObjectDatabase.Options")
public typealias git_odb_options = ObjectDatabase.Options



public extension ObjectDatabase {
    @available(*, unavailable, renamed: "refCount")
    var rc: git_refcount { fatalError() }
    
    @available(*, unavailable, renamed: "ownCache")
    var own_cache: Cache { fatalError() }
    
    
    
    @available(*, unavailable, message: "Use structured concurrency instead. If you need atomic access to a value, mark it `@Volatile`.")
    var lock: Mutex { fatalError() }
}



public extension ObjectDatabase.Options {
    @available(*, unavailable, renamed: "oidKind")
    var oid_type: git_oid_t { oidKind }
}
