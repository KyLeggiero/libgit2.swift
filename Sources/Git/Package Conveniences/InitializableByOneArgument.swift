//
//  File.swift
//  libgit2.swift
//
//  Created by Ky on 2025-01-10.
//

import Foundation



internal protocol InitializableByOneArgument {
    associatedtype OtherType
    associatedtype InitializerError: Error = Never
    init(_ otherType: OtherType) throws(InitializerError)
}
