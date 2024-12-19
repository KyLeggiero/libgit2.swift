//
// sha functionality.swift
// Analogous to `util/hash/sha.h`, `util/hash/common_crypto.h` & `util/hash/common_crypto.c`
//
// Written by Ky on 2024-12-09.
// Copyright waived. No rights reserved.
//
// This file is part of libgit2.swift, distributed under the Fair License.
// For full terms, see the included LICENSE file.
//

import Foundation
import CommonCrypto



// MARK: - Protocolization

// MARK: API

/// Abstracts CommonCrypto operations into a simple API
public protocol ShaContext: AnyTypeProtocol {
    
    static var algorithm: HashAlgorithm { get }
    
    init()
    
    mutating func update(with hashData: Data)
    
    @available(*, deprecated, renamed: "resolved()", message: "You shouldn't need to provide an initial string")
    mutating func resolved(__advanced__initialData out: Data) -> Data?
    mutating func resolved() -> Data?
}



// MARK: Guts

/// Fill this out and it'll synthesize conformance to ``ShaContext`` for you!
public protocol __CommonCryptoShaContext_GitAutoSugar: ShaContext {
    
    associatedtype CContext
    
    
    var cContext: CContext { get set }
    
    init(cContext: CContext)
    
    @inline(__always)
    static func cContextInit() -> CContext
    
    @inline(__always)
    static func cc_init(context: inout CContext)
    
    @inline(__always)
    static func cc_update(context: inout CContext, updateData: UnsafeMutablePointer<UInt8>, chunkStart: CC_LONG)
    
    @inline(__always)
    static func cc_final(outData: UnsafeMutablePointer<UInt8>, context: inout CContext)
}



// MARK: Implementation

public extension ShaContext where Self: __CommonCryptoShaContext_GitAutoSugar {
    
    // Analogous to `git_hash_sha1_ctx_init`
    // Analogous to `git_hash_sha256_ctx_init`
    init() {
        var cContext = Self.cContextInit()
        Self.cc_init(context: &cContext)
        self.init(cContext: cContext)
    }
    
    
    // Analogous to `git_hash_sha1_update`
    // Analogous to `git_hash_sha256_update`
    mutating func update(with data: Data) {
        var data = data
        
        while !data.isEmpty {
            let chunkStart = CC_LONG(min(data.count, .init(CC_LONG.max)))
            
            var updateData = data
            Self.cc_update(context: &self.cContext, updateData: &updateData.bytes, chunkStart: chunkStart)
            
            data = Data(updateData[.init(chunkStart)...])
        }
        
        
        // The above code translates this original C code:
        //
        // const unsigned char *data = _data;
        //
        // GIT_ASSERT_ARG(ctx);
        //
        // while (len > 0) {
        //     CC_LONG chunk = (len > CC_LONG_MAX) ? CC_LONG_MAX : (CC_LONG)len;
        //
        //     CC_SHA1_Update(&ctx->c, data, chunk);
        //
        //     data += chunk;
        //     len -= chunk;
        // }
        //
        // return 0;
    }
    
    
    // Analogous to `git_hash_sha1_final`
    // Analogous to `git_hash_sha256_final`
    @available(*, deprecated, renamed: "resolved()", message: "You shouldn't need to provide an initial string")
    mutating func resolved(__advanced__initialData out: Data) -> Data? {
        resolved_sharedImplementation(startingData: out)
    }
    
    
    mutating func resolved() -> Data? {
        resolved_sharedImplementation(startingData: Data())
    }
    
    
    private mutating func resolved_sharedImplementation(startingData: Data) -> Data? {
        var hashData = startingData
        Self.cc_final(outData: &hashData.bytes, context: &self.cContext)
        
//        guard !stringData.isEmpty else {
//            throw .init(message: "CC_SHA1_Final did not set hash string data", kind: .sha)
//        }
        
        return hashData
    }
}



// MARK: - SHA1

extension Sha1.Context: ShaContext {
    public static var algorithm: HashAlgorithm { .sha1 }
}



