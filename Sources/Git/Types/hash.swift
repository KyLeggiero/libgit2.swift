//
// hash.swift
//
// Written by Ky on 2024-12-09.
// Copyright waived. No rights reserved.
//
// This file is part of libgit2.swift, distributed under the Fair License.
// For full terms, see the included LICENSE file.
//

import Foundation

@preconcurrency import Either



public enum HashAlgorithm: AnyEnumProtocol {
    case sha1
    case sha256
}



public extension HashAlgorithm {
    
    // Analogous to `git_hash_size`
    @inline(__always)
    var hashSize: size_t {
        switch self {
        case .sha1:   GIT_HASH_SHA1_SIZE
        case .sha256: GIT_HASH_SHA256_SIZE
        }
    }
}



public let GIT_HASH_MAX_SIZE = GIT_HASH_SHA256_SIZE



public struct HashContext<Context: ShaContext>: AnyStructProtocol { // TODO: Test generics
    public var context: Context
    public var algorithm: HashAlgorithm { Context.algorithm }
    
    public init(context: Context) {
        self.context = context
    }
}



public extension HashContext where Context == Sha1.Context {
    static var sha1: Self { .init() }
}



public extension HashContext where Context == Sha256.Context {
    static var sha256: Self { .init() }
}



extension HashContext: ShaContext {
    
    public init() {
        self.init(context: .init())
    }
    
    
    public static var algorithm: HashAlgorithm {
        Context.algorithm
    }
    
    
    public mutating func update(with data: Data) {
        context.update(with: data)
    }
    
    
    @available(*, deprecated, renamed: "resolved()", message: "You shouldn't need to provide an initial string")
    public mutating func resolved(__advanced__initialData out: Data) -> Data? {
        context.resolved(__advanced__initialData: out)
    }
    
    
    public mutating func resolved() -> Data? {
        context.resolved()
    }
}



public extension Either<Sha1.Context?, Sha256.Context?> {
    
    @inlinable
    var sha1: Sha1.Context? {
        get { left ?? nil }
        set { self = .left(newValue) }
    }
    
    
    @inlinable
    var sha256: Sha256.Context? {
        get { right ?? nil }
        set { self = .right(newValue) }
    }
    
    
    internal static func `nil`(for algorithm: HashAlgorithm) -> Self {
        switch algorithm {
        case .sha1:   .left(.none)
        case .sha256: .right(.none)
        }
    }
    
    
    static var sha1: Self { .left(.init()) }
    static var sha256: Self { .right(.init()) }
}



// MARK: - Migrating

@available(*, unavailable, renamed: "Array", message: "Just use Swift's builtin [String]")
public typealias git_str_vec = [String]



@available(*, unavailable, renamed: "HashContext")
public typealias git_hash_ctx = HashContext<Never>

@available(*, unavailable, renamed: "HashAlgorithm")
public typealias git_hash_algorithm_t = HashAlgorithm



@available(*, unavailable, renamed: "nil")
var GIT_HASH_ALGORITHM_NONE: git_hash_algorithm_t { fatalError() }

@available(*, unavailable, renamed: "HashAlgorithm.sha1")
var GIT_HASH_ALGORITHM_SHA1: git_hash_algorithm_t { fatalError() }

@available(*, unavailable, renamed: "HashAlgorithm.sha256")
var GIT_HASH_ALGORITHM_SHA256: git_hash_algorithm_t { fatalError() }


public extension HashContext {
    @available(*, unavailable, renamed: "context")
    var ctx: Context { fatalError() }
}


@available(*, unavailable, message: "You must specify a context to use this API")
extension Never: ShaContext {
    public static var algorithm: HashAlgorithm { fatalError() }
    public init() { fatalError() }
    public mutating func update(with data: Data) { fatalError() }
    public mutating func resolved(__advanced__initialData out: Data) -> Data? { fatalError() }
    public mutating func resolved() -> Data? { fatalError() }
}
