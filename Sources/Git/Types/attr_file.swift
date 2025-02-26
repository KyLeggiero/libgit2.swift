//
// attr_file.swift
//
// Written by Ky on 2025-01-24.
// Copyright waived. No rights reserved.
//
// This file is part of libgit2.swift, distributed under the Fair License.
// For full terms, see the included LICENSE file.
//

import Foundation
@preconcurrency import Either



public enum git_attr_file_source_t: CInt, AnyEnumProtocol {
    case GIT_ATTR_FILE_SOURCE_MEMORY = 0
    case GIT_ATTR_FILE_SOURCE_FILE   = 1
    case GIT_ATTR_FILE_SOURCE_INDEX  = 2
    case GIT_ATTR_FILE_SOURCE_HEAD   = 3
    case GIT_ATTR_FILE_SOURCE_COMMIT = 4

    case GIT_ATTR_FILE_NUM_SOURCES
}



public struct git_attr_file_source: AnyStructProtocol {
    /** The source location for the attribute file. */
    public var type: git_attr_file_source_t

    /**
     * The filename of the attribute file to read (relative to the
     * given base path).
     */
    public let base: String
    public let filename: String

    /**
     * The commit ID when the given source type is a commit (or NULL
     * for the repository's HEAD commit.)
     */
    public var commit_id: Oid
}



/// FileName Matching
public struct git_attr_fnmatch: AnyStructProtocol {
    public var pattern: String
    public var length: size_t
    public var containing_dir: String
    public var containing_dir_length: size_t
    public var flags: CUnsignedInt
}



public struct git_attr_rule: AnyStructProtocol {
    public var match: git_attr_fnmatch
    public var assigns: SelfSortingArray<git_attr_assignment>
}



public struct git_attr_name {
    var unused: RefCount
    let name: String
    var name_hash: UInt32
}



public struct git_attr_assignment: AnyStructProtocol {
    /** for macros */
    var rc: RefCount
    var name: String
    var name_hash: __uint32_t
    
}



public struct git_attr_file_entry: AnyStructProtocol {
    public var file: [git_attr_file] // TODO: Swift 7: Make this a fixed-length array?
    /** points into fullpath */
    public let path: String
    public var fullpath: String // TODO: Swift 7: Make this a fixed-length string?
}



public struct git_attr_file: AnyStructProtocol {
    public var rc: RefCount
    public var lock: Mutex
    public var entry: git_attr_file_entry
    public var source: git_attr_file_source
    public var rules: SelfSortingArray<Either<git_attr_rule, git_attr_fnmatch>>
    public var pool: Pool
    public var nonexistent: CUnsignedInt = 1
    public var session_key: CInt
    public var cache_data: Either<Oid, Filestamp>
}



public struct git_attr_path: AnyStructProtocol {
    public var full: String?
    public var path: String?
    public var basename: String?
    public var is_dir: Bool
}



/**
 * A git_attr_session can provide an "instance" of reading, to prevent cache
 * invalidation during a single operation instance (like checkout).
 */
public struct git_attr_session: AnyStructProtocol {
    public var key: CInt
    public var init_setup: CUnsignedInt = 1
    public var init_sysdir: CUnsignedInt = 1
    public var sysdir: String
    public var tmp: String?
    
    
    public init(
        key: CInt,
        init_setup: CUnsignedInt = 1,
        init_sysdir: CUnsignedInt = 1,
        sysdir: String,
        tmp: String? = nil)
    {
        self.key = key
        self.init_setup = init_setup
        self.init_sysdir = init_sysdir
        self.sysdir = sysdir
        self.tmp = tmp
    }
}



public enum git_dir_flag: CInt, AnyEnumProtocol {
    case GIT_DIR_FLAG_TRUE = 1
    case GIT_DIR_FLAG_FALSE = 0
    case GIT_DIR_FLAG_UNKNOWN = -1
}
