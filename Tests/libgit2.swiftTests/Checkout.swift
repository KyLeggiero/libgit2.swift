//
// Checkout.swift
//
// Written by Ky on 2024-11-27.
// Copyright waived. No rights reserved.
//
// This file is part of libgit2.swift, distributed under the Fair License.
// For full terms, see the included LICENSE file.
//

import Testing

import Git



struct Checkout {

    @Test
    func checkout() async throws {
        var treeish: Object? = nil
        var opts = git_checkout_options.GIT_CHECKOUT_OPTIONS_INIT
        opts.checkout_strategy = GIT_CHECKOUT_SAFE

        Libgit2.initialize()

        handleError(git_revparse_single(&treeish, repo, "master"));
        handleError(git_checkout_tree(repo, treeish, &opts));

        handleError(git_repository_set_head(g_repo, "refs/heads/master"));

        git_object_free(treeish);
        git_libgit2_shutdown();

    }
}
