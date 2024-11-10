//
// cache.swift
//
// Written by Ky on 2024-11-09.
// Copyright waived. No rights reserved.
//
// This file is part of libgit2.swift, distributed under the Free License.
// For full terms, see the included LICENSE file.
//

import Foundation



@available(*, unavailable, renamed: "Cache")
typealias git_cache = Cache
public struct Cache: Sendable {
    public var map: git_oidmap
    public var lock: git_rwlock
    public var used_memory: ssize_t
}



public extension Cache {
    enum StoreKind: UInt, Sendable {
        case any = 0
        case raw = 1
        case parsed = 2
    }
}


@available(*, unavailable, renamed: "Cache.StoreKind.any")
public let GIT_CACHE_STORE_ANY = Cache.StoreKind.any

@available(*, unavailable, renamed: "Cache.StoreKind.raw")
public let GIT_CACHE_STORE_RAW = Cache.StoreKind.raw

@available(*, unavailable, renamed: "Cache.StoreKind.parsed")
public let GIT_CACHE_STORE_PARSED = Cache.StoreKind.parsed




@available(*, unavailable, renamed: "CachedObject")
typealias git_cached_obj = CachedObject
public struct CachedObject: Sendable {
    var oid: Oid
    var type: Object.Kind
    var storeKind: Cache.StoreKind
    var size: size_t
    var refcount: Atomic32
    
    
    @available(*, unavailable, renamed: "storeKind")
    var flags: Cache.StoreKind {
        storeKind
    }
}
