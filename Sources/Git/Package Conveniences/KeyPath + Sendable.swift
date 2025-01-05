//
// KeyPath + Sendable.swift
//
// Written by Ky on 2025-01-03.
// Copyright waived. No rights reserved.
//
// This file is part of libgit2.swift, distributed under the Fair License.
// For full terms, see the included LICENSE file.
//

import Foundation




extension KeyPath: @retroactive @unchecked Sendable where Root: Sendable, Value: Sendable {
    
}
