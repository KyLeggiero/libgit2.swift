//
// grafts.swift
//
// Written by Ky on 2024-11-13.
// Copyright waived. No rights reserved.
//
// This file is part of libgit2.swift, distributed under the Fair License.
// For full terms, see the included LICENSE file.
//

import Foundation



public struct Grafts: AnyStructProtocol {
    /// Map of `git_commit_graft`s
    public var commits: [git_oidmap]

    /// Type of object IDs
    public var oid_type: Oid.Kind

    /// File backing the graft. NULL if it's an in-memory graft
    public var path: String?
    
    /// SHA-256 hash of the path?
    ///
    /// Does it have to be SHA-256?
    public var pathHashString: String
}



// MARK: - Migration

@available(*, unavailable, renamed: "Grafts")
public typealias git_grafts = Grafts



public extension Grafts {
    @available(*, unavailable, renamed: "pathHashString")
    var path_checksum: String { pathHashString }
}
