//
// errors.swift
//
// Written by Ky on 2024-11-09.
// Copyright waived. No rights reserved.
//
// This file is part of libgit2.swift, distributed under the Fair License.
// For full terms, see the included LICENSE file.
//

import Foundation



/**
 * Structure to store extra details of the last error that occurred.
 *
 * This is kept on a per-thread basis if GIT_THREADS was defined when the
 * library was build, otherwise one is kept globally for the library
 */
public struct GitError: Error, AnyStructProtocol {
    let message: String?
    let kind: Kind?
    var code: Code?
    let systemError: CInt?
    let cause: (any Error)?
    
    
    init(message: String? = nil,
         kind: Kind? = nil,
         code: Code? = .__generic,
         systemError: CInt? = nil,
         cause: (any Error)? = nil)
    {
        self.message = message
        self.kind = kind
        self.code = code
        self.systemError = systemError
        self.cause = cause
    }
}



// TODO: LocalizedError



public extension GitError {
    
    @available(*, deprecated, message: "Please describe the error in some way...")
    init() {
        self = .generic
    }
    
    
    @available(*, deprecated, message: "Please use a semantic error instead...")
    static var generic: Self { .init() }
}



public extension GitError.Code {
    @available(*, message: "Please use a semantic error instead...")
    static var generic: Self { .__generic }
}



//public extension GitError.Kind {
//    @available(*, deprecated, message: "Please use a semantic error instead...")
//    static var generic: Self { .__generic }
//}




public extension GitError {
    /** Error classes */
    enum Kind: Int, Error, AnyEnumProtocol {
//        case __generic  = -1
        
        case noMemory   = 1
        case os         = 2
        case invalid    = 3
        case reference  = 4
        case zlib       = 5
        case repository = 6
        case config     = 7
        case regex      = 8
        case odb        = 9
        case index      = 10
        case object     = 11
        case net        = 12
        case tag        = 13
        case tree       = 14
        case indexer    = 15
        case ssl        = 16
        case submodule  = 17
        case thread     = 18
        case stash      = 19
        case checkout   = 20
        case fetchHead  = 21
        case merge      = 22
        case ssh        = 23
        case filter     = 24
        case revert     = 25
        case callback   = 26
        case cherrypick = 27
        case describe   = 28
        case rebase     = 29
        case filesystem = 30
        case patch      = 31
        case worktree   = 32
        case sha        = 33
        case http       = 34
        case `internal` = 35
        case grafts     = 36
    }
    
    
    /** Generic return codes */
    enum Code: Int, AnyEnumProtocol {
        
        /** Generic error */
        case __generic                                        = -1
        
        /** Requested object could not be found */
        case objectNotFound                                   = -3
        
        /** Object exists preventing operation */
        case objectAlreadyExists                              = -4
        
        /** More than one object matches */
        case moreThanOneObjectMatches                         = -5
        
        /** Output buffer too short to hold data */
        case outputBufferTooShort                             = -6

        
        /**
         * GIT_EUSER is a special error that is never generated by libgit2
         * code.  You can return it from a callback (e.g to stop an iteration)
         * to know that it was generated by the callback and not by libgit2.
         */
        case custom                                           = -7

        
        /** Operation not allowed on bare repository */
        case operaationNotAllowed_bareRepo                    =  -8
        
        /** HEAD refers to branch with no commits */
        case noCommitsOnHeadBranch                            =  -9
        
        /** Merge in progress prevented operation */
        case mergeInProgress                                  = -10
        
        /** Reference was not fast-forwardable */
        case referenceDoesNotSupportFastForward               = -11
        
        /** Name/ref spec was not in a valid format */
        case badRefspecFormat                                 = -12
        
        /** Checkout conflicts prevented operation */
        case conflict                                         = -13
        
        /** Lock file prevented operation */
        case locked                                           = -14
        
        /** Reference value does not match expected */
        case MODIFIED                                         = -15
        
        /** Authentication error */
        case authenticationFailed                             = -16
        
        /** Server certificate is invalid */
        case invalidServerCertificate                         = -17
        
        /** Patch/merge has already been applied */
        case patchOrMergeAlreadyApplied                       = -18
        
        /** The requested peel operation is not possible */
        case peelOperationNotPossible                         = -19
        
        /** Unexpected EOF */
        case unexpectedEof                                    = -20
        
        /** Invalid operation or input */
        case invalidOperationOrInput                          = -21
        
        /** Uncommitted changes in index prevented operation */
        case uncommittedChangesPreventOperation               = -22
        