extension Sha1.Context: __CommonCryptoShaContext_GitAutoSugar {
    public static func cContextInit() -> CContext { .init() }
    public static func cc_init(context: inout CContext) { CC_SHA1_Init(&context) }
    public static func cc_update(context: inout CContext, updateData: UnsafeMutablePointer<UInt8>, chunkStart: CC_LONG) { CC_SHA1_Update(&context, updateData, chunkStart) }
    public static func cc_final(outData: UnsafeMutablePointer<UInt8>, context: inout CContext) { CC_SHA1_Final(outData, &context) }
}



// MARK: - SHA256

extension Sha256.Context: ShaContext {
    public static var algorithm: HashAlgorithm { .sha256 }
}



extension Sha256.Context: __CommonCryptoShaContext_GitAutoSugar {
    public static func cContextInit() -> CContext { .init() }
    public static func cc_init(context: inout CContext) { CC_SHA256_Init(&context) }
    public static func cc_update(context: inout CContext, updateData: UnsafeMutablePointer<UInt8>, chunkStart: CC_LONG) { CC_SHA256_Update(&context, updateData, chunkStart) }
    public static func cc_final(outData: UnsafeMutablePointer<UInt8>, context: inout CContext) { CC_SHA256_Final(outData, &context) }
}



// MARK: - Migration

@available(*, unavailable, renamed: "CC_LONG.max", message: "Use Swift's builtin `.max` syntax instead")
private var CC_LONG_MAX: CC_LONG { CC_LONG.max } // CC_LONG(bitPattern: -1) // ((CC_LONG)-1)


// MARK: SHA-1

@available(*, unavailable, message: "Unneeded in libgit2.swift")
public func git_hash_sha1_global_init() -> CInt { 0 }

@available(*, unavailable, message: "Unneeded in libgit2.swift")
public func git_hash_sha1_ctx_cleanup(_ ctx: inout git_hash_sha1_ctx?) { }


@available(*, unavailable, renamed: "Sha1.Context()", message: "Use Swift type initialization directly")
public func git_hash_sha1_ctx_init(_: inout git_hash_sha1_ctx?) -> CInt { fatalError() }

@available(*, unavailable, renamed: "Sha1.Context(cContext:)", message: "Use Swift type initialization directly")
public func git_hash_sha1_init(_: inout git_hash_sha1_ctx?) -> CInt { fatalError() }

@available(*, unavailable, renamed: "Sha1.Context.update(with:)")
public func git_hash_sha1_update(_: inout git_hash_sha1_ctx?, _: VoidStar, _: size_t) -> CInt { fatalError() }

@available(*, unavailable, renamed: "Sha1.Context.resolved")
public func git_hash_sha1_final(_: inout [CUnsignedChar], _: inout git_hash_sha1_ctx?) -> CInt { fatalError() }


// MARK: SHA-256

@available(*, unavailable, message: "Unneeded in libgit2.swift")
public func git_hash_sha256_global_init() -> CInt { 0 }

@available(*, unavailable, message: "Unneeded in libgit2.swift")
public func git_hash_sha256_ctx_cleanup(_ ctx: git_hash_sha256_ctx?) { }


@available(*, unavailable, renamed: "Sha256.Context()", message: "Use Swift type initialization directly")
public func git_hash_sha256_ctx_init(_: inout git_hash_sha256_ctx?) -> CInt { fatalError() }

@available(*, unavailable, renamed: "Sha256.Context(cContext:)", message: "Use Swift type initialization directly")
public func git_hash_sha256_init(_: inout git_hash_sha256_ctx?) -> CInt { fatalError() }

@available(*, unavailable, renamed: "Sha256.Context.update(with:)")
public func git_hash_sha256_update(_: inout git_hash_sha256_ctx?, _: VoidStar, _: size_t) -> CInt { fatalError() }

@available(*, unavailable, renamed: "Sha256.Context.resolved")
public func git_hash_sha256_final(_: inout [CUnsignedChar], _: inout git_hash_sha256_ctx?) -> CInt { fatalError() }
