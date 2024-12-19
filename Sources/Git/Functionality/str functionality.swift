//
// str functionality.swift
//
// Written by Ky on 2024-12-18.
// Copyright waived. No rights reserved.
//
// This file is part of libgit2.swift, distributed under the Fair License.
// For full terms, see the included LICENSE file.
//

import Foundation

public let git_str__oom = "\u{0}"

@available(*, deprecated, renamed: "nil", message: "You should only have to nilify the String and the Swift runtime will take care of the rest.")
@inline(__always)
public func git_str_dispose(string: inout String?) {
    string = nil
}



// MARK: - Migration

@available(*, unavailable, renamed: "git_str_dispose(string:)", message: "Evaluate whether this is necessary in Swift (original was mostly deallocation)")
public func git_str_dispose(_: inout git_str) { fatalError() }

@available(*, unavailable, message: "Swift = assignment should be sufficient")
public func git_str_puts(_: inout git_str, _: inout String) -> CInt { fatalError() }