        /** The operation is not valid for a directory */
        case directoryDoesNotSupportThisOperation             = -23
        
        /** A merge conflict exists and cannot continue */
        case mergeConflict                                    = -24

        
        /** A user-configured callback refused to act */
        case userConfiguredCallbackRefusedToAct               = -30
        
        /** Signals end of iteration with iterator */
        case iterationComplete                                = -31
        
        /** Internal only */
        case __internal__retry                                = -32
        
        /** Hashsum mismatch in object */
        case hashMismatch                                     = -33
        
        /** Unsaved changes in the index would be overwritten */
        case unsavedChangesCouldNotBeOverwritten              = -34
        
        /** Patch application failed */
        case couldNotApplyPatch                               = -35
        
        /** The object is not owned by the current user */
        case objectNotOwnedByUser                             = -36
        
        /** The operation timed out */
        case operationTimedOut                                = -37
        
        /** There were no changes */
        case noChanges                                        = -38
        
        /** An option is not supported */
        case unsupportedOperation                             = -39
        
        /** The subject is read-only */
        case readOnly                                         = -40
    }
}




public extension GitError {
    struct ThreadState: AnyStructProtocol {
        
        // Why does this exist when `git_error` has `message` lol???
        // Like yea one is `char *` from git2 and one is `git_str` from libgit2, but seriously that kinda duplication
        // is likely unnecessary. Can't wait to see if we can eliminate some of that.
        //
        // - Ash, 2024-12-09
        /** The error message buffer. */
        var message: String
        
        /** Error information, set by `git_error_set` and friends. */
        var error: GitError
        
        /**
         * The last error to occur; points to the error member of this
         * struct _or_ a static error.
         */
        var last: GitError?
    }
}



// MARK: - Migration

@available(*, unavailable, renamed: "GitError")
public typealias git_error = GitError

@available(*, unavailable, renamed: "GitError.ThreadState")
public typealias error_threadstate = GitError.ThreadState


// MARK: `git_error_t`

@available(*, unavailable, renamed: "GitError.Kind")
public typealias git_error_t = GitError.Kind


@available(*, unavailable, renamed: "nil")
public var GIT_ERROR_NONE: GitError.Kind? { nil }

@available(*, unavailable, renamed: "GitError.Kind.noMemory")
public var GIT_ERROR_NOMEMORY: GitError.Kind { .noMemory }

@available(*, unavailable, renamed: "GitError.Kind.os")
public var GIT_ERROR_OS: GitError.Kind { .os }

@available(*, unavailable, renamed: "GitError.Kind.invalid")
public var GIT_ERROR_INVALID: GitError.Kind { .invalid }

@available(*, unavailable, renamed: "GitError.Kind.reference")
public var GIT_ERROR_REFERENCE: GitError.Kind { .reference }

@available(*, unavailable, renamed: "GitError.Kind.zlib")
public var GIT_ERROR_ZLIB: GitError.Kind { .zlib }

@available(*, unavailable, renamed: "GitError.Kind.repository")
public var GIT_ERROR_REPOSITORY: GitError.Kind { .repository }

@available(*, unavailable, renamed: "GitError.Kind.config")
public var GIT_ERROR_CONFIG: GitError.Kind { .config }

@available(*, unavailable, renamed: "GitError.Kind.regex")
public var GIT_ERROR_REGEX: GitError.Kind { .regex }

@available(*, unavailable, renamed: "GitError.Kind.odb")
public var GIT_ERROR_ODB: GitError.Kind { .odb }

@available(*, unavailable, renamed: "GitError.Kind.index")
public var GIT_ERROR_INDEX: GitError.Kind { .index }

@available(*, unavailable, renamed: "GitError.Kind.object")
public var GIT_ERROR_OBJECT: GitError.Kind { .object }

@available(*, unavailable, renamed: "GitError.Kind.net")
public var GIT_ERROR_NET: GitError.Kind { .net }

@available(*, unavailable, renamed: "GitError.Kind.tag")
public var GIT_ERROR_TAG: GitError.Kind { .tag }

@available(*, unavailable, renamed: "GitError.Kind.tree")
public var GIT_ERROR_TREE: GitError.Kind { .tree }

@available(*, unavailable, renamed: "GitError.Kind.indexer")
public var GIT_ERROR_INDEXER: GitError.Kind { .indexer }

@available(*, unavailable, renamed: "GitError.Kind.ssl")
public var GIT_ERROR_SSL: GitError.Kind { .ssl }

