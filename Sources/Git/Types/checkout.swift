//
// checkout.swift
//
// Written by Ky on 2024-11-27.
// Copyright waived. No rights reserved.
//
// This file is part of libgit2.swift, distributed under the Fair License.
// For full terms, see the included LICENSE file.
//

import Foundation



public let GIT_CHECKOUT_OPTIONS_VERSION = 1
public let GIT_CHECKOUT_OPTIONS_INIT = (version: GIT_CHECKOUT_OPTIONS_VERSION, strategy: Checkout.Strategy.safe)



public enum Checkout: AnyEnumProtocol {
}



public extension Checkout {
    enum Strategy: UInt32, AutoOptionSet, AnyEnumProtocol {
        
        case __empty = 0
        
        /**
         * Allow safe updates that cannot overwrite uncommitted data.
         * If the uncommitted changes don't conflict with the checked out files,
         * the checkout will still proceed, leaving the changes intact.
         *
         * Mutually exclusive with GIT_CHECKOUT_FORCE.
         * GIT_CHECKOUT_FORCE takes precedence over GIT_CHECKOUT_SAFE.
         */
        case safe =                       0b0000_0000__0000_0000__0000_0000__0000_0001 //(1 << 0)

        /**
         * Allow all updates to force working directory to look like index.
         *
         * Mutually exclusive with GIT_CHECKOUT_SAFE.
         * GIT_CHECKOUT_FORCE takes precedence over GIT_CHECKOUT_SAFE.
         */
        case force =                      0b0000_0000__0000_0000__0000_0000__0000_0010 //(1 << 1)


        /** Allow checkout to recreate missing files */
        case recreateMissing =            0b0000_0000__0000_0000__0000_0000__0000_0100 //(1 << 2)

        /** Allow checkout to make safe updates even if conflicts are found */
        case allowConflicts =             0b0000_0000__0000_0000__0000_0000__0000_1000 //(1 << 4)

        /** Remove untracked files not in index (that are not ignored) */
        case removeUntracked =            0b0000_0000__0000_0000__0000_0000__0001_0000 //(1 << 5)

        /** Remove ignored files not in index */
        case removeIgnored =              0b0000_0000__0000_0000__0000_0000__0010_0000 //(1 << 6)

        /** Only update existing files, don't create new ones */
        case updateOnly =                 0b0000_0000__0000_0000__0000_0000__0100_0000 //(1 << 7)

        /**
         * Normally checkout updates index entries as it goes; this stops that.
         * Implies `GIT_CHECKOUT_DONT_WRITE_INDEX`.
         */
        case dontUpdateIndex =            0b0000_0000__0000_0000__0000_0000__1000_0000 //(1 << 8)

        /** Don't refresh index/config/etc before doing checkout */
        case noRefresh =                  0b0000_0000__0000_0000__0000_0001__0000_0000 //(1 << 9)

        /** Allow checkout to skip unmerged files */
        case skipUnmerged =               0b0000_0000__0000_0000__0000_0010__0000_0000 //(1 << 10)
        /** For unmerged files, checkout stage 2 from index */
        case useOurs =                    0b0000_0000__0000_0000__0000_0100__0000_0000 //(1 << 11)
        /** For unmerged files, checkout stage 3 from index */
        case useTheirs =                  0b0000_0000__0000_0000__0000_1000__0000_0000 //(1 << 12)

        /** Treat pathspec as simple list of exact match file paths */
        case disablePathspecMatch =       0b0000_0000__0000_0000__0001_0000__0000_0000 //(1 << 13)

        /** Ignore directories in use, they will be left empty */
        case skipLockedDirectories =      0b0000_0000__0000_0010__0000_0000__0000_0000 //(1 << 18)

        /** Don't overwrite ignored files that exist in the checkout target */
        case dontOverwriteIgnored =       0b0000_0000__0000_0100__0000_0000__0000_0000 //(1 << 19)

        /** Write normal merge files for conflicts */
        case conflictStyle_merge =        0b0000_0000__0000_1000__0000_0000__0000_0000 //(1 << 20)

        /** Include common ancestor data in diff3 format files for conflicts */
        case conflictStyle_diff3 =        0b0000_0000__0001_0000__0000_0000__0000_0000 //(1 << 21)

        /** Don't overwrite existing files or folders */
        case dontRemoveExisting =         0b0000_0000__0010_0000__0000_0000__0000_0000 //(1 << 22)

        /** Normally checkout writes the index upon completion; this prevents that. */
        case dontWriteIndex =             0b0000_0000__0100_0000__0000_0000__0000_0000 //(1 << 23)

        /**
         * Show what would be done by a checkout.  Stop after sending
         * notifications; don't update the working directory or index.
         */
        case dryRun =                     0b0000_0000__1000_0000__0000_0000__0000_0000 //(1 << 24)

        /** Include common ancestor data in zdiff3 format for conflicts */
        case conflictStyle_zdiff3 =       0b0000_0001__0000_0000__0000_0000__0000_0000 //(1 << 25)

        // THE FOLLOWING OPTIONS ARE NOT YET IMPLEMENTED

        /** Recursively checkout submodules with same options (NOT IMPLEMENTED) */
        case updateSubmodules =           0b0000_0000__0000_0000__1000_0000__0000_0000 //(1 << 16)
        /** Recursively checkout submodules if HEAD moved in super repo (NOT IMPLEMENTED) */
        case updateSubmodules_ifChanged = 0b0000_0000__0000_0001__0000_0000__0000_0000 //(1 << 17)
    }
}



