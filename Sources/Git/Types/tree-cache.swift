//
// tree-cache.swift
//
// Written by Ky on 2024-11-13.
// Copyright waived. No rights reserved.
//
// This file is part of libgit2.swift, distributed under the Fair License.
// For full terms, see the included LICENSE file.
//

import Foundation



public struct TreeCache: AnyStructProtocol {
    var children: [TreeCache]

    public var oidKind: Oid.Kind

    public var entryCount: Result<size_t, Error>
    public var oid: Oid
    public var name: String
}



// MARK: - Migration

@available(*, unavailable, renamed: "TreeCache")
public typealias git_tree_cache = TreeCache



public extension TreeCache {
    @available(*, unavailable, renamed: "children.count", message: "Not necessary; Swift arrays contain their own count")
    var children_count: size_t { fatalError("use children.count") }
    
    @available(*, unavailable, renamed: "oidKind")
    var oid_type: git_oid_t { fatalError("use oidKind") }
    
    @available(*, unavailable, renamed: "entryCount")
    var entry_count: ssize_t { fatalError("use entryCount") }
    
    @available(*, unavailable, renamed: "name.count", message: "Not necessary; Swift strings contain their own count")
    var namelen: size_t { fatalError("use name.count") }
}