@available(*, unavailable, renamed: "GitError.Kind.submodule")
public var GIT_ERROR_SUBMODULE: GitError.Kind { .submodule }

@available(*, unavailable, renamed: "GitError.Kind.thread")
public var GIT_ERROR_THREAD: GitError.Kind { .thread }

@available(*, unavailable, renamed: "GitError.Kind.stash")
public var GIT_ERROR_STASH: GitError.Kind { .stash }

@available(*, unavailable, renamed: "GitError.Kind.checkout")
public var GIT_ERROR_CHECKOUT: GitError.Kind { .checkout }

@available(*, unavailable, renamed: "GitError.Kind.fetchHead")
public var GIT_ERROR_FETCHHEAD: GitError.Kind { .fetchHead }

@available(*, unavailable, renamed: "GitError.Kind.merge")
public var GIT_ERROR_MERGE: GitError.Kind { .merge }

@available(*, unavailable, renamed: "GitError.Kind.ssh")
public var GIT_ERROR_SSH: GitError.Kind { .ssh }

@available(*, unavailable, renamed: "GitError.Kind.filter")
public var GIT_ERROR_FILTER: GitError.Kind { .filter }

@available(*, unavailable, renamed: "GitError.Kind.revert")
public var GIT_ERROR_REVERT: GitError.Kind { .revert }

@available(*, unavailable, renamed: "GitError.Kind.callback")
public var GIT_ERROR_CALLBACK: GitError.Kind { .callback }

@available(*, unavailable, renamed: "GitError.Kind.cherrypick")
public var GIT_ERROR_CHERRYPICK: GitError.Kind { .cherrypick }

@available(*, unavailable, renamed: "GitError.Kind.describe")
public var GIT_ERROR_DESCRIBE: GitError.Kind { .describe }

@available(*, unavailable, renamed: "GitError.Kind.rebase")
public var GIT_ERROR_REBASE: GitError.Kind { .rebase }

@available(*, unavailable, renamed: "GitError.Kind.filesystem")
public var GIT_ERROR_FILESYSTEM: GitError.Kind { .filesystem }

@available(*, unavailable, renamed: "GitError.Kind.patch")
public var GIT_ERROR_PATCH: GitError.Kind { .patch }

@available(*, unavailable, renamed: "GitError.Kind.worktree")
public var GIT_ERROR_WORKTREE: GitError.Kind { .worktree }

@available(*, unavailable, renamed: "GitError.Kind.sha")
public var GIT_ERROR_SHA: GitError.Kind { .sha }

@available(*, unavailable, renamed: "GitError.Kind.http")
public var GIT_ERROR_HTTP: GitError.Kind { .http }

@available(*, unavailable, renamed: "GitError.Kind.internal")
public var GIT_ERROR_INTERNAL: GitError.Kind { .internal }

@available(*, unavailable, renamed: "GitError.Kind.grafts")
public var GIT_ERROR_GRAFTS: GitError.Kind { .grafts }


// MARK: `git_error_code`

@available(*, unavailable, renamed: "GitError.Code")
public typealias git_error_code = GitError.Code


@available(*, unavailable, renamed: "nil")
public var GIT_OK: GitError.Code? { nil }

@available(*, unavailable, renamed: "GitError.Code.generic")
@available(*, deprecated, renamed: "GitError.Code.generic")
public var GIT_ERROR: GitError.Code { .generic }

@available(*, unavailable, renamed: "GitError.Code.objectNotFound")
public var GIT_ENOTFOUND: GitError.Code { .objectNotFound }

@available(*, unavailable, renamed: "GitError.Code.objectAlreadyExists")
public var GIT_EEXISTS: GitError.Code { .objectAlreadyExists }

@available(*, unavailable, renamed: "GitError.Code.moreThanOneObjectMatches")
public var GIT_EAMBIGUOUS: GitError.Code { .moreThanOneObjectMatches }

@available(*, unavailable, renamed: "GitError.Code.outputBufferTooShort")
public var GIT_EBUFS: GitError.Code { .outputBufferTooShort }

@available(*, unavailable, renamed: "GitError.Code.custom")
public var GIT_EUSER: GitError.Code { .custom }

@available(*, unavailable, renamed: "GitError.Code.operaationNotAllowed_bareRepo")
public var GIT_EBAREREPO: GitError.Code { .operaationNotAllowed_bareRepo }

