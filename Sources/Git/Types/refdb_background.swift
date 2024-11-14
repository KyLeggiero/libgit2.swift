//
// refdb_background.swift
//
// Written by Ky on 2024-11-11.
// Copyright waived. No rights reserved.
//
// This file is part of libgit2.swift, distributed under the Free License.
// For full terms, see the included LICENSE file.
//

import Foundation



/// An instance for a custom backend
public extension ReferenceDatabase {
    struct Backend: AnyStructProtocol {
        /// The backend API version
        var version: CUnsignedInt
    }
}



// MARK: - Migration

@available(*, unavailable, renamed: "ReferenceDatabase.Backend")
public typealias git_refdb_backend = ReferenceDatabase.Backend
