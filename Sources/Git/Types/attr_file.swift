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
