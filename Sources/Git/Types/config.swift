//
// config.swift
//
// Written by Ky on 2024-11-11.
// Copyright waived. No rights reserved.
//
// This file is part of libgit2.swift, distributed under the Fair License.
// For full terms, see the included LICENSE file.
//

import Foundation



public struct Config: AnyStructProtocol {
    public var refCount: RefCount
    public var readers: [AnyTypeProtocol]
    public var writers: [AnyTypeProtocol]
}



/**
 * Config var type
 */
public enum git_configmap_t: CInt, AnyEnumProtocol {
    case `false` = 0
    case `true` = 1
    case int32
    case string
}



// MARK: - Migration

@available(*, unavailable, renamed: "Config")
public typealias git_config = Config



public extension Config {
    @available(*, unavailable, renamed: "refCount")
    var rc: git_refcount { refCount }
}


@available(*, unavailable, renamed: "git_configmap_t.false")
public var GIT_CONFIGMAP_FALSE: git_configmap_t { fatalError() }

@available(*, unavailable, renamed: "git_configmap_t.true")
public var GIT_CONFIGMAP_TRUE: git_configmap_t { fatalError() }

@available(*, unavailable, renamed: "git_configmap_t.int32")
public var GIT_CONFIGMAP_INT32: git_configmap_t { fatalError() }

@available(*, unavailable, renamed: "git_configmap_t.string")
public var GIT_CONFIGMAP_STRING: git_configmap_t { fatalError() }




