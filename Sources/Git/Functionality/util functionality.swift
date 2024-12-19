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



// MARK: - Migration

@available(*, unavailable, renamed: "array.count", message: "Just use Swift's builtin array.count lol")
public func ARRAY_SIZE(_ array: [any Any]) -> Int { fatalError() }

@available(*, unavailable, renamed: "_getEnv(name:)")
public func git__getenv(_: inout git_str, _: String) -> CInt { fatalError() }
