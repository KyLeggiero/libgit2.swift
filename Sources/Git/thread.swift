//
// thread.swift
//
// Written by Ky on 2024-11-10.
// Copyright waived. No rights reserved.
//
// This file is part of libgit2.swift, distributed under the Free License.
// For full terms, see the included LICENSE file.
//

import Foundation


@available(*, unavailable, renamed: "Atomic32")
typealias git_atomic32 = Atomic32
@MainActor
public struct Atomic32: Sendable {
#if GIT_WIN32
    var val: CLong
#else
    var val: CInt
#endif
}
