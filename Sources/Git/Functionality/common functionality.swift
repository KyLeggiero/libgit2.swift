//
// common functionality.swift
//
// Written by Ky on 2025-02-18.
// Copyright waived. No rights reserved.
//
// This file is part of libgit2.swift, distributed under the Fair License.
// For full terms, see the included LICENSE file.
//

import Foundation



/**
 * Initialize a structure with a version.
 */
@inline(__always)
public func git__init_structure<Structure>(structure: Structure.Type = Structure.self, version: Structure.Version)
-> Structure
where Structure: Versioned
{
    return .init(version: version)
}


@inline(__always)
public func GIT_INIT_STRUCTURE<Structure>(structure: Structure.Type = Structure.self, version: Structure.Version)
-> Structure
where Structure: Versioned
{
    git__init_structure(version: version)
}


@inline(__always)
public func GIT_INIT_STRUCTURE_FROM_TEMPLATE<Structure>(version: Structure.Version, type: Structure.Type = Structure.self, template: Structure)
-> Structure
where Structure: Versioned
{
    try? GIT_ERROR_CHECK_VERSION(version: version, expectedMax: template.version, name: String(describing: type.self))
    return template
}

                                                    
/**
 * Check a versioned structure for validity
 */
@inline(__always)
public func git_error__check_version<Structure>(structure: Structure?, expectedMax: Structure.Version, name: String) throws(GitError)
where Structure: Versioned
{
    guard let structure else { return }
    
    try git_error__check_version(version: structure.version, expectedMax: expectedMax, name: name)
}


@inline(__always)
public func git_error__check_version(version: Versioned.Version, expectedMax: Versioned.Version, name: String) throws(GitError) {
    guard version > 0, version <= expectedMax else {
        throw .init(message: "invalid version \(version) on \(name)", kind: .invalid, code: .__generic)
    }
}


@inline(__always)
public func GIT_ERROR_CHECK_VERSION<Structure>(structure: Structure, expectedMax: Structure.Version, name: String) throws(GitError)
where Structure: Versioned {
    do {
        try git_error__check_version(structure: structure,expectedMax: expectedMax,name: name)
    }
    catch var error where nil != error.code {
        error.code = .__generic
        throw error
    }
}


@inline(__always)
public func GIT_ERROR_CHECK_VERSION(version: Versioned.Version, expectedMax: Versioned.Version, name: String) throws(GitError) {
    do {
        try git_error__check_version(version: version, expectedMax: expectedMax, name: name)
    }
    catch var error where nil != error.code {
        error.code = .__generic
        throw error
    }
}
