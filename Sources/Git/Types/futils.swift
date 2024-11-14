//
// futils.swift
//
// Written by Ky on 2024-11-12.
// Copyright waived. No rights reserved.
//
// This file is part of libgit2.swift, distributed under the Free License.
// For full terms, see the included LICENSE file.
//

import Foundation



public struct Filestamp: AnyStructProtocol {
    public var mtime: timespec
    public var size: __uint64_t
    public var ino: CUnsignedInt
}



// MARK: - Migration

@available(*, unavailable, renamed: "Filestamp")
public typealias git_futils_filestamp = Filestamp
