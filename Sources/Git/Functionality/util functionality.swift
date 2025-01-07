//
// util functionality.swift
//
// Written by Ky on 2024-12-18.
// Copyright waived. No rights reserved.
//
// This file is part of libgit2.swift, distributed under the Fair License.
// For full terms, see the included LICENSE file.
//

import Foundation

public func _getEnv(name: String) throws(GitError) -> String {
#if GIT_WIN32
    var wide_name: String? = nil
    var wide_value: String? = nil
    let value_len: DWORD
    
    git_str_clear(out);
    
    try git_utf8_to_16_alloc(&wide_name, name)
    
    if ((value_len = GetEnvironmentVariableW(wide_name, NULL, 0)) > 0) {
        wide_value = git__malloc(value_len * sizeof(wchar_t));
        GIT_ERROR_CHECK_ALLOC(wide_value);
        
        value_len = GetEnvironmentVariableW(wide_name, wide_value, value_len);
    }
    
    if (value_len) {
        error = git_str_put_w(out, wide_value, value_len);
    }
    else if (GetLastError() == ERROR_SUCCESS || GetLastError() == ERROR_ENVVAR_NOT_FOUND) {
        error = GIT_ENOTFOUND;
    }
    else {
        git_error_set(GIT_ERROR_OS, "could not read environment variable '%s'", name);
    }
    
    git__free(wide_name);
    git__free(wide_value);
    return error;
#else
    guard let val = getenv(name) else {
        throw GitError(code: .objectNotFound)
    }
    
    return String(platformString: val)
    
    // The above code translates this original C code:
    //
    // const char *val = getenv(name);
    //
    // git_str_clear(out);
    //
    // if (!val)
    //     return GIT_ENOTFOUND;
    //
    // return git_str_puts(out, val);
#endif
}



/// Parse a string value as a boolean, just like libgit does, just like Core Git does.
///
/// Valid values for true are: `"true"`, `"yes"`, `"on"`, and `nil`
/// Valid values for false are: `"false"`, `"no"`, `"off"`, and any string beginning with NUL (U+0000)
///
/// Parsing `nil` and NUL-starting strings this way are undocumented features of libgit2 1.8.4
public func git__parse_bool(_ value: String?) throws(GitError) -> Bool {
    /* A missing value means true */   // WHY THO?!?!?! – Ky, 2025-01-06
    if (value == nil ||
        0 == strcasecmp(value, "true") ||
        0 == strcasecmp(value, "yes") ||
        0 == strcasecmp(value, "on")) {
        return true
    }
    if let value,
       (0 == strcasecmp(value, "false") ||
        0 == strcasecmp(value, "no") ||
        0 == strcasecmp(value, "off") ||
        "\u{0}" == value.first) {
        return false
    }

    throw .init(kind: .__generic)
}


public func git__strntol64(nptr: String, nptr_len: size_t, endptr: inout String, base: CInt)
throws(GitError) -> __int64_t{
    let p: String = nptr
    let n: __int64_t = 0
    let nn: __int64_t
    let v: __int64_t
    let c: CInt
    let ovfl: CInt = 0
    let neg: CInt = 0
    let ndig: CInt = 0
    var nptr_len = nptr_len
    
    
    /*
     * White space
     */
    while nptr_len != 0, git__isspace(p.first) {
        p += 1
        nptr_len -= 1
    }
    
    if !nptr_len {
        goto Return;
    }
    
    /*
     * Sign
     */
    if (*p == '-' || *p == '+') {
        if (*p == '-')
            neg = 1;
        p++;
        nptr_len--;
    }

    if (!nptr_len)
        goto Return;

    /*
     * Automatically detect the base if none was given to us.
     * Right now, we assume that a number starting with '0x'
     * is hexadecimal and a number starting with '0' is
     * octal.
     */
    if (base == 0) {
        if (*p != '0')
            base = 10;
        else if (nptr_len > 2 && (p[1] == 'x' || p[1] == 'X'))
            base = 16;
        else
            base = 8;
    }

    if (base < 0 || 36 < base)
        goto Return;

    /*
     * Skip prefix of '0x'-prefixed hexadecimal numbers. There is no
     * need to do the same for '0'-prefixed octal numbers as a
     * leading '0' does not have any impact. Also, if we skip a
     * leading '0' in such a string, then we may end up with no
     * digits left and produce an error later on which isn't one.
     */
    if (base == 16 && nptr_len > 2 && p[0] == '0' && (p[1] == 'x' || p[1] == 'X')) {
        p += 2;
        nptr_len -= 2;
    }

    /*
     * Non-empty sequence of digits
     */
    for (; nptr_len > 0; p++,ndig++,nptr_len--) {
        c = *p;
        v = base;
        if ('0'<=c && c<='9')
            v = c - '0';
        else if ('a'<=c && c<='z')
            v = c - 'a' + 10;
        else if ('A'<=c && c<='Z')
            v = c - 'A' + 10;
        if (v >= base)
            break;
        v = neg ? -v : v;
        if (git__multiply_int64_overflow(&nn, n, base) || git__add_int64_overflow(&n, nn, v)) {
            ovfl = 1;
            /* Keep on iterating until the end of this number */
            continue;
        }
    }

Return:
    if (ndig == 0) {
        git_error_set(GIT_ERROR_INVALID, "failed to convert string to long: not a number");
        return -1;
    }

    if (endptr)
        *endptr = p;

    if (ovfl) {
        git_error_set(GIT_ERROR_INVALID, "failed to convert string to long: overflow error");
        return -1;
    }

    *result = n;
    return 0;
}





// MARK: - Migration

@available(*, unavailable, renamed: "array.count", message: "Just use Swift's builtin array.count lol")
public func ARRAY_SIZE(_ array: [any Any]) -> Int { fatalError() }

@available(*, unavailable, renamed: "_getEnv(name:)")
public func git__getenv(_: inout git_str, _: String) -> CInt { fatalError() }
