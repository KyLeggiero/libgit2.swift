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



public extension Config {
    
    /// Parse a string value as a bool.
    ///
    /// Valid values for true are: 'true', 'yes', 'on', 1 or any number different from 0
    /// Valid values for false are: 'false', 'no', 'off', 0
    ///
    /// - Parameter value: value to parse
    /// - Returns: The result of parsing
    /// - Throws: A descriptive error if parsing failed
    static func parseBool(_ value: String) throws(GitError) -> Bool {
        do {
            return try? git__parse_bool(value)
            ?? try (git_config_parse_int32(value) != 0)
        }
        catch {
            throw .init(message: "failed to parse '\(value)' as a boolean value", kind: .config)
        }
        
        // The above code translates this original C code:
        //
        // int git_config_parse_bool(int *out, const char *value)
        // {
        //     if (git__parse_bool(out, value) == 0)
        //         return 0;
        //
        //     if (git_config_parse_int32(out, value) == 0) {
        //         *out = !!(*out);
        //         return 0;
        //     }
        //
        //     git_error_set(GIT_ERROR_CONFIG, "failed to parse '%s' as a boolean value", value);
        //     return -1;
        // }
    }
    
    
    func git_config_parse_int64(_ value: String) throws(GitError) -> __int64_t {
        let num_end: String
        var num: __int64_t

        if (!value || git__strntol64(&num, value, strlen(value), &num_end, 0) < 0)
            goto fail_parse;

        switch (*num_end) {
        case 'g':
        case 'G':
            num *= 1024;
            /* fallthrough */

        case 'm':
        case 'M':
            num *= 1024;
            /* fallthrough */

        case 'k':
        case 'K':
            num *= 1024;

            /* check that that there are no more characters after the
             * given modifier suffix */
            if (num_end[1] != '\0')
                return -1;

            /* fallthrough */

        case '\0':
            *out = num;
            return 0;

        default:
            goto fail_parse;
        }

    fail_parse:
        git_error_set(GIT_ERROR_CONFIG, "failed to parse '%s' as an integer", value ? value : "(null)");
        return -1;
    }
    
    
    static func git_config_parse_int32(_ value: String) throws(GitError) -> __int32_t {
        var tmp: int64_t
        var truncate: int32_t
        
        if (git_config_parse_int64(&tmp, value) < 0)
            goto fail_parse;
        
        truncate = tmp & 0xFFFFFFFF;
        if (truncate != tmp)
            goto fail_parse;
        
        *out = truncate;
        return 0;
        
    fail_parse:
        git_error_set(GIT_ERROR_CONFIG, "failed to parse '%s' as a 32-bit integer", value ? value : "(null)");
        return -1;
    }
}



// MARK: - Migration


@available(*, unavailable, renamed: "Config.parseBool")
public func git_config_parse_bool(_: inout CInt, _: CharStar) -> CInt { fatalError() }
