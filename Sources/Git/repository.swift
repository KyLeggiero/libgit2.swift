//
// oid.swift
//
// Written by Ky on 2024-11-10.
// Copyright waived. No rights reserved.
//
// This file is part of libgit2.swift, distributed under the Free License.
// For full terms, see the included LICENSE file.
//

import Foundation


@available(*, unavailable, renamed: "Repository")
typealias git_repository = Repository
public struct Repository: Sendable {
    var _odb: git_odb
    var _refdb: git_refdb
    var _config: git_config
    var _index: git_index

    var objects: Cache
    var attrcache: git_attr_cache
    var diff_drivers: git_diff_driver_registry

    var gitlink: String
    var gitdir: String
    var commondir: String
    var workdir: String
    var namespace: String

    var ident_name: String
    var ident_email: String

    var reserved_names: git_array_t<git_str>

    var use_env = true
    var is_bare = true
    var is_worktree = true
    
    var oid_type: Oid.Kind

    var lru_counter: UInt

    var grafts: git_grafts
    var shallow_grafts: git_grafts

    var attr_session_key: Atomic32

    var configmap_cache: [ConfigmapItem]
    var submodule_cache: git_strmap
};



@available(*, unavailable, renamed: "ConfigmapItem")
typealias git_configmap_item = ConfigmapItem
/** Cvar cache identifiers */
public enum ConfigmapItem: Int, Sendable {
    case autoCrlf = 0     /* core.autocrlf */
    case eol               /* core.eol */
    case symlinks          /* core.symlinks */
    case ignoreCase        /* core.ignorecase */
    case fileMode          /* core.filemode */
    case ignoreStat        /* core.ignorestat */
    case trustCTime        /* core.trustctime */
    case abbrev            /* core.abbrev */
    case precompose        /* core.precomposeunicode */
    case safeCrlf         /* core.safecrlf */
    case logAllRefUpdates  /* core.logallrefupdates */
    case protectHfs        /* core.protectHFS */
    case protectNtfs       /* core.protectNTFS */
    case fSyncObjectFiles  /* core.fsyncObjectFiles */
    case logPaths         /* core.longpaths */
    case cacheMax
}



@available(*, unavailable, renamed: "ConfigmapItem.autoCrlf")
let GIT_CONFIGMAP_AUTO_CRLF = ConfigmapItem.autoCrlf

@available(*, unavailable, renamed: "ConfigmapItem.eol")
let GIT_CONFIGMAP_EOL = ConfigmapItem.eol

@available(*, unavailable, renamed: "ConfigmapItem.symlinks")
let GIT_CONFIGMAP_SYMLINKS = ConfigmapItem.symlinks

@available(*, unavailable, renamed: "ConfigmapItem.ignoreCase")
let GIT_CONFIGMAP_IGNORECASE = ConfigmapItem.ignoreCase

@available(*, unavailable, renamed: "ConfigmapItem.fileMode")
let GIT_CONFIGMAP_FILEMODE = ConfigmapItem.fileMode

@available(*, unavailable, renamed: "ConfigmapItem.ignoreStat")
let GIT_CONFIGMAP_IGNORESTAT = ConfigmapItem.ignoreStat

@available(*, unavailable, renamed: "ConfigmapItem.trustCTime")
let GIT_CONFIGMAP_TRUSTCTIME = ConfigmapItem.trustCTime

@available(*, unavailable, renamed: "ConfigmapItem.abbrev")
let GIT_CONFIGMAP_ABBREV = ConfigmapItem.abbrev

@available(*, unavailable, renamed: "ConfigmapItem.precompose")
let GIT_CONFIGMAP_PRECOMPOSE = ConfigmapItem.precompose

@available(*, unavailable, renamed: "ConfigmapItem.safeCrlf")
let GIT_CONFIGMAP_SAFE_CRLF = ConfigmapItem.safeCrlf

@available(*, unavailable, renamed: "ConfigmapItem.logAllRefUpdates")
let GIT_CONFIGMAP_LOGALLREFUPDATES = ConfigmapItem.logAllRefUpdates

@available(*, unavailable, renamed: "ConfigmapItem.protectHfs")
let GIT_CONFIGMAP_PROTECTHFS = ConfigmapItem.protectHfs

@available(*, unavailable, renamed: "ConfigmapItem.protectNtfs")
let GIT_CONFIGMAP_PROTECTNTFS = ConfigmapItem.protectNtfs

@available(*, unavailable, renamed: "ConfigmapItem.fSyncObjectFiles")
let GIT_CONFIGMAP_FSYNCOBJECTFILES = ConfigmapItem.fSyncObjectFiles

@available(*, unavailable, renamed: "ConfigmapItem.logPaths")
let GIT_CONFIGMAP_LONGPATHS = ConfigmapItem.logPaths

@available(*, unavailable, renamed: "ConfigmapItem.cacheMax")
let GIT_CONFIGMAP_CACHE_MAX = ConfigmapItem.cacheMax
