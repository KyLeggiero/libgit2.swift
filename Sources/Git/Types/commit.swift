//
// commit.swift
//
// Written by Ky on 2024-11-09.
// Copyright waived. No rights reserved.
//
// This file is part of libgit2.swift, distributed under the Fair License.
// For full terms, see the included LICENSE file.
//

import Foundation



public struct Commit {
    public var object: Object

    public var parent_ids: [Oid]
    public var tree_id: Oid

    public var author: git_signature
    public var committer: git_signature

    public var message_encoding: String
    public var raw_message: String
    public var raw_header: String

    public var summary: String
    public var body: String
}



public extension Commit {
    struct ParseOptions {
        var oidKind: Oid.Kind
        var flags: Commit.ParseFlags
    }
}



public extension Commit {
    enum ParseFlags: UInt, Sendable {
        /** Only parse parents and committer info */
        case quick = 1 // (1 << 0)
    }
}



// MARK: - Migrated


@available(*, deprecated, renamed: "Commit")
typealias git_commit = Commit

@available(*, deprecated, renamed: "Commit.ParseOptions")
public typealias git_commit__parse_options = Commit.ParseOptions

@available(*, deprecated, renamed: "Commit.ParseFlags")
public typealias git_commit__parse_flags = Commit.ParseFlags

@available(*, deprecated, renamed: "CommitParseFlags.quick")
public let GIT_COMMIT_PARSE_QUICK = Commit.ParseFlags.quick



public extension Commit.ParseOptions {
    @available(*, unavailable, renamed: "oidKind")
    var oid_type: git_oid_t { oidKind }
}
