//
// sha.swift
//
// Written by Ky on 2024-12-09.
// Copyright waived. No rights reserved.
//
// This file is part of libgit2.swift, distributed under the Fair License.
// For full terms, see the included LICENSE file.
//

import Foundation

#if GIT_SHA256_BUILTIN

struct git_hash_sha256_ctx {
    var c: SHA256Context
}

#endif
