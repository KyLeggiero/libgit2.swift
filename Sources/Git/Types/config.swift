//
// config.swift
//
// Written by Ky on 2024-11-11.
// Copyright waived. No rights reserved.
//
// This file is part of libgit2.swift, distributed under the Fair License.
// For full terms, see the included LICENSE file.
//

import Foundation



public struct Config: AnyStructProtocol {
    public var refCount: RefCount
    public var readers: ArbitraryArray
    public var writers: ArbitraryArray
}



// MARK: - Migration

@available(*, unavailable, renamed: "Config")
public typealias git_config = Config



public extension Config {
    @available(*, unavailable, renamed: "refCount")
    var rc: git_refcount { refCount }
}
