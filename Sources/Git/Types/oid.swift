//
// oid.swift
//
// Written by Ky on 2024-11-10.
// Copyright waived. No rights reserved.
//
// This file is part of libgit2.swift, distributed under the Fair License.
// For full terms, see the included LICENSE file.
//

import Foundation



/// Unique identity of any object (commit, tree, blob, tag).
public struct Oid: AnyStructProtocol, RawRepresentable, Hashable {

    /// type of object id
    public var kind: Kind

    /** raw binary formatted id */
    public var rawValue: RawValue
    
    
    public init(rawValue: RawValue) {
        self.kind = .sha256
        self.rawValue = rawValue
    }
    
    
    public init(kind: Kind, rawValue: RawValue) {
        self.kind = .sha256
        self.rawValue = rawValue
    }
}



public extension Oid {
    enum Kind: Int, AnyEnumProtocol {
        case sha1 = 1
        
        case sha256 = 2
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

@available(*, unavailable, renamed: "Oid")
public typealias git_oid = Oid

@available(*, unavailable, renamed: "Oid.Kind")
public typealias git_oid_t = Oid.Kind



public extension Oid {
    @available(*, unavailable, renamed: "rawValue")
    var id: RawValue { rawValue }
    
    @available(*, unavailable, renamed: "kind")
    var type: Oid.Kind { kind }
}



@available(*, unavailable, renamed: "Oid.Kind.sha1")
public let GIT_OID_SHA1 = Oid.Kind.sha1

@available(*, unavailable, renamed: "Oid.Kind.sha256")
public let GIT_OID_SHA256 = Oid.Kind.sha256

