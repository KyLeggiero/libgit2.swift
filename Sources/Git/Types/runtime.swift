//
// runtime.swift
//
// Written by Ky on 2024-12-05.
// Copyright waived. No rights reserved.
//
// This file is part of libgit2.swift, distributed under the Fair License.
// For full terms, see the included LICENSE file.
//

import Foundation



public enum Git {}



public extension Git {
    enum Runtime {}
}



// MARK: - Migration

@available(*, unavailable, renamed: "Git.Runtime.InitFunction")
typealias git_runtime_init_fn = () -> CInt

@available(*, unavailable, renamed: "Git.Runtime.ShutdownFunction")
typealias git_runtime_shutdown_fn = () -> Void

@available(*, unavailable, renamed: "Git.Runtime.initialize(initializationFunctions:)")
func git_runtime_init(_: [git_runtime_init_fn], _: size_t) -> CInt { -1 }

@available(*, unavailable, renamed: "Git.Runtime.initCount")
func git_runtime_init_count() -> CInt { -1 }

@available(*, unavailable, renamed: "Git.Runtime.shutdown()")
func git_runtime_shutdown() -> CInt { -1 }

@available(*, unavailable, renamed: "Git.Runtime.registerShutdownHook(_:)")
func git_runtime_shutdown_register(_: git_runtime_shutdown_fn) -> CInt { -1 }
