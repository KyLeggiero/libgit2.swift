//
// commit_graph.swift
//
// Written by Ky on 2024-11-10.
// Copyright waived. No rights reserved.
//
// This file is part of libgit2.swift, distributed under the Fair License.
// For full terms, see the included LICENSE file.
//

import Foundation



/// A wrapper for CommitGraph.File to enable lazt loading into the ODB
public struct CommitGraph: AnyStructProtocol {
    /// The path to the commit-graph file. Something like ".git/objects/info/commit-graph".
    public var filename: String

    /// The underlying commit-graph file.
    public var file: CommitGraph.File

    /// The object ID types in the commit graph.
    public var oidKind: Oid.Kind

    /// Whether the commit-graph file was already checked for validity.
    public var checked: Bool
}



// MARK: - CommitGraph.File

public extension CommitGraph {
    struct File: AnyStructProtocol {
        /// The generation number of the commit within the graph
        public var generation: size_t

        /// Time in seconds from UNIX epoch.
        public var commitTime: IntSecondsSinceEpoch

        /// The number of parents of the commit.
        public var parentCount: size_t

        /// The indices of the parent commits within the Commit Data table. The value
        /// of `GIT_COMMIT_GRAPH_MISSING_PARENT` indicates that no parent is in that
        /// position.
        var parentIndices: (size_t, size_t)

        /// The index within the Extra Edge List of any parent after the first two.
        public var extraParentsIndex: size_t

        /// The object ID of the root tree of the commit.
        public var treeOid: Oid

        /// The object ID hash of the requested commit.
        public var oid: Oid
    }
}




// MARK: - Migrated

@available(*, unavailable, renamed: "CommitGraph")
public typealias git_commit_graph = CommitGraph

@available(*, unavailable, renamed: "CommitGraph.File")
public typealias git_commit_graph_file = CommitGraph.File



public extension CommitGraph {
    @available(*, unavailable, renamed: "oidKind")
    var oid_type: git_oid_t { oidKind }
}



public extension CommitGraph.File {
    @available(*, unavailable, renamed: "commitTime")
    var commit_time: git_time_t { commitTime }
    
    @available(*, unavailable, renamed: "parentCount")
    var parent_count: size_t { parentCount }
    
    @available(*, unavailable, renamed: "parentIndices")
    var parent_indices: (size_t, size_t) { parentIndices }
    
    @available(*, unavailable, renamed: "extraParentsIndex")
    var extra_parents_index: size_t { extraParentsIndex }
    
    @available(*, unavailable, renamed: "treeOid")
    var tree_oid: Oid { treeOid }
    
    @available(*, unavailable, renamed: "oid")
    var sha1: Oid { oid }
}
