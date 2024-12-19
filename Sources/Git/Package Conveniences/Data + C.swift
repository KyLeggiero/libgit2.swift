//
// Data + C.swift
//
// Written by Ky on 2024-12-09.
// Copyright waived. No rights reserved.
//
// This file is part of libgit2.swift, distributed under the Fair License.
// For full terms, see the included LICENSE file.
//

import Foundation



internal extension Data {
    /// Converts this Data structure to an array of bytes
    ///
    /// Also allows you to write new data using an array of bytes
    @inline(__always)
    var bytes: [UInt8] {
        get {
            .init(self)
        }
        set {
            self = .init(newValue)
        }
    }
}
