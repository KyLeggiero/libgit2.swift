//
// sha.swift
//
// Written by Ky on 2024-12-09.
// Copyright waived. No rights reserved.
//
// This file is part of libgit2.swift, distributed under the Fair License.
// For full terms, see the included LICENSE file.
//

import Foundation
import CommonCrypto



// MARK: - SHA1

public let GIT_HASH_SHA1_SIZE = 20



public struct Sha1: AnyStructProtocol {
    internal var context: Context
    
    public init(context: Context = .init()) {
        self.context = context
    }
}



public extension Sha1 {
    struct Context: AnyStructProtocol {
        public var cContext: CC_SHA1_CTX
        
        public  init(cContext: CC_SHA1_CTX) {
            self.cContext = cContext
        }
    }
}



// MARK: - SHA256

public let GIT_HASH_SHA256_SIZE = 32



public struct Sha256: AnyStructProtocol {
    internal var context: Context
    
    public init(context: Context) {
        self.context = context
    }
}



public extension Sha256 {
    struct Context: AnyStructProtocol {
        public var cContext: CC_SHA256_CTX
        
        public init(cContext: CC_SHA256_CTX) {
            self.cContext = cContext
        }
    }
}



// MARK: - Migrating

@available(*, unavailable, renamed: "Sha1.Context")
public typealias git_hash_sha1_ctx = Sha1.Context

@available(*, unavailable, renamed: "Sha256.Context")
public typealias git_hash_sha256_ctx = Sha256.Context



@available(*, unavailable)
internal extension git_hash_sha1_ctx {
    @available(*, unavailable, renamed: "cContext")
    var c: CC_SHA1_CTX { get { cContext } set { } }
}



@available(*, unavailable)
internal extension git_hash_sha256_ctx {
    @available(*, unavailable, renamed: "cContext")
    var c: CC_SHA256_CTX { get { cContext } set { } }
}
