//
// errors functionality.swift
//
// Written by Ky on 2024-12-08.
// Copyright waived. No rights reserved.
//
// This file is part of libgit2.swift, distributed under the Fair License.
// For full terms, see the included LICENSE file.
//

import Foundation



public extension GitError {
    // Analogous to `git_error_global_init`
    @MainActor
    @available(*, deprecated, message: "This is likely unnecessary in Swift (seems all it did was deallocate things)")
    static func globalInit() async {
        // TODO: Do we need to register on-Task-exit hooks here?
//        tls_key = Git.TlsData.onThreadExit(callback: threadstate_free)
        // TODO: Do we need to register on-shutdown hooks here?
//        await Git.Runtime.registerShutdownHook(git_error_global_shutdown)
    }
}



// MARK: - Migrated

@available(*, unavailable, renamed: "GitError.globalInit")
public func git_error_global_init() -> CInt { fatalError() }
