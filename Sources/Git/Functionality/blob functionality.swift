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
 * - Parameter blob: a previously loaded blob.
 * - Returns: SHA1 hash for this blob.
 */
public func git_blob_id(obj: git_blob) -> Oid {
    // unsure if ths is what the C version meant by
    // ```object_api.c
    //     return git_oject_id((const git_object *)obj);
    // ```
    // ```object.c
    // const git_oid *git_object_id(const git_object *obj) {
    //     return &obj->cached.oid;
    // }
    // ```
    obj.object.cached.oid
}
