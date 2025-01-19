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

import SafeCollectionAccess



public extension Config {
    
    /// Parse a string value as a bool.
    ///
    /// Valid values for true are: 'true', 'yes', 'on', 1 or any number different from 0.
    /// Valid values for false are: 'false', 'no', 'off', 0.
    /// Follows the same rules as ``FixedWidthInteger/parse(gitNumberString:base:)``.
    ///
    /// - Parameter value: value to parse
    /// - Returns: The result of parsing
    /// - Throws: A descriptive error if parsing failed
    // Analogous to `git_config_parse_bool`
    static func parseBool(_ value: String) throws(GitError) -> Bool {
        do {
            return try (try? git__parse_bool(value))
                ?? (try (git_config_parse_int32(value) != 0))
        }
        catch {
            throw .init(message: "failed to parse '\(value)' as a boolean value", kind: .config, code: .__generic)
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
        let parseResult = Int64.parse(gitNumberString: value, base: nil)
        let num_end = value[orNil: parseResult.parseRange.upperBound]
        var num = try parseResult.parsed.get()
        
        switch (num_end) {
        case "g", "G":
            num *= 1024
            fallthrough
            
        case "m", "M":
            num *= 1024
            fallthrough
            
        case "k", "K":
            num *= 1024
            
            /* check that that there are no more characters after the
             * given modifier suffix */
            guard value.indices.contains(value.index(after: parseResult.parseRange.upperBound)) else {
                throw GitError(
                    message: "Integer string was a valid integer, but contained characters after the digits & SI suffix",
                    code: GitError.Code.__generic)
            }
            
            fallthrough
            
        case nil:
            return num
            
        default:
            throw GitError(message: "failed to parse '\(value)' as an integer", kind: .config, code: .__generic)
        }
    }
    
    
    static func git_config_parse_int32(_ value: String) throws(GitError) -> __int32_t {
        var tmp: __int64_t
        var truncate: __int32_t
        
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
