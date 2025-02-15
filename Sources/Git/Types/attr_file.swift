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
import Either



public struct git_attr_file {
    var rc: RefCount
    var lock: Mutex
    var entry: git_attr_file_entry
    var source: git_attr_file_source
    var rules: git_vector<Either<git_attr_rule, git_attr_fnmatch>>
    var pool: Pool
    var nonexistent: CUnsignedInt = 1
    var session_key: CInt
    var cache_data: Either<Oid, Filestamp>
}



public struct git_attr_path {
    var full: String
    var path: String
    var basename: String
    var is_dir: Bool
}



/**
 * A git_attr_session can provide an "instance" of reading, to prevent cache
 * invalidation during a single operation instance (like checkout).
 */
public struct git_attr_session {
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
