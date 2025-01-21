//
// filter.swift
//
// Written by Ky on 2024-12-31.
// Copyright waived. No rights reserved.
//
// This file is part of libgit2.swift, distributed under the Fair License.
// For full terms, see the included LICENSE file.
//

import Foundation



// MARK: - Primary

/**
 * Filter structure used to register custom filters.
 *
 * To associate extra data with a filter, allocate extra data and put the
 * `git_filter` struct at the start of your data buffer, then cast the
 * `self` pointer to your larger structure when your callback is invoked.
 */
public struct Filter: AnyStructProtocol {
    
    /** The `version` field should be set to `GIT_FILTER_VERSION`. */
    public var version: CUnsignedInt

     /**
     * A whitespace-separated list of attribute names to check for this
     * filter (e.g. "eol crlf text").  If the attribute name is bare, it
     * will be simply loaded and passed to the `check` callback.  If it
     * has a value (i.e. "name=value"), the attribute must match that
     * value for the filter to be applied.  The value may be a wildcard
     * (eg, "name=*"), in which case the filter will be invoked for any
     * value for the given attribute name.  See the attribute parameter
     * of the `check` callback for the attribute value that was specified.
     */
    public let attributes: String

    /** Called when the filter is first used for any file. */
    public var initialize: InitFunction?

    /** Called when the filter is removed or unregistered from the system. */
    public var shutdown: ShutdownFunction

    /**
     * Called to determine whether the filter should be invoked for a
     * given file.  If this function returns `GIT_PASSTHROUGH` then the
     * `stream` or `apply` functions will not be invoked and the
     * contents will be passed through unmodified.
     */
    public var _checkFunction_static: CheckFunction
    
    public var reserved: AnyTypeProtocol? = nil
    
    /**
     * Called to apply the filter, this function will provide a
     * `git_writestream` that will the original data will be
     * written to; with that data, the `git_writestream` will then
     * perform the filter translation and stream the filtered data
     * out to the `next` location.
     */
    public var _streamFunction_static: StreamFunction

    /** Called when the system is done filtering for a file. */
    public var _cleanupFunction_static: CleanupFunction
    
    
    init(version: CUnsignedInt,
         attributes: String,
         initialize: InitFunction? = nil,
         shutdown: @escaping ShutdownFunction,
         check: @escaping CheckFunction,
         stream: @escaping StreamFunction,
         cleanup: @escaping CleanupFunction)
    {
        self.version = version
        self.attributes = attributes
        self.initialize = initialize
        self.shutdown = shutdown
        self._checkFunction_static = check
        self._streamFunction_static = stream
        self._cleanupFunction_static = cleanup
    }
    
    
    public static var version: CUnsignedInt { 1 }
}



public extension Filter {
    
    /// Called to determine whether the filter should be invoked for a given file.
    /// 
    /// If this function throws ``GitError/Code/userConfiguredCallbackRefusedToAct`` then the `stream` or `apply` functions will not be invoked and the contents will be passed through unmodified.
    ///
    /// - Parameters:
    ///   - source:          <#source description#>
    ///   - attributeValues: <#attributeValues description#>
    ///
    /// - Returns: <#Return description#>
    ///
    /// - Throws: <#Error description#>
    func check(source: Source, attributeValues: inout String?) throws(GitError) -> AnyTypeProtocol? {
        try _checkFunction_static(self)(source, &attributeValues)
    }
    
    
    /// Performs the data filtering.
    /// 
    /// Filters data in a streaming manner. This function will provide a ``Writestream`` that the original data will be written to;
    /// with that data, the ``Writestream`` will then perform the filter translation and stream the filtered data out to the `next` location.
    ///
    /// - Parameters:
    ///   - source:  <#source description#>
    ///   - payload: <#payload description#>
    ///   - next:    <#next description#>
    ///
    /// - Returns: <#Return description#>
    ///
    /// - Throws: <#Error description#>
    func stream(source: Source, payload: inout AnyTypeProtocol?, next: Writestream) throws(GitError) -> Writestream {
        try _streamFunction_static(self)(source, payload, next)
    }
    
    
    /// Callback to clean up after filtering has been applied
    ///
    /// Invoked after the filter has been applied.  If the `check`, `apply`, or `stream` functions allocated a `payload` to keep per-source filter state, use this to free that payload and release resources as required.
    ///
    /// - Returns: <#Return description#>
    func cleanup() -> AnyTypeProtocol? {
        _cleanupFunction_static(self)
    }
}



// MARK: - Supporting types

