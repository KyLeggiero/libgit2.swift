//
// errors functionality.swift
//
// Written by Ky on 2024-12-08.
// Copyright waived. No rights reserved.
//
// This file is part of libgit2.swift, distributed under the Fair License.
// For full terms, see the included LICENSE file.
//

import Foundation



public extension GitError {
    // Analogous to `git_error_global_init`
    @MainActor
    @available(*, deprecated, message: "This is likely unnecessary in Swift (seems all it did was deallocate things)")
    static func initialize() async {
        // TODO: Do we need to register on-Task-exit hooks here?
//        tls_key = Git.TlsData.onThreadExit(callback: threadstate_free)
        // TODO: Do we need to register on-shutdown hooks here?
//        await Git.Runtime.registerShutdownHook(git_error_global_shutdown)
    }
    
    
    init<E: Error>(_ anyError: E) {
        if let gitError = anyError as? Self {
            self = gitError
        }
        else if let localizedError = anyError as? LocalizedError {
            self.init(message: localizedError.bestDescription)
        }
        else {
            self.init(message: anyError.localizedDescription)
        }
    }
}



extension GitError: InitializableByOneArgument {
    typealias OtherType = Error
}



internal func mapError<Thrown, Mapped, Returned>(
    newType: Mapped.Type = Mapped.self,
    _ thrower: @autoclosure @Sendable () throws(Thrown) -> Returned)
throws(Mapped) -> Returned
where Thrown: Error,
    Mapped: Error,
    Mapped: InitializableByOneArgument,
    Mapped.OtherType == Thrown,
    Mapped.InitializerError == Never
{
    do {
        return try thrower()
    }
    catch {
        throw Mapped(error)
    }
}



internal func mapError<Thrown, Mapped, Returned>(
    _ thrower: @autoclosure () throws(Thrown) -> Returned,
    _ mapper: (Thrown) -> Mapped)
throws(Mapped) -> Returned
where Thrown: Error,
    Mapped: Error
{
    do {
        return try thrower()
    }
    catch {
        throw mapper(error)
    }
}



internal func mapError<NewError, Returned>(
    _ thrower: @autoclosure () throws -> Returned,
    _ alternative: () -> NewError)
throws(NewError) -> Returned
where NewError: Error
{
    do {
        return try thrower()
    }
    catch {
        throw alternative()
    }
}



//infix operator ?! : NilCoalescingPrecedence
//
//
//
//func ?! <NewError, Returned>(
//    _ thrower: @autoclosure () throws -> Returned,
//    _ alternative: @autoclosure () throws(NewError) -> Void)
//throws(NewError) -> Returned
//where NewError: Error
//{
//    do {
//        return try thrower()
//    }
//    catch {
//        try alternative()
//    }
//}



private extension LocalizedError {
    var bestDescription: String {
        let topDescription = errorDescription ?? localizedDescription
        if let recoverySuggestion {
            return """
                \(topDescription)
                
                \(recoverySuggestion)
                """
        }
        else {
            return topDescription
        }
    }
}



// MARK: - Migrated

@available(*, unavailable, renamed: "GitError.initialize")
public func git_error_global_init() -> CInt { fatalError() }
