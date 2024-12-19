//
// Data + hexEncodedString.swift
//
// Written by Ky on 2024-12-13.
// Copyright waived. No rights reserved.
//
// This file is part of libgit2.swift, distributed under the Fair License.
// For full terms, see the included LICENSE file.
//

import Foundation



extension Data {
    
    /// Encodes these data to a hex string
    var hexEncodedString: String {
        map { String(format: "%02hhx", $0) }.joined()
    }
}