public extension Filter {
    
    /**
     * A filter source represents a file/blob to be processed
     */
    struct Source: AnyStructProtocol {
        public var repo: Repository
        public let path: String
        public var oid: Oid?  // zero/nil if unknown (which is likely)
        public var filemode: __uint16_t? // zero/nil if unknown
        public var mode: Filter.Mode
        public var options: Filter.Options
    }
    
    
    
    /**
     * Filters are applied in one of two directions: smudging - which is
     * exporting a file from the Git object database to the working directory,
     * and cleaning - which is importing a file from the working directory to
     * the Git object database.  These values control which direction of
     * change is being applied.
     */
    enum Mode: CInt, AnyEnumProtocol {
        case toWorktree = 0
        case toOdb = 1
        
        public static let smudge: Self = toWorktree
        public static let clean: Self = toOdb
    }
    
    
    
    /**
     * Filtering options
     */
    struct Options: AnyStructProtocol {
        public var version: CUnsignedInt

        /** See `git_filter_flag_t` above */
        public let flags: Flag

        public var reserved: AnyTypeProtocol? = nil

        /**
         * The commit to load attributes from, when
         * `GIT_FILTER_ATTRIBUTES_FROM_COMMIT` is specified.
         */
        public var attributeLodingCommitId: Oid
    }
    
    
    
    /**
     * Filter option flags.
     */
    enum Flag: CUnsignedInt, AutoOptionSet, AnyEnumProtocol {
        case __empty = 0

        /** Don't error for `safecrlf` violations, allow them to continue. */
        case allowUnsafe = 0b0001 // (1u << 0)

        /** Don't load `/etc/gitattributes` (or the system equivalent) */
        case noSystemAttributes = 0b0010 // (1u << 1)

        /** Load attributes from `.gitattributes` in the root of HEAD */
        case attributesFromHead = 0b0100 // (1u << 2)

        /**
         * Load attributes from `.gitattributes` in a given commit.
         * This can only be specified in a `git_filter_options`.
         */
        case attributesFromCommit = 0b1000 // (1u << 3)
    }
}



// MARK: - Function Types

public extension Filter {
    
    /**
     * Initialize callback on filter
     *
     * Specified as `filter.initialize`, this is an optional callback invoked
     * before a filter is first used.  It will be called once at most.
     *
     * If non-NULL, the filter's `initialize` callback will be invoked right
     * before the first use of the filter, so you can defer expensive
     * initialization operations (in case libgit2 is being used in a way that
     * doesn't need the filter).
     */
    typealias InitFunction = @Sendable () throws(GitError) -> Filter
    
    
    
    /**
     * Shutdown callback on filter
     *
     * Specified as `filter.shutdown`, this is an optional callback invoked
     * when the filter is unregistered or when libgit2 is shutting down.  It
     * will be called once at most and should release resources as needed.
     * This may be called even if the `initialize` callback was not made.
     *
     * Typically this function will free the `git_filter` object itself.
     */
    typealias ShutdownFunction = @Sendable () -> Filter
    
    
    
    /**
     * Callback to decide if a given source needs this filter
     *
     * Specified as `filter.check`, this is an optional callback that checks
     * if filtering is needed for a given source.
     *
     * It should return 0 if the filter should be applied (i.e. success),
     * GIT_PASSTHROUGH if the filter should not be applied, or an error code
     * to fail out of the filter processing pipeline and return to the caller.
     *
     * The `attr_values` will be set to the values of any attributes given in
     * the filter definition.  See `git_filter` below for more detail.
     *
     * The `payload` will be a pointer to a reference payload for the filter.
     * This will start as NULL, but `check` can assign to this pointer for
     * later use by the `stream` callback.  Note that the value should be heap
     * allocated (not stack), so that it doesn't go away before the `stream`
     * callback can use it.  If a filter allocates and assigns a value to the
     * `payload`, it will need a `cleanup` callback to free the payload.
     */
    typealias CheckFunction = @Sendable (_ `self`: Filter) -> _CheckFunction_Method
    
    /// The signature of the check function when it's a method on a type (rather than being generated with a `Filter` explicitly passed as `self`)
    ///
    /// This is returned by a ``CheckFunction``
    typealias _CheckFunction_Method = @Sendable (
        _ src: Filter.Source,
        _ attr_values: inout String?) throws(GitError) -> AnyTypeProtocol?
    
    
    
