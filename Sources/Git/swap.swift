//
//  File.swift
//  libgit2.swift
//
//  Created by Ky on 2024-11-09.
//

import Foundation



internal func swap<T>(a: inout T, b: inout T) {
    (b, a) = (a, b)
}
