//
//  File.swift
//  libgit2.swift
//
//  Created by Ky on 2025-01-20.
//

import Foundation



// MARK: - Migration

@available(*, unavailable, renamed: "String", message: "All of the functionality of `git_buf` should be available in `String` or `Data`. Choose which best suits your needs.")
public typealias git_buf = String
