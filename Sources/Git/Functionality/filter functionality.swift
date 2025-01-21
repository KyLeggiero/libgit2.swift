//
// filter functionality.swift
//
// Written by Ky on 2024-12-07.
// Copyright waived. No rights reserved.
//
// This file is part of libgit2.swift, distributed under the Fair License.
// For full terms, see the included LICENSE file.
//

import Foundation



public extension Filter {
    
    @MainActor
    // Analogous to `git_filter_global_init`
    static func initialize() async throws(GitError) {
        
        await Registry.SyncLock.run {
            Registry.shared = .init(filters: SelfSortingArray(comparingBy: \.priority))
        }
        
        let crlf: Filter
        
        do {
            crlf = try Filter.crlf()
        }
        catch {
            throw .generic
        }
        
        try filter_registry_insert(GIT_FILTER_CRLF, crlf, GIT_FILTER_CRLF_PRIORITY)
        
        do {
            let ident = try git_ident_filter_new()
        }
        catch {
            throw .generic
        }
        try filter_registry_insert(GIT_FILTER_IDENT, ident, GIT_FILTER_IDENT_PRIORITY)
        
        try git_runtime_shutdown_register(git_filter_global_shutdown)
        
        // The above code translates this original C code:
        //
        //     git_filter *crlf = NULL, *ident = NULL;
        //     int error = 0;
        //
        //     if (git_rwlock_init(&filter_registry.lock) < 0)
        //         return -1;
        //
        //     if ((error = git_vector_init(&filter_registry.filters, 2,
        //         filter_def_priority_cmp)) < 0)
        //         goto done;
        //
        //     if ((crlf = git_crlf_filter_new()) == NULL ||
        //         filter_registry_insert(
        //             GIT_FILTER_CRLF, crlf, GIT_FILTER_CRLF_PRIORITY) < 0 ||
        //         (ident = git_ident_filter_new()) == NULL ||
        //         filter_registry_insert(
        //             GIT_FILTER_IDENT, ident, GIT_FILTER_IDENT_PRIORITY) < 0)
        //         error = -1;
        //
        //     if (!error)
        //         error = git_runtime_shutdown_register(git_filter_global_shutdown);
        //
        // done:
        //     if (error) {
        //         git_filter_free(crlf);
        //         git_filter_free(ident);
        //     }
        //
        //     return error;
    }
}



private extension Filter {
    // Analogous to `filter_def_priority_cmp`
    @inline(__always)
    static func filterDefinitionPriorityCompare(a: git_filter_def, b: git_filter_def) -> ComparisonResult
    {
        ComparisonResult(a, b, by: \.priority)
    }
}



private struct git_filter_def {
    var filter_name: String
    var filter: Filter
    var priority: CInt
    var initialized: CInt
    var nattrs: size_t
    var nmatches: size_t
    var attrdata: String
    let attrs: String
}



// MARK: - Registry

private extension Filter {
    struct Registry: AnyStructProtocol {
        
        @SyncLock
        var filters: SelfSortingArray<git_filter_def>
        
        @SyncLock
        init(filters: SelfSortingArray<git_filter_def>) {
            self.filters = filters
        }
    }
}



private extension Filter.Registry {
    @globalActor
    final actor SyncLock: GlobalActor {
        public static var shared = Volatile()
        
        @SyncLock
        static func run<Value>(_ block: @SyncLock () -> Value) -> Value {
            block()
        }
        
        
        @SyncLock
        static func run<Value>(_ block: @SyncLock () throws(GitError) -> Value) throws(GitError) -> Value {
            try block()
        }
        
        
        @SyncLock
        static func run<Value>(_ block: @SyncLock () async -> Value) async -> Value {
            await block()
        }
        
        
        @SyncLock
        static func run<Value>(_ block: @SyncLock () async throws(GitError) -> Value) async throws(GitError) -> Value {
            try await block()
        }
    }
}




private extension Filter.Registry {
    @SyncLock
    static var shared = Self(filters: .init())
}



public extension Filter {
    // Analogous to `git_crlf_filter_new`
    static func crlf() -> Self {
        Self.init(
            version: GIT_FILTER_VERSION,
            attributes: "crlf eol text",
            initialize: nil,
            shutdown: git_filter_free,
            check: crlf_check,
            stream: crlf_stream,
            cleanup: crlf_cleanup)
    }
}



