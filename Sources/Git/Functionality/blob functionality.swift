//
// blob functionality.swift
//
// Written by Ky on 2025-01-25.
// Copyright waived. No rights reserved.
//
// This file is part of libgit2.swift, distributed under the Fair License.
// For full terms, see the included LICENSE file.
//

import Foundation

/**
 * Get the id of a blob.
 *
 * @param blob a previously loaded blob.
 * @return SHA1 hash for this blob.
 */
public func git_blob_id(obj: git_blob) -> Oid {
    obj.cached.oid
}
