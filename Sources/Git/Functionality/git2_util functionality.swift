//
// git2_util functionality.swift
//
// Written by Ky on 2025-02-18.
// Copyright waived. No rights reserved.
//
// This file is part of libgit2.swift, distributed under the Fair License.
// For full terms, see the included LICENSE file.
//

import Foundation



/// Check for an error value and throw it if non-nil.
/// - Parameter error: The error to throw, or `nil` to not throw an error
/// - Throws: `error` iff it's non-`nil`
@inline(__always)
public func GIT_ERROR_CHECK_ERROR(_ error: GitError?) throws(GitError) {
    if let error {
        throw error
    }
}


@inline(__always)
public func GIT_ERROR_CHECK_ERROR<Return>(_ checkedFunction: @autoclosure () throws(GitError) -> Return) throws(GitError) -> Return {
    try checkedFunction()
}



public extension FixedWidthInteger {
    
    /** Check for additive overflow, failing if it would occur. */
    func addOrThrowOnOverflow(_ two: Self) throws(GitError) -> Self {
        let (out, overflow) = self.addingReportingOverflow(two)
        
        if overflow {
            throw .init(code: .__generic)
        }
        else {
            return out
        }
    }
}



// MARK: - Migrating

@available(*, unavailable, renamed: "one.addReportingOverflow(_:)")
public func GIT_ADD_SIZET_OVERFLOW(one: size_t, two: size_t) -> (result: size_t, overflow: Bool) { fatalError() }


@available(*, unavailable, renamed: "one.addOrThrowOnOverflow(_:)")
public func GIT_ERROR_CHECK_ALLOC_ADD<Out, One, Two>(out: inout Out, one: One, two: Two) { fatalError() }