@available(*, unavailable, renamed: "GitError.Code.noCommitsOnHeadBranch")
public var GIT_EUNBORNBRANCH: GitError.Code { .noCommitsOnHeadBranch }

@available(*, unavailable, renamed: "GitError.Code.mergeInProgress")
public var GIT_EUNMERGED: GitError.Code { .mergeInProgress }

@available(*, unavailable, renamed: "GitError.Code.referenceDoesNotSupportFastForward")
public var GIT_ENONFASTFORWARD: GitError.Code { .referenceDoesNotSupportFastForward }

@available(*, unavailable, renamed: "GitError.Code.badRefspecFormat")
public var GIT_EINVALIDSPEC: GitError.Code { .badRefspecFormat }

@available(*, unavailable, renamed: "GitError.Code.conflict")
public var GIT_ECONFLICT: GitError.Code { .conflict }

@available(*, unavailable, renamed: "GitError.Code.locked")
public var GIT_ELOCKED: GitError.Code { .locked }

@available(*, unavailable, renamed: "GitError.Code.MODIFIED")
public var GIT_EMODIFIED: GitError.Code { .MODIFIED }

@available(*, unavailable, renamed: "GitError.Code.authenticationFailed")
public var GIT_EAUTH: GitError.Code { .authenticationFailed }

@available(*, unavailable, renamed: "GitError.Code.invalidServerCertificate")
public var GIT_ECERTIFICATE: GitError.Code { .invalidServerCertificate }

@available(*, unavailable, renamed: "GitError.Code.patchOrMergeAlreadyApplied")
public var GIT_EAPPLIED: GitError.Code { .patchOrMergeAlreadyApplied }

@available(*, unavailable, renamed: "GitError.Code.peelOperationNotPossible")
public var GIT_EPEEL: GitError.Code { .peelOperationNotPossible }

@available(*, unavailable, renamed: "GitError.Code.unexpectedEof")
public var GIT_EEOF: GitError.Code { .unexpectedEof }

@available(*, unavailable, renamed: "GitError.Code.invalidOperationOrInput")
public var GIT_EINVALID: GitError.Code { .invalidOperationOrInput }

@available(*, unavailable, renamed: "GitError.Code.uncommittedChangesPreventOperation")
public var GIT_EUNCOMMITTED: GitError.Code { .uncommittedChangesPreventOperation }

@available(*, unavailable, renamed: "GitError.Code.directoryDoesNotSupportThisOperation")
public var GIT_EDIRECTORY: GitError.Code { .directoryDoesNotSupportThisOperation }

@available(*, unavailable, renamed: "GitError.Code.mergeConflict")
public var GIT_EMERGECONFLICT: GitError.Code { .mergeConflict }

@available(*, unavailable, renamed: "GitError.Code.userConfiguredCallbackRefusedToAct")
public var GIT_PASSTHROUGH: GitError.Code { .userConfiguredCallbackRefusedToAct }

@available(*, unavailable, renamed: "GitError.Code.iterationComplete")
public var GIT_TEROVER: GitError.Code { .iterationComplete }

@available(*, unavailable, renamed: "GitError.Code.__internal__retry")
public var GIT_EETRY: GitError.Code { .__internal__retry }

@available(*, unavailable, renamed: "GitError.Code.hashMismatch")
public var GIT_EMISMATCH: GitError.Code { .hashMismatch }

@available(*, unavailable, renamed: "GitError.Code.unsavedChangesCouldNotBeOverwritten")
public var GIT_EINDEXDIRTY: GitError.Code { .unsavedChangesCouldNotBeOverwritten }

@available(*, unavailable, renamed: "GitError.Code.couldNotApplyPatch")
public var GIT_EAPPLYFAIL: GitError.Code { .couldNotApplyPatch }

@available(*, unavailable, renamed: "GitError.Code.objectNotOwnedByUser")
public var GIT_EOWNER: GitError.Code { .objectNotOwnedByUser }

@available(*, unavailable, renamed: "GitError.Code.operationTimedOut")
public var GIT_EIMEOUT: GitError.Code { .operationTimedOut }

@available(*, unavailable, renamed: "GitError.Code.noChanges")
public var GIT_UNCHANGED: GitError.Code { .noChanges }

@available(*, unavailable, renamed: "GitError.Code.unsupportedOperation")
public var GIT_NOTSUPPORTED: GitError.Code { .unsupportedOperation }

@available(*, unavailable, renamed: "GitError.Code.readOnly")
public var GIT_READONLY: GitError.Code { .readOnly }
