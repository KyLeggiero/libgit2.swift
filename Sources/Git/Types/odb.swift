//
// odb.swift
//
// Written by Ky on 2024-11-10.
// Copyright waived. No rights reserved.
//
// This file is part of libgit2.swift, distributed under the Free License.
// For full terms, see the included LICENSE file.
//

import Foundation



public struct ObjectDatabase: AnyStructProtocol {
    public var rc: RefCount
    public var lock: Mutex  /* protects backends */
    public var options: Options
    public var backends: ArbitraryArray
    public var own_cache: Cache
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



public extension ObjectDatabase.Options {
    @available(*, unavailable, renamed: "oidKind")
    var oid_type: git_oid_t { oidKind }
}
    