private extension Filter {
    func crlf_check(
        src: Source,
        attr_values: inout String?)
    throws(GitError) -> AnyTypeProtocol?
    {
        let ca = try convert_attrs(attr_values: &attr_values, src: src)
        
        guard .binary != ca.crlf_action else {
            throw .init(code: .userConfiguredCallbackRefusedToAct)
        }
        
        return ca
    }
    
    
    @Sendable
    func crlf_stream(
        src: Source,
        payload: AnyTypeProtocol?,
        next: Writestream)
    throws(GitError) -> Writestream
    {
        return git_filter_buffered_stream_new(crlf_apply, nil, payload, src, next);
    }
    
    
    func crlf_cleanup() -> AnyTypeProtocol? {
        payload = nil
    }
    
    
    
    enum Crlf: AnyEnumProtocol {
        case binary
        case text
        case textInput
        case textCrlf
        case auto
        case autoInput
        case autoCrlf
    }
    
    
    
    struct buffered_stream: AnyStructProtocol {
        var parent: Writestream
        var filter: Filter
        var write_fn: WriteFunction
        var legacy_write_fn: LegacyWriteFunction
        let source: Filter.Source
        var payload: AnyTypeProtocol?
        var input: String
        var temp_buf: String
        var output: String
        var target: Writestream
    }
}

public typealias WriteFunction = @Sendable (_: Filter, _: AnyTypeProtocol?, _: String, _: String, _: Filter.Source) throws(GitError) -> Void
public typealias LegacyWriteFunction = WriteFunction

public extension Writestream {
    
    static func filterBufferedStream(
        filter: Filter,
        writeFunction: WriteFunction,
        temporaryBuffer: String,
        payload: inout AnyTypeProtocol,
        source: Filter.Source,
        target: Writestream)
    -> Writestream
    {
        let buffered_stream: buffered_stream = git__calloc(1, sizeof(struct buffered_stream));
        GIT_ERROR_CHECK_ALLOC(buffered_stream);

        buffered_stream->parent.write = buffered_stream_write;
        buffered_stream->parent.close = buffered_stream_close;
        buffered_stream->parent.free = buffered_stream_free;
        buffered_stream->filter = filter;
        buffered_stream->write_fn = write_fn;
        buffered_stream->output = temp_buf ? temp_buf : &buffered_stream->temp_buf;
        buffered_stream->payload = payload;
        buffered_stream->source = source;
        buffered_stream->target = target;

        if (temp_buf)
            git_str_clear(temp_buf);

        *out = (git_writestream *)buffered_stream;
        return 0
    }
}



private struct crlf_attrs: AnyStructProtocol {
    /** the .gitattributes setting */
    var attr_action: CInt = .init()
    
    /** the core.autocrlf setting */
    var crlf_action: Filter.Crlf? = .none
    
    var auto_crlf: CInt = .init()
    var safe_crlf: CInt = .init()
    var core_eol: CInt = .init()
}



private func convert_attrs(
//    ca: crlf_attrs,
    attr_values: inout String?,
    src: Filter.Source)
