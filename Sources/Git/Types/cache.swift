//
// cache.swift
//
// Written by Ky on 2024-11-09.
// Copyright waived. No rights reserved.
//
// This file is part of libgit2.swift, distributed under the Fair License.
// For full terms, see the included LICENSE file.
//

import Foundation



public struct Cache: AnyStructProtocol {
    public var map: git_oidmap
    public var lock: ThreadReadWriteLock
    public var usedMemory: Result<size_t, Error>
}



public extension Cache {
    enum StoreKind: UInt, AnyEnumProtocol {
        case any = 0
        case raw = 1
        case parsed = 2
    }
}



public struct CachedObject: AnyStructProtocol {
    public var oid: Oid
    public var type: Object.Kind
    public var storeKind: Cache.StoreKind
    public var size: size_t
    
    @Volatile
    public var refcount: Int
}



// MARK: - Migration

@available(*, unavailable, renamed: "Cache")
typealias git_cache = Cache

@available(*, unavailable, renamed: "CachedObject")
typealias git_cached_obj = CachedObject



@available(*, unavailable, renamed: "Cache.StoreKind.any")
public let GIT_CACHE_STORE_ANY = Cache.StoreKind.any

@available(*, unavailable, renamed: "Cache.StoreKind.raw")
public let GIT_CACHE_STORE_RAW = Cache.StoreKind.raw

@available(*, unavailable, renamed: "Cache.StoreKind.parsed")
public let GIT_CACHE_STORE_PARSED = Cache.StoreKind.parsed



public extension Cache {
    @available(*, unavailable, renamed: "usedMemory")
    var used_memory: ssize_t {
        switch usedMemory {
        case .success(let used_memory): used_memory
        case .failure(_):               -1
        }
    }
}



public extension CachedObject {
    @available(*, unavailable, renamed: "storeKind")
    var flags: Cache.StoreKind { storeKind }
}
