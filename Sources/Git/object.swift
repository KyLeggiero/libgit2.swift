//
// object.swift
//
// Written by Ky on 2024-11-09.
// Copyright waived. No rights reserved.
//
// This file is part of libgit2.swift, distributed under the Free License.
// For full terms, see the included LICENSE file.
//

import Foundation



@available(*, unavailable, renamed: "Object")
typealias git_object = Object
public struct Object: Sendable {
    var cached: CachedObject
    var repo: Repository
}



@available(*, unavailable, renamed: "Object.Kind")
public typealias git_object_t = Object.Kind
public extension Object {
    enum Kind: Int, Sendable {
        
        /// Object can be any of the following
        case any =      -2
        
        /// Object is invalid.
        case invalid =  -1
        
        /// A commit object.
        case commit =    1
        
        /// A tree (directory listing) object.
        case tree =      2
        
        /// A file revision object.
        case blob =      3
        
        /// An annotated tag object.
        case tag =       4
        
        /// A delta, base is given by an offset.
        case ofsDelta = 6
        
        /// A delta, base is given by object id.
        case refDelta = 7
    }
}



// MARK: - Migration

@available(*, unavailable, renamed: "Object.Kind.any")
public var GIT_OBJECT_ANY:       git_object_t { .any }
@available(*, unavailable, renamed: "Object.Kind.invalid")
public var GIT_OBJECT_INVALID:   git_object_t { .invalid }
@available(*, unavailable, renamed: "Object.Kind.commit")
public var GIT_OBJECT_COMMIT:    git_object_t { .commit }
@available(*, unavailable, renamed: "Object.Kind.tree")
public var GIT_OBJECT_TREE:      git_object_t { .tree }
@available(*, unavailable, renamed: "Object.Kind.blob")
public var GIT_OBJECT_BLOB:      git_object_t { .blob }
@available(*, unavailable, renamed: "Object.Kind.tag")
public var GIT_OBJECT_TAG:       git_object_t { .tag }
@available(*, unavailable, renamed: "Object.Kind.ofsDelta")
public var GIT_OBJECT_OFS_DELTA: git_object_t { .ofsDelta }
@available(*, unavailable, renamed: "Object.Kind.refDelta")
public var GIT_OBJECT_REF_DELTA: git_object_t { .refDelta }
