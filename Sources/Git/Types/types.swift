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



public typealias FileSize = __int64_t;
public typealias IntSecondsSinceEpoch = __int64_t; /**< time in seconds from epoch */



/** Time in a signature */
public struct git_time: AnyStructProtocol {
    
    /// time in seconds from epoch
    public var time: IntSecondsSinceEpoch
    
    /// timezone offset, in minutes
    public var offset: CInt
    
    /// indicator for questionable '-0000' offsets in signature
    public var sign: CChar
}


/// An action signature (e.g. for committers, taggers, etc)
public struct git_signature: AnyStructProtocol {
    
    /// full name of the author
    public var name: String
    
    /// email of the author
    public var email: String
    
    /// time when the action happened
    public var when: git_time
}



// MARK: - Consistency

/// All types in this repo should conform to this by default
public typealias AnyTypeProtocol = Sendable

/// All `struct`s in this repo should conform to this by default
public typealias AnyStructProtocol = AnyTypeProtocol

/// All `enum`s in this repo should conform to this by default
public typealias AnyEnumProtocol = AnyTypeProtocol

/// All reference types should conform to this by default. Equivalent to `void *` in libgit2
public typealias AnyRefProtocol = any Sendable & AnyObject



// MARK: - Fuck C

public typealias CUnsigned = CUnsignedInt



// MARK: - Migration

@available(*, unavailable, renamed: "IntSecondsSinceEpoch")
public typealias git_time_t = IntSecondsSinceEpoch

@available(*, unavailable, renamed: "FileSize")
public typealias git_off_t = FileSize

@available(*, unavailable, renamed: "AnyRefProtocol", message: "`void *` could mean 'a pointer to any type' or 'a raw pointer'. You might consider `Data?`, `AnyObject?`, `UnsafeMutableRawPointer?` or Swift generics")
public typealias VoidStar = AnyRefProtocol


@available(*, unavailable, renamed: "Data", message: "`unsigned char *` means 'contiguous bytes in memory', which is exactly what `Data` means")
public typealias UnsignedCharStar = Data