public extension Checkout.Strategy {
    
    /// default is a dry run, no actual updates
    @available(*, unavailable, renamed: "nil")
    static let none = Self?.none
}




@available(*, unavailable, renamed: "nil")
public var GIT_CHECKOUT_NONE: Checkout.Strategy?                        { .none }

@available(*, unavailable, renamed: "Checkout.Strategy.safe")
public var GIT_CHECKOUT_SAFE: Checkout.Strategy                         { .safe }

@available(*, unavailable, renamed: "Checkout.Strategy.force")
public var GIT_CHECKOUT_FORCE: Checkout.Strategy                        { .force }

@available(*, unavailable, renamed: "Checkout.Strategy.recreateMissing")
public var GIT_CHECKOUT_RECREATE_MISSING: Checkout.Strategy             { .recreateMissing }

@available(*, unavailable, renamed: "Checkout.Strategy.allowConflicts")
public var GIT_CHECKOUT_ALLOW_CONFLICTS: Checkout.Strategy              { .allowConflicts }

@available(*, unavailable, renamed: "Checkout.Strategy.removeUntracked")
public var GIT_CHECKOUT_REMOVE_UNTRACKED: Checkout.Strategy             { .removeUntracked }

@available(*, unavailable, renamed: "Checkout.Strategy.removeIgnored")
public var GIT_CHECKOUT_REMOVE_IGNORED: Checkout.Strategy               { .removeIgnored }

@available(*, unavailable, renamed: "Checkout.Strategy.updateOnly")
public var GIT_CHECKOUT_UPDATE_ONLY: Checkout.Strategy                  { .updateOnly }

@available(*, unavailable, renamed: "Checkout.Strategy.dontUpdateIndex")
public var GIT_CHECKOUT_DONT_UPDATE_INDEX: Checkout.Strategy            { .dontUpdateIndex }

@available(*, unavailable, renamed: "Checkout.Strategy.noRefresh")
public var GIT_CHECKOUT_NO_REFRESH: Checkout.Strategy                   { .noRefresh }

@available(*, unavailable, renamed: "Checkout.Strategy.skipUnmerged")
public var GIT_CHECKOUT_SKIP_UNMERGED: Checkout.Strategy                { .skipUnmerged }

@available(*, unavailable, renamed: "Checkout.Strategy.useOurs")
public var GIT_CHECKOUT_USE_OURS: Checkout.Strategy                     { .useOurs }

@available(*, unavailable, renamed: "Checkout.Strategy.useTheirs")
public var GIT_CHECKOUT_USE_THEIRS: Checkout.Strategy                   { .useTheirs }

@available(*, unavailable, renamed: "Checkout.Strategy.disablePathspecMatch")
public var GIT_CHECKOUT_DISABLE_PATHSPEC_MATCH: Checkout.Strategy       { .disablePathspecMatch }

@available(*, unavailable, renamed: "Checkout.Strategy.skipLockedDirectories")
public var GIT_CHECKOUT_SKIP_LOCKED_DIRECTORIES: Checkout.Strategy      { .skipLockedDirectories }

@available(*, unavailable, renamed: "Checkout.Strategy.dontOverwriteIgnored")
public var GIT_CHECKOUT_DONT_OVERWRITE_IGNORED: Checkout.Strategy       { .dontOverwriteIgnored }

@available(*, unavailable, renamed: "Checkout.Strategy.conflictStyle_merge")
public var GIT_CHECKOUT_CONFLICT_STYLE_MERGE: Checkout.Strategy         { .conflictStyle_merge }

@available(*, unavailable, renamed: "Checkout.Strategy.conflictStyle_diff3")
public var GIT_CHECKOUT_CONFLICT_STYLE_DIFF3: Checkout.Strategy         { .conflictStyle_diff3 }

@available(*, unavailable, renamed: "Checkout.Strategy.dontRemoveExisting")
public var GIT_CHECKOUT_DONT_REMOVE_EXISTING: Checkout.Strategy         { .dontRemoveExisting }

@available(*, unavailable, renamed: "Checkout.Strategy.dontWriteIndex")
public var GIT_CHECKOUT_DONT_WRITE_INDEX: Checkout.Strategy             { .dontWriteIndex }

@available(*, unavailable, renamed: "Checkout.Strategy.dryRun")
public var GIT_CHECKOUT_DRY_RUN: Checkout.Strategy                      { .dryRun }

@available(*, unavailable, renamed: "Checkout.Strategy.conflictStyle_zdiff3")
public var GIT_CHECKOUT_CONFLICT_STYLE_ZDIFF3: Checkout.Strategy        { .conflictStyle_zdiff3 }

@available(*, unavailable, renamed: "Checkout.Strategy.updateSubmodules")
public var GIT_CHECKOUT_UPDATE_SUBMODULES: Checkout.Strategy            { .updateSubmodules }

@available(*, unavailable, renamed: "Checkout.Strategy.updateSubmodules_ifChanged")
public var GIT_CHECKOUT_UPDATE_SUBMODULES_IF_CHANGED: Checkout.Strategy { .updateSubmodules_ifChanged }



// MARK: - Migration

@available(*, unavailable, renamed: "Checkout.Strategy")
public typealias git_checkout_strategy_t = Checkout.Strategy
