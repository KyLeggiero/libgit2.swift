//
// "logging".swift
//
// Written by Ky on 2024-12-13.
// Copyright waived. No rights reserved.
//
// This file is part of libgit2.swift, distributed under the Fair License.
// For full terms, see the included LICENSE file.
//

import Foundation



/// Prints the given warning to stderr
///
/// - Parameters:
///   - warning: The warning to print to stderr
package func print(warning: Any..., file: String = #file, function: String = #function, line: Int = #line) {
    print(warning, to: &standardError)
}



extension FileHandle: @retroactive TextOutputStream {
    public func write(_ string: String) {
        guard let data = string.data(using: .utf8) else { return }
        self.write(data)
    }
}



nonisolated(unsafe) internal var standardOutput = FileHandle.standardOutput
nonisolated(unsafe)  internal var standardError = FileHandle.standardError
