//
// String + C.swift
//
// Written by Ky on 2024-12-30.
// Copyright waived. No rights reserved.
//
// This file is part of libgit2.swift, distributed under the Fair License.
// For full terms, see the included LICENSE file.
//

import Foundation



internal extension String {
    /// Converts this String structure to an array of bytes in UTF-8 format
    ///
    /// Also allows you to write new UTF-8 strings using an array of bytes
    @inline(__always)
    var chars: Array<CChar> {
        get {
            .init(utf8CString)
        }
        set {
            var newValue = newValue
            self = String(cString: &newValue)
        }
    }
}



//extension ContiguousArray where Element: BinaryInteger {
//    func unsafeMap<OtherType: BinaryInteger>(to otherType: OtherType.Type) -> ContiguousArray<OtherType>
//    where OtherType.Magnitude == Element.Magnitude {
//        withUnsafePointer(to: self) { unsafeSelf in
//            unsafeSelf.withMemoryRebound(to: ContiguousArray<OtherType>.self, capacity: capacity) { unsafeCasted in
//                unsafeCasted.pointee
//            }
//        }
//    }
//}