    /**
     * Callback to perform the data filtering.
     *
     * Specified as `filter.stream`, this is a callback that filters data
     * in a streaming manner.  This function will provide a
     * `git_writestream` that will the original data will be written to;
     * with that data, the `git_writestream` will then perform the filter
     * translation and stream the filtered data out to the `next` location.
     */
    typealias StreamFunction = @Sendable (_ `self`: Filter) -> _StreamFunction_Method
    
    /// The signature of the stream function when it's a method on a type (rather than being generated with a `Filter` explicitly passed as `self`)
    ///
    /// This is returned by a ``StreamFunction``
    typealias _StreamFunction_Method = @Sendable (
        _ src: Filter.Source,
        _ payload: AnyTypeProtocol?,
        _ next: Writestream)
    throws(GitError) -> Writestream
    
    
    
    /**
     * Callback to clean up after filtering has been applied
     *
     * Specified as `filter.cleanup`, this is an optional callback invoked
     * after the filter has been applied.  If the `check`, `apply`, or
     * `stream` callbacks allocated a `payload` to keep per-source filter
     * state, use this callback to free that payload and release resources
     * as required.
     */
    typealias CleanupFunction = @Sendable (_ `self`: Filter) -> _CleanupFunction_Method
    
    /// The signature of the cleanup function when it's a method on a type (rather than being generated with a `Filter` explicitly passed as `self`)
    ///
    /// This is returned by a ``CleanupFunction``
    typealias _CleanupFunction_Method = @Sendable () -> AnyTypeProtocol?
}



// MARK: - Migration

@available(*, unavailable, renamed: "Filter")
public typealias git_filter = Filter

@available(*, unavailable, renamed: "Filter.InitFunction")
public typealias git_filter_init_fn = Filter.InitFunction

@available(*, unavailable, renamed: "Filter.ShutdownFunction")
public typealias git_filter_shutdown_fn = Filter.ShutdownFunction

@available(*, unavailable, renamed: "Filter.CheckFunction")
public typealias git_filter_check_fn = Filter.CheckFunction

@available(*, unavailable, renamed: "Filter.StreamFunction")
public typealias git_filter_stream_fn = Filter.StreamFunction

@available(*, unavailable, renamed: "Filter.CleanupFunction")
public typealias git_filter_cleanup_fn = Filter.CleanupFunction

@available(*, unavailable, renamed: "Filter.version")
public var GIT_FILTER_VERSION: CUnsignedInt { fatalError() }

@available(*, unavailable, message: "Unnecessary in Swift")
public func git_filter_free(_: inout git_filter) { fatalError() }



@available(*, unavailable, renamed: "Filter.Source")
public typealias git_filter_source = Filter.Source



@available(*, unavailable, renamed: "Filter.Options")
public typealias git_filter_options = Filter.Options

@available(*, unavailable)
public extension Filter.Options {
    @available(*, unavailable, renamed: "attributeLodingCommitId")
    var attr_commit_id: git_oid { fatalError() }
}



@available(*, unavailable, renamed: "Filter.Mode")
public typealias git_filter_mode_t = Filter.Mode

@available(*, unavailable, renamed: "Filter.Mode.toWorktree")
public var GIT_FILTER_TO_WORKTREE: Filter.Mode { fatalError() }

@available(*, unavailable, renamed: "Filter.Mode.smudge")
public var GIT_FILTER_SMUDGE: Filter.Mode { fatalError() }

@available(*, unavailable, renamed: "Filter.Mode.toOdb")
public var GIT_FILTER_TO_ODB: Filter.Mode { fatalError() }

@available(*, unavailable, renamed: "Filter.Mode.clean")
public var GIT_FILTER_CLEAN: Filter.Mode { fatalError() }


@available(*, unavailable, renamed: "Filter.Flag()")
public var GIT_FILTER_DEFAULT: Filter.Flag { fatalError() }

@available(*, unavailable, renamed: "Filter.Flag.allowUnsafe")
public var GIT_FILTER_ALLOW_UNSAFE: Filter.Flag { fatalError() }

@available(*, unavailable, renamed: "Filter.Flag.noSystemAttributes")
public var GIT_FILTER_NO_SYSTEM_ATTRIBUTES: Filter.Flag { fatalError() }

@available(*, unavailable, renamed: "Filter.Flag.attributesFromHead")
public var GIT_FILTER_ATTRIBUTES_FROM_HEAD: Filter.Flag { fatalError() }

@available(*, unavailable, renamed: "Filter.Flag.attributesFromCommit")
public var GIT_FILTER_ATTRIBUTES_FROM_COMMIT: Filter.Flag { fatalError() }
