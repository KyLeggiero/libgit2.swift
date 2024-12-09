//
// object.swift
//
// Written by Ky on 2024-11-09.
// Copyright waived. No rights reserved.
//
// This file is part of libgit2.swift, distributed under the Fair License.
// For full terms, see the included LICENSE file.
//

import Foundation



public struct Object: AnyStructProtocol {
    public var cached: CachedObject
    public var repo: Repository
}



public extension Object {
    enum Kind: Int, AnyEnumProtocol {
        
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

@available(*, unavailable, renamed: "Object")
public typealias git_object = Object

@available(*, unavailable, renamed: "Object.Kind")
public typealias git_object_t = Object.Kind

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
