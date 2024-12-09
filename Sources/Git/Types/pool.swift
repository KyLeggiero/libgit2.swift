//
// pool.swift
//
// Written by Ky on 2024-11-11.
// Copyright waived. No rights reserved.
//
// This file is part of libgit2.swift, distributed under the Fair License.
// For full terms, see the included LICENSE file.
//

import Foundation

@preconcurrency import SafePointer



#if !GIT_DEBUG_POOL
/// Chunked allocator.
///
/// A `git_pool` can be used when you want to cheaply allocate
/// multiple items of the same type and are willing to free them
/// all together with a single call.  The two most common cases
/// are a set of fixed size items (such as lots of OIDs) or a
/// bunch of strings.
///
/// Internally, a `git_pool` allocates pages of memory and then
/// deals out blocks from the trailing unused portion of each page.
/// The pages guarantee that the number of actual allocations done
/// will be much smaller than the number of items needed.
///
/// For examples of how to set up a `git_pool` see `git_pool_init`.
public struct Pool: AnyStructProtocol {
    
    /// allocated pages
    public var pages: [Pool.Page]
    
    /// size of single alloc unit in bytes
    public var itemSize: size_t
    
    /// size of page in bytes
    public var pageSize: size_t
}
#else
/// Debug chunked allocator.
///
/// Acts just like `git_pool` but instead of actually pooling allocations it
/// passes them through to `git__malloc`. This makes it possible to easily debug
/// systems that use `git_pool` using valgrind.
///
/// In order to track allocations during the lifetime of the pool we use a
/// `git_vector`. When the pool is deallocated everything in the vector is
/// freed.
///
/// `API is exactly the same as the standard `git_pool` with one exception.
/// Since we aren't allocating pages to hand out in chunks we can't easily
/// implement `git_pool__open_pages`.
public struct Pool: AnyStructProtocol {
    public var allocations: git_vector
    public var itemSize: size_t
    public var pageSize: size_t
}
#endif



public extension Pool {
    struct Page: AnyStructProtocol {
        internal weak var next: SafePointer<Self>?
        internal var size: size_t
        internal var avail: size_t
        internal var data: [CChar] // the C version found it necessary to align this to 8 at util/pool.c:19
    }
}



// MARK: - Migration

@available(*, unavailable, renamed: "Pool")
public typealias git_pool = Pool


@available(*, unavailable, renamed: "Pool.Page")
public typealias git_pool_page = Pool.Page



public extension Pool {
    @available(*, unavailable, renamed: "itemSize")
    var item_size: size_t { fatalError("use itemSize") }
    
    @available(*, unavailable, renamed: "pageSize")
    var page_size: size_t { fatalError("use pageSize") }
}
