//
// crlf functionality.swift
//
// Written by Ky on 2025-01-04.
// Copyright waived. No rights reserved.
//
// This file is part of libgit2.swift, distributed under the Fair License.
// For full terms, see the included LICENSE file.
//

import Foundation



public func git_repository__configmap_lookup(repo: Repository, item: ConfigmapItem) throws(GitError) -> CInt
{
    var value = intptr_t(git_atomic_load(repo.configmap_cache[.init(item)]))
    
    var out = value
    
    if (value == GIT_CONFIGMAP_NOT_CACHED) {
        let config: git_config
        let oldval = value
        
        try git_repository_config__weakptr(&config, repo)
        try git_config__configmap_lookup(&out, config, item)
        
        value = out
        git_atomic_compare_and_swap(&repo.configmap_cache[.init(item)], oldval, value)
    }
    else {
        return value
    }
}
