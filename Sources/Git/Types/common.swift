//
// common.swift
//
// Written by Ky on 2025-02-18.
// Copyright waived. No rights reserved.
//
// This file is part of libgit2.swift, distributed under the Fair License.
// For full terms, see the included LICENSE file.
//

import Foundation



/// A structure which has a version number defining layout/capabilities of the structure.
///
/// Useful when serializing data, to guarantee correct decoding/migration
public protocol Versioned: AnyTypeProtocol, Copyable {
    
    /// The universal value which instances of this structure can use to declare their version
    var version: Version { get }
    
    /// Initializes a stricture as blank except the version
    init(version: Version)
}



public extension Versioned {
    
    /// The universal type which structures can use to declare their version
    typealias Version = UInt
}



internal protocol InitializableByOneArgument {
    associatedtype OtherType
    associatedtype InitializerError: Error = Never
    init(_ otherType: OtherType) throws(InitializerError)
}
