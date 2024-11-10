//
// odb.swift
//
// Written by Ky on 2024-11-10.
// Copyright waived. No rights reserved.
//
// This file is part of libgit2.swift, distributed under the Free License.
// For full terms, see the included LICENSE file.
//

import Foundation



struct git_odb {
    var rc: RefCount
    var lock: git_mutex  /* protects backends */
    var options: git_odb_options
    var backends: git_vector
    var own_cache: Cache
    var cgraph: git_commit_graph
    var do_fsync: CUnsignedInt = 1
};
