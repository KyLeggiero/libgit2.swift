//
// attrcache.swift
//
// Written by Ky on 2024-11-11.
// Copyright waived. No rights reserved.
//
// This file is part of libgit2.swift, distributed under the Fair License.
// For full terms, see the included LICENSE file.
//

import Foundation



public struct AttributeCache: AnyStructProtocol {
    public var cfg_attr_file: String /* cached value of core.attributesfile */
    public var cfg_excl_file: String /* cached value of core.excludesfile */
    public var files: StringMap      /* hash path to git_attr_cache_entry records */
    public var macros: StringMap     /* hash name to vector<git_attr_assignment> */
//    public var lock: Mutex
    public var pool: Pool
}



// MARK: - Migration

@available(*, unavailable, renamed: "AttributeCache")
public typealias git_attr_cache = AttributeCache
