//
// index.swift
//
// Written by Ky on 2024-11-11.
// Copyright waived. No rights reserved.
//
// This file is part of libgit2.swift, distributed under the Free License.
// For full terms, see the included LICENSE file.
//

import Foundation
import CommonCrypto

@preconcurrency import SafePointer



public struct git_index: AnyStructProtocol {
    public var rc: RefCount

    public var index_file_path: String
    public var stamp: Filestamp
    public var checksum: [CUnsignedChar]//[GIT_HASH_MAX_SIZE];

    public var entries: ArbitraryArray
    public var entries_map: SafePointer<IndexMap>

    public var deleted: ArbitraryArray /* deleted entries if readers > 0 */
    public var readers: Atomic32 /* number of active iterators */

    public var oid_type: Oid.Kind

    public var on_disk: CUnsignedInt = 1
    public var ignore_case: CUnsignedInt = 1
    public var distrust_filemode: CUnsignedInt = 1
    public var no_symlinks: CUnsignedInt = 1
    public var dirty: CUnsignedInt = 1    /* whether we have unsaved changes */

    public var tree: SafePointer<git_tree_cache>
    public var tree_pool: Pool

    public var names: ArbitraryArray
    public var reuc: ArbitraryArray

    public var entries_cmp_path: git_vector_cmp
    public var entries_search: git_vector_cmp
    public var entries_search_path: git_vector_cmp
    public var reuc_search: git_vector_cmp

    public var version: CUnsignedInt
}



/** A map with `git_index_entry`s as key. */
public typealias IndexMap = [git_index_entry : git_index_entry]



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
public struct git_index_entry: AnyStructProtocol, Hashable {
    public var ctime: git_index_time
    public var mtime: git_index_time

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



/** Time structure used in a git index entry */
public struct git_index_time: AnyStructProtocol, Hashable {
    public var seconds: __int32_t
    /* nsec should not be stored as time_t compatible */
    public var nanoseconds: __uint32_t
}



// MARK: - Migration

@available(*, unavailable, renamed: "IndexMap")
public typealias git_idxmap = IndexMap
