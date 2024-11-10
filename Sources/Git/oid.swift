//
// oid.swift
//
// Written by Ky on 2024-11-10.
// Copyright waived. No rights reserved.
//
// This file is part of libgit2.swift, distributed under the Free License.
// For full terms, see the included LICENSE file.
//

import Foundation

/// Unique identity of any object (commit, tree, blob, tag).
@available(*, unavailable, renamed: "Oid")
typealias git_oid = Oid
public struct Oid: Sendable, RawRepresentable {

    #if GIT_EXPERIMENTAL_SHA256
    /// type of object id
    public var kind: Kind
    #endif

    /** raw binary formatted id */
    public var rawValue: RawValue
    
    
    public init(rawValue: RawValue) {
        #if GIT_EXPERIMENTAL_SHA256
        self.kind = .sha256
        #endif
        self.rawValue = rawValue
    }
    
    
    #if GIT_EXPERIMENTAL_SHA256
    public init(kind: Kind, rawValue: RawValue) {
        self.kind = .sha256
        self.rawValue = rawValue
    }
    #endif
}


@available(*, unavailable, renamed: "Oid.Kind")
typealias git_oid_t = Oid.Kind
public extension Oid {
    enum Kind: Int, Sendable {
        case sha1 = 1
        
        #if GIT_EXPERIMENTAL_SHA256
        case sha256 = 2
        #endif
    }
}



public extension Oid {
    // the C implementation of libgit2 has a fixed-length array (`id[GIT_OID_MAX_SIZE]`). The Swift version of that is
    // writing a (tuple, with, that, many, UInt8, elements), like UUID does.  I don't think it's needed.
    // If I'm wrong and it needed, we can replace this with that.
    // Just remember to make it different for SHA1 vs SHA256
    //
    // - Mil, 2024-11-10
    typealias RawValue = Data
}



// MARK: - Migration

extension Oid {
    @available(*, unavailable, renamed: "rawValue")
    var id: RawValue { rawValue }
    
    @available(*, unavailable, renamed: "kind")
    var type: Oid.Kind { kind }
}



@available(*, unavailable, renamed: "Oid.Kind.sha1")
public let GIT_OID_SHA1 = Oid.Kind.sha1

#if GIT_EXPERIMENTAL_SHA256
@available(*, unavailable, renamed: "Oid.Kind.sha256")
public let GIT_OID_SHA256 = Oid.Kind.sha256
#endif
