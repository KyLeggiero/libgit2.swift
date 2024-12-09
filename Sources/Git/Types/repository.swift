//
// oid.swift
//
// Written by Ky on 2024-11-10.
// Copyright waived. No rights reserved.
//
// This file is part of libgit2.swift, distributed under the Fair License.
// For full terms, see the included LICENSE file.
//

import Foundation

@preconcurrency import SafePointer



public struct Repository: AnyStructProtocol {
    public var _odb: ObjectDatabase
    public var _refdb: ReferenceDatabase
    public var _config: Config
    public var _index: Index

    public var objects: Cache
    public weak var attrcache: SafePointer<AttributeCache>?
    public weak var diffDrivers: SafePointer<DiffDriverRegistry>?

    public var gitlink: String
    public var gitdir: String
    public var commondir: String
    public var workdir: String
    public var namespace: String

    public var ident_name: String
    public var ident_email: String

    public var reservedNames: [String]

    public var useEnv = true
    public var isBare = true
    public var isWorktree = true
    
    public var oid_type: Oid.Kind

    public var lru_counter: UInt

    public weak var grafts: SafePointer<Grafts>?
    public weak var shallowGrafts: SafePointer<Grafts>?

    public var attr_session_key: Atomic32

    public var configmapCache: [ConfigmapItem]
    public var submoduleCache: StringMap
};



/** Cvar cache identifiers */
public enum ConfigmapItem: Int, AnyEnumProtocol {
    case autoCrlf = 0      /* core.autocrlf */
    case eol               /* core.eol */
    case symlinks          /* core.symlinks */
    case ignoreCase        /* core.ignorecase */
    case fileMode          /* core.filemode */
    case ignoreStat        /* core.ignorestat */
    case trustCTime        /* core.trustctime */
    case abbrev            /* core.abbrev */
    case precompose        /* core.precomposeunicode */
    case safeCrlf          /* core.safecrlf */
    case logAllRefUpdates  /* core.logallrefupdates */
    case protectHfs        /* core.protectHFS */
    case protectNtfs       /* core.protectNTFS */
    case fSyncObjectFiles  /* core.fsyncObjectFiles */
    case logPaths          /* core.longpaths */
    
    case cacheMax
}



// MARK: - Migration

@available(*, unavailable, renamed: "Repository")
typealias git_repository = Repository

@available(*, unavailable, renamed: "ConfigmapItem")
typealias git_configmap_item = ConfigmapItem



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



public extension Repository {
    @available(*, unavailable, renamed: "diffDrivers")
    var diff_drivers: git_diff_driver_registry { fatalError("use diffDrivers") }
    
    @available(*, unavailable, renamed: "reservedNames")
    var reserved_names: [String] { fatalError("use reservedNames") }
    
    
    @available(*, unavailable, renamed: "useEnv")
    var use_env: CUnsigned { fatalError("use useEnv") }
    
    @available(*, unavailable, renamed: "isBare")
    var is_bare: CUnsigned { fatalError("use isBare") }
    
    @available(*, unavailable, renamed: "isWorktree")
    var is_worktree: CUnsigned { fatalError("use isWorktree") }
    
    @available(*, unavailable, renamed: "shallowGrafts")
    var shallow_grafts: SafePointer<Grafts>? { fatalError("use shallowGrafts") }
    
    @available(*, unavailable, renamed: "configmapCache")
    var configmap_cache: [ConfigmapItem] { fatalError("use configmapCache") }
    
    @available(*, unavailable, renamed: "submoduleCache")
    var submodule_cache: StringMap { fatalError("use submoduleCache") }
}
