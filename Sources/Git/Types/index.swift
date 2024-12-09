//
// index.swift
//
// Written by Ky on 2024-11-11.
// Copyright waived. No rights reserved.
//
// This file is part of libgit2.swift, distributed under the Fair License.
// For full terms, see the included LICENSE file.
//

import Foundation
import CommonCrypto

@preconcurrency import SafePointer



public struct Index: AnyStructProtocol {
    public var refCount: RefCount

    public var indexFilePath: String
    public var stamp: Filestamp
    public var checksum: [CUnsignedChar]//[GIT_HASH_MAX_SIZE];

    public var entries: ArbitraryArray
    public var entriesMap: IndexMap

    public var deleted: ArbitraryArray /* deleted entries if readers > 0 */
    public var readers: Atomic32 /* number of active iterators */

    public var oidKind: Oid.Kind

    public var onDisk = true
    public var ignoreCase = true
    public var distrustFilemode = true
    public var noSymlinks = true
    public var hasUnsavedChanges = true

    public var tree: SafePointer<TreeCache>
    public var treePool: Pool

    public var names: ArbitraryArray
    public var reuc: ArbitraryArray // "resolve undo"? https://libgit2.org/libgit2/#v1.4.4/group/index/git_index_remove_bypath

    public var entries_cmp_path: VectorComparator
    public var entries_search: VectorComparator
    public var entries_search_path: VectorComparator
    public var reuc_search: VectorComparator

    public var version: CUnsignedInt
}



/** A map with `Index.Entry`s as key. */
public typealias IndexMap = [Index.Entry : Index.Entry]

/** A map with case-insensitive `Index.Entry`s as key */
public typealias IndexMap_CaseInsensitive = [Index.Entry : Index.Entry]



public extension Index {
    /**
     * In-memory representation of a file entry in the index.
     *
     * This is a public structure that represents a file entry in the index.
     * The meaning of the fields corresponds to core Git's documentation (in
     * "Documentation/technical/index-format.txt").
     *
     * The `flags` field consists of a number of bit fields which can be
     * accessed via the first set of `GIT_INDEX_ENTRY_...` bitmasks below.
     * These flags are all read from and persisted to disk.
     *
     * The `flags_extended` field also has a number of bit fields which can be
     * accessed via the later `GIT_INDEX_ENTRY_...` bitmasks below.  Some of
     * these flags are read from and written to disk, but some are set aside
     * for in-memory only reference.
     *
     * Note that the time and size fields are truncated to 32 bits. This
     * is enough to detect changes, which is enough for the index to
     * function as a cache, but it should not be taken as an authoritative
     * source for that data.
     */
    struct Entry: AnyStructProtocol, Hashable {
        public var ctime: Index.Time
        public var mtime: Index.Time
        
        public var dev: __uint32_t
        public var ino: __uint32_t
        public var mode: __uint32_t
        public var uid: __uint32_t
        public var gid: __uint32_t
        public var file_size: __uint32_t
        
        public var id: Oid
        
        public var flags: __uint16_t
        public var flags_extended: __uint16_t
        
        let path: String
    }
}



public extension Index {
    /** Time structure used in a git index entry */
    struct Time: AnyStructProtocol, Hashable {
        public var seconds: __int32_t
        /* nsec should not be stored as time_t compatible */
        public var nanoseconds: __uint32_t
    }
}



// MARK: - Migration

@available(*, unavailable, renamed: "Index")
public typealias git_index = Index

@available(*, unavailable, renamed: "IndexMap")
public typealias git_idxmap = IndexMap

@available(*, unavailable, renamed: "Index.Time")
public typealias git_index_time = Index.Time

@available(*, unavailable, renamed: "Index.Entry")
public typealias git_index_entry = Index.Entry



public extension Index {
    @available(*, unavailable, renamed: "refCount")
    var rc: git_refcount { fatalError("use refCount") }
    
    @available(*, unavailable, renamed: "indexFilePath")
    var index_file_path: String { fatalError("use indexFilePath") }
    
    @available(*, unavailable, renamed: "entriesMap")
    var entries_map: git_idxmap { fatalError("use entriesMap") }
    
    @available(*, unavailable, renamed: "oidKind")
    var oid_type: git_oid_t { fatalError("use oidKind") }
    
    
    @available(*, unavailable, renamed: "onDisk")
    var on_disk: CUnsignedInt { fatalError("onDisk") }
    
    @available(*, unavailable, renamed: "ignoreCase")
    var ignore_case: CUnsignedInt { fatalError("ignoreCase") }
    
    @available(*, unavailable, renamed: "distrustFilemode")
    var distrust_filemode: CUnsignedInt { fatalError("distrustFilemode") }
    
    @available(*, unavailable, renamed: "noSymlinks")
    var no_symlinks: CUnsignedInt { fatalError("noSymlinks") }
    
    @available(*, unavailable, renamed: "hasUnsavedChanges")
    var dirty: CUnsignedInt { fatalError("hasUnsavedChanges") }
    
    
    @available(*, unavailable, renamed: "treePool")
    var tree_pool: git_pool { fatalError("use treePool") }
}
