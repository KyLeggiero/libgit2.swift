//
// diff_driver.swift
//
// Written by Ky on 2024-11-13.
// Copyright waived. No rights reserved.
//
// This file is part of libgit2.swift, distributed under the Free License.
// For full terms, see the included LICENSE file.
//

import Foundation

@preconcurrency import SafePointer



public struct git_diff_driver_registry: AnyStructProtocol {
    public weak var drivers: SafePointer<StringMap>?
}
