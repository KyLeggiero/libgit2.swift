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

@preconcurrency import SafePointer



@available(*, unavailable, renamed: "Repository")
typealias git_repository = Repository
public struct Repository: AnyStructProtocol {
    public var _odb: ObjectDatabase
    public var _refdb: ReferenceDatabase
    public var _config: Config
    public var _index: git_index

    public var objects: Cache
    public weak var attrcache: SafePointer<AttributeCache>?
    public weak var diff_drivers: SafePointer<git_diff_driver_registry>?

    public var gitlink: String
    public var gitdir: String
    public var commondir: String
    public var workdir: String
    public var namespace: String

    public var ident_name: String
    public var ident_email: String

    public var reserved_names: [String]

    public var use_env = true
    public var is_bare = true
    public var is_worktree = true
    
    public var oid_type: Oid.Kind

    public var lru_counter: UInt

    public weak var grafts: SafePointer<git_grafts>?
    public weak var shallow_grafts: SafePointer<git_grafts>?

    public var attr_session_key: Atomic32

    public var configmap_cache: [ConfigmapItem]
    public var submodule_cache: StringMap
};



@available(*, unavailable, renamed: "ConfigmapItem")
typealias git_configmap_item = ConfigmapItem
/** Cvar cache identifiers */
public enum ConfigmapItem: Int, AnyEnumProtocol {
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
