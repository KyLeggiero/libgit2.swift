//
// crlf functionality.swift
//
// Written by Ky on 2025-01-04.
// Copyright waived. No rights reserved.
//
// This file is part of libgit2.swift, distributed under the Fair License.
// For full terms, see the included LICENSE file.
//

import Foundation



public extension Filter {
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
    
    
    
    enum Crlf: AnyEnumProtocol {
        case binary
        case text
        case textInput
        case textCrlf
        case auto
        case autoInput
        case autoCrlf
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
        &ca.auto_crlf,
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








