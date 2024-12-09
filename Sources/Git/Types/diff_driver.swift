//
// diff_driver.swift
//
// Written by Ky on 2024-11-13.
// Copyright waived. No rights reserved.
//
// This file is part of libgit2.swift, distributed under the Fair License.
// For full terms, see the included LICENSE file.
//

import Foundation

@preconcurrency import SafePointer



public struct DiffDriverRegistry: AnyStructProtocol {
    public var drivers: StringMap?
}



@available(*, unavailable, renamed: "DiffDriverRegistry")
public typealias git_diff_driver_registry = DiffDriverRegistry
