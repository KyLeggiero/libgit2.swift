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

import Either



@available(*, unavailable, renamed: "Atomic32")
public typealias git_atomic32 = Atomic32
@Volatile
public struct Atomic32: AnyStructProtocol {
#if GIT_WIN32
    public var val: CLong
#else
    public var val: CInt
#endif
}



@available(*, unavailable, renamed: "Atomic64")
public typealias git_atomic64 = Atomic64
@Volatile
public struct Atomic64: AnyStructProtocol {
    public var val: __int64_t
}



@available(*, unavailable, renamed: "Mutex")
public typealias git_mutex = Mutex
public typealias Mutex = CUnsignedInt



@globalActor
public final actor Volatile: GlobalActor {
    public static var shared = Volatile()
}



//public typealias git_rwlock = Either<GIT_SRWLOCK, CRITICAL_SECTION>
//
//
//
//public extension git_rwlock {
//    var srwl: GIT_SRWLOCK {
//        get {
//            switch self {
//            case .left(let value):
//                return value
//                
//            case .right(let wrongValue):
//                print("🛑 Attempted to get csec when srwl was stored. I know this is stupid but they're mutually-exclusive. Production code will return a new csec but keep the current srwl value")
//                assertionFailure()
//                return .init()
//            }
//        }
//        set {
//            switch self {
//            case .left(_):
//                self = .left(newValue)
//                
//            case .right(_):
//                print("🛑 Attempted to set csec when srwl was stored. I know this is stupid but they're mutually-exclusive. Production code will automatically discard the existing srwl value and store the new csec value in its place to change this from a srwl to a csec.")
//                assertionFailure()
//                self = .left(newValue)
//            }
//        }
//    }
//    
//    
//    var csec: CRITICAL_SECTION {
//        get {
//            switch self {
//            case .right(let value):
//                return value
//                
//            case .left(let wrongValue):
//                print("🛑 Attempted to get srwl when csec was stored. I know this is stupid but they're mutually-exclusive. Production code will return a new srwl but keep the current csec value")
//                assertionFailure()
//                return .init()
//            }
//        }
//        set {
//            switch self {
//            case .right(_):
//                self = .right(newValue)
//                
//            case .left(_):
//                print("🛑 Attempted to set srwl when csec was stored. I know this is stupid but they're mutually-exclusive. Production code will automatically discard the existing csec value and store the new srwl value in its place to change this from a csec to a srwl.")
//                assertionFailure()
//                self = .right(newValue)
//            }
//        }
//    }
//}
//

public typealias git_rwlock = pthread_rwlock_t
