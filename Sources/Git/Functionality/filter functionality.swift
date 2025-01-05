//
// filter functionality.swift
//
// Written by Ky on 2024-12-07.
// Copyright waived. No rights reserved.
//
// This file is part of libgit2.swift, distributed under the Fair License.
// For full terms, see the included LICENSE file.
//

import Foundation



public extension Filter {
    
    @MainActor
    static func initialize() async throws(GitError) {
        
        await Registry.SyncLock.run {
            Registry.shared = .init(filters: SelfSortingArray(comparingBy: \.priority))
        }
        
        guard let crlf = try git_crlf_filter_new() else {
            throw GitError.generic
        }
        try filter_registry_insert(GIT_FILTER_CRLF, crlf, GIT_FILTER_CRLF_PRIORITY)
        
        guard let ident = try git_ident_filter_new() else {
            throw GitError.generic
        }
        try filter_registry_insert(GIT_FILTER_IDENT, ident, GIT_FILTER_IDENT_PRIORITY)
        
        try git_runtime_shutdown_register(git_filter_global_shutdown)
        
        // The above code translates this original C code:
        //
        //     git_filter *crlf = NULL, *ident = NULL;
        //     int error = 0;
        //
        //     if (git_rwlock_init(&filter_registry.lock) < 0)
        //         return -1;
        //
        //     if ((error = git_vector_init(&filter_registry.filters, 2,
        //         filter_def_priority_cmp)) < 0)
        //         goto done;
        //
        //     if ((crlf = git_crlf_filter_new()) == NULL ||
        //         filter_registry_insert(
        //             GIT_FILTER_CRLF, crlf, GIT_FILTER_CRLF_PRIORITY) < 0 ||
        //         (ident = git_ident_filter_new()) == NULL ||
        //         filter_registry_insert(
        //             GIT_FILTER_IDENT, ident, GIT_FILTER_IDENT_PRIORITY) < 0)
        //         error = -1;
        //
        //     if (!error)
        //         error = git_runtime_shutdown_register(git_filter_global_shutdown);
        //
        // done:
        //     if (error) {
        //         git_filter_free(crlf);
        //         git_filter_free(ident);
        //     }
        //
        //     return error;
    }
}



private extension Filter {
    // Analogous to `filter_def_priority_cmp`
    @inline(__always)
    static func filterDefinitionPriorityCompare(a: git_filter_def, b: git_filter_def) -> ComparisonResult
    {
        ComparisonResult(a, b, by: \.priority)
    }
}



private struct git_filter_def {
    var filter_name: String
    var filter: Filter
    var priority: CInt
    var initialized: CInt
    var nattrs: size_t
    var nmatches: size_t
    var attrdata: String
    let attrs: String
}



// MARK: - Registry

private extension Filter {
    struct Registry: AnyStructProtocol {
        
        @SyncLock
        var filters: SelfSortingArray<git_filter_def>
        
        @SyncLock
        init(filters: SelfSortingArray<git_filter_def>) {
            self.filters = filters
        }
    }
}



private extension Filter.Registry {
    @globalActor
    final actor SyncLock: GlobalActor {
        public static var shared = Volatile()
        
        @SyncLock
        static func run<Value>(_ block: @SyncLock () -> Value) -> Value {
            block()
        }
        
        
        @SyncLock
        static func run<Value>(_ block: @SyncLock () throws(GitError) -> Value) throws(GitError) -> Value {
            try block()
        }
        
        
        @SyncLock
        static func run<Value>(_ block: @SyncLock () async -> Value) async -> Value {
            await block()
        }
        
        
        @SyncLock
        static func run<Value>(_ block: @SyncLock () async throws(GitError) -> Value) async throws(GitError) -> Value {
            try await block()
        }
    }
}




private extension Filter.Registry {
    @SyncLock
    static var shared = Self(filters: .init())
}



// MARK: - Migration

@available(*, unavailable, renamed: "Filter.Registry.shared")
@Filter.Registry.SyncLock
private var filter_registry: Filter.Registry { get { .shared } set { .shared = newValue } }


@available(*, unavailable, renamed: "Filter.initialize()")
public func git_filter_global_init() -> CInt { fatalError() }

@available(*, unavailable, renamed: "Filter.filterDefinitionPriorityCompare(a:b:)")
public func filter_def_priority_cmp(_: Any, _: Any) -> CInt { fatalError() }
