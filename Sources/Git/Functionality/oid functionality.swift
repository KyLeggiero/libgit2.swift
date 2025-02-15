//
// oid functionality.swift
//
// Written by Ky on 2025-01-26.
// Copyright waived. No rights reserved.
//
// This file is part of libgit2.swift, distributed under the Fair License.
// For full terms, see the included LICENSE file.
//

import Foundation



/** Size (in bytes) of a raw/binary sha1 oid */
public let GIT_OID_SHA1_SIZE: size_t = 20

/** Size (in bytes) of a raw/binary sha256 oid */
public let GIT_OID_SHA256_SIZE: size_t = 32



public extension Oid {
    /**
     * Copy an oid from one structure to another.
     *
     * - Returns: oid structure the result is written into.
     * - Parameter self: oid structure to copy from.
     * - Throws: error code
     */
    func copy() throws(GitError) -> Oid {
        guard 0 != self.kind.size else {
            throw oid_error_invalid("unknown type")
        }
        
        return Oid(kind: self.kind, rawValue: self.rawValue)
        
        // The above code translates this original C code:
        //
        // int git_oid_cpy(git_oid *out, const git_oid *src)
        // {
        //     size_t size;
        //
        //     if (!(size = git_oid_size(git_oid_type(src))))
        //         return oid_error_invalid("unknown type");
        //
        // #ifdef GIT_EXPERIMENTAL_SHA256
        //     out->type = src->type;
        // #endif
        //
        //     return git_oid_raw_cpy(out->id, src->id, size);
        // }
    }
}



public extension Oid.Kind {
    
    init(of oid: Oid) {
        self = oid.kind
    }
    
    
    @inline(__always)
    var size: size_t {
        switch self {
        case .sha1:
            GIT_OID_SHA1_SIZE
            
        case .sha256:
            GIT_OID_SHA256_SIZE
        }
    }
}



// MARK: - [private] Errors

private func oid_error_invalid(_ message: String) -> GitError {
    return GitError(message: "unable to parse OID - \(message)", kind: GitError.Kind.invalid, code: .__generic)
}



// MARK: - Migration

@available(*, unavailable, renamed: "Oid.Kind.size")
public func git_oid_size(_: git_oid_t) -> size_t { fatalError() }

@available(*, unavailable, renamed: "Oid.Kind.init(of:)")
public func git_oid_type(_: git_oid) -> git_oid_t { fatalError() }

@available(*, unavailable, message: "Swift's = assignment is sufficient")
public func git_oid_raw_cpy<T>(_: inout T, _: T, _: size_t) -> CInt { fatalError() }

@available(*, unavailable, renamed: "Oid.copy", message: "Just like `=` assignment, the left is the new copy, right is the original")
public func git_oid_cpy(_: inout git_oid, _: git_oid) -> CInt { fatalError() }