throws(GitError) -> crlf_attrs
{
//    memset(ca, 0, size(of: crlf_attrs.self))
    var ca = crlf_attrs()

    try git_repository__configmap_lookup(
        ca.auto_crlf,
        git_filter_source_repo(src), GIT_CONFIGMAP_AUTO_CRLF)
    
    try git_repository__configmap_lookup(
        &ca.safe_crlf,
        git_filter_source_repo(src), GIT_CONFIGMAP_SAFE_CRLF)
    
    try git_repository__configmap_lookup(
        &ca.core_eol,
        git_filter_source_repo(src), GIT_CONFIGMAP_EOL)

    /* downgrade FAIL to WARN if ALLOW_UNSAFE option is used */
    if (0 != (git_filter_source_flags(src) & GIT_FILTER_ALLOW_UNSAFE),
        ca.safe_crlf == GIT_SAFE_CRLF_FAIL) {
        ca.safe_crlf = GIT_SAFE_CRLF_WARN
    }

    if let attr_values {
        /* load the text attribute */
        ca->crlf_action = check_crlf(attr_values[2]); /* text */

        if (ca->crlf_action == GIT_CRLF_UNDEFINED)
            ca->crlf_action = check_crlf(attr_values[0]); /* crlf */

        if (ca->crlf_action != GIT_CRLF_BINARY) {
            /* load the eol attribute */
            int eol_attr = check_eol(attr_values[1]);

            if (ca->crlf_action == GIT_CRLF_AUTO && eol_attr == GIT_EOL_LF)
                ca->crlf_action = GIT_CRLF_AUTO_INPUT;
            else if (ca->crlf_action == GIT_CRLF_AUTO && eol_attr == GIT_EOL_CRLF)
                ca->crlf_action = GIT_CRLF_AUTO_CRLF;
            else if (eol_attr == GIT_EOL_LF)
                ca->crlf_action = GIT_CRLF_TEXT_INPUT;
            else if (eol_attr == GIT_EOL_CRLF)
                ca->crlf_action = GIT_CRLF_TEXT_CRLF;
        }

        ca->attr_action = ca->crlf_action;
    } else {
        ca->crlf_action = GIT_CRLF_UNDEFINED;
    }

    if (ca->crlf_action == GIT_CRLF_TEXT)
        ca->crlf_action = text_eol_is_crlf(ca) ? GIT_CRLF_TEXT_CRLF : GIT_CRLF_TEXT_INPUT;
    if (ca->crlf_action == GIT_CRLF_UNDEFINED && ca->auto_crlf == GIT_AUTO_CRLF_FALSE)
        ca->crlf_action = GIT_CRLF_BINARY;
    if (ca->crlf_action == GIT_CRLF_UNDEFINED && ca->auto_crlf == GIT_AUTO_CRLF_TRUE)
        ca->crlf_action = GIT_CRLF_AUTO_CRLF;
    if (ca->crlf_action == GIT_CRLF_UNDEFINED && ca->auto_crlf == GIT_AUTO_CRLF_INPUT)
        ca->crlf_action = GIT_CRLF_AUTO_INPUT;

    return 0;
}



// MARK: - Migration

@available(*, unavailable, renamed: "Filter.Crlf")
private typealias git_crlf_t = Filter.Crlf


@available(*, unavailable, renamed: "Filter.Crlf.none")
private var GIT_CRLF_UNDEFINED: Filter.Crlf { fatalError() }

@available(*, unavailable, renamed: "Filter.Crlf.binary")
private var GIT_CRLF_BINARY: Filter.Crlf { fatalError() }

@available(*, unavailable, renamed: "Filter.Crlf.text")
private var GIT_CRLF_TEXT: Filter.Crlf { fatalError() }

@available(*, unavailable, renamed: "Filter.Crlf.textInput")
private var GIT_CRLF_TEXT_INPUT: Filter.Crlf { fatalError() }

@available(*, unavailable, renamed: "Filter.Crlf.textCrlf")
private var GIT_CRLF_TEXT_CRLF: Filter.Crlf { fatalError() }

@available(*, unavailable, renamed: "Filter.Crlf.auto")
private var GIT_CRLF_AUTO: Filter.Crlf { fatalError() }

@available(*, unavailable, renamed: "Filter.Crlf.autoInput")
private var GIT_CRLF_AUTO_INPUT: Filter.Crlf { fatalError() }

@available(*, unavailable, renamed: "Filter.Crlf.autoCrlf")
private var GIT_CRLF_AUTO_CRLF: Filter.Crlf { fatalError() }










// MARK: - Migration

@available(*, unavailable, renamed: "Filter.Registry.shared")
@Filter.Registry.SyncLock
private var filter_registry: Filter.Registry { get { .shared } set { .shared = newValue } }


@available(*, unavailable, renamed: "Filter.initialize()")
public func git_filter_global_init() -> CInt { fatalError() }

@available(*, unavailable, renamed: "Filter.filterDefinitionPriorityCompare(a:b:)")
public func filter_def_priority_cmp(_: Any, _: Any) -> CInt { fatalError() }

@available(*, unavailable, renamed: "Filter.crlf()")
public func git_crlf_filter_new() -> git_filter { fatalError() }


@available(*, unavailable, renamed: "Writestream.filterBufferedStream()")
public func git_filter_buffered_stream_new(
    _: inout git_writestream,
    _: git_filter,
    _: (_: git_filter, _: inout AnyTypeProtocol?, _: git_str, _: git_str, _: git_filter_source) -> CInt,
    _: git_str,
    _: inout AnyTypeProtocol?,
    _: git_filter_source,
    _: git_writestream)
-> CInt
{ fatalError() }
