//
// attr functionality.swift
//
// Written by Ky on 2025-02-14.
// Copyright waived. No rights reserved.
//
// This file is part of libgit2.swift, distributed under the Fair License.
// For full terms, see the included LICENSE file.
//

import Foundation



public let GIT_ATTR_OPTIONS_VERSION: Versioned.Version = 1
public var GIT_ATTR_OPTIONS_INIT: git_attr_options { .init(version: GIT_ATTR_OPTIONS_VERSION, flags: []) }
