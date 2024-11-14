//
// tree-cache.swift
//
// Written by Ky on 2024-11-13.
// Copyright waived. No rights reserved.
//
// This file is part of libgit2.swift, distributed under the Free License.
// For full terms, see the included LICENSE file.
//

import Foundation



public struct git_tree_cache: AnyStructProtocol {
    var children: [git_tree_cache]
    public var children_count: size_t

    public var oid_type: Oid.Kind

    public var entry_count: ssize_t
    public var oid: Oid
    public var namelen: size_t
    public var name: String
}
