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



@inline(__always)
public let GIT_CONFIG_FILENAME_SYSTEM = "gitconfig"



public extension Config {
    
    /// Parse a string value as a bool.
    ///
    /// Valid values for true:
    /// - "true", "yes", "on"
    /// - 1 or any non-zero number
    ///
    /// Valid values for false:
    /// - "false", "no", "off"
    /// - 0
    ///
    /// When parsing as a number, this also follows the same rules as ``FixedWidthInteger/parse(gitNumberString:base:)``.
    ///
    /// - Parameter value: The string to parse
    /// - Returns: The parsed boolean value
    /// - Throws: `GitError` if the string cannot be parsed as a boolean
    // Analogous to `git_config_parse_bool`
    static func parseBool(_ value: String) throws(GitError) -> Bool {
        do {
            return try (try? .parse(gitBoolString: value))
                ?? (try (parseInt32(value) != 0))
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
    
    
    /// Parse a string value as an Int64.
    ///
    /// An optional value suffix of `'k'`, `'m'`, or `'g'` will cause the value to be multiplied by `1024`, `1048576`, or `1073741824` prior to output.
    ///
    /// For example, `"123k"` parses as `125952`.
    ///
    /// This also follows the same rules as ``FixedWidthInteger/parse(gitNumberString:base:)``.
    ///
    /// - Parameter value: value to parse
    /// - Returns: the result of the parsing
    /// - Throws: an error if parsing failed
    // Analogous to `git_config_parse_int64`
    static func parseInt64(_ value: String) throws(GitError) -> __int64_t { // TODO: Test
        @inline(__always)
        var failParseError: GitError {
            GitError(message: "failed to parse '\(value)' as an integer", kind: .config, code: .__generic)
        }
        
        
        let parseResult = Int64.parse(gitNumberString: value, base: nil)
        let num_end = value[orNil: parseResult.parseRange.upperBound]
        var num = try parseResult.parsed.mapError({ _ in failParseError }).get()
        
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
            guard value.endIndex <= parseResult.parseRange.upperBound else {
                throw GitError(
                    message: "Integer string was a valid integer, but contained characters after the digits & SI suffix",
                    code: GitError.Code.__generic)
            }
            
            fallthrough
            
        case nil:
            return num
            
        default:
            throw failParseError
        }
    }
    
    
    /// Parse a string value as an Int32.
    ///
    /// An optional value suffix of `'k'`, `'m'`, or `'g'` will cause the value to be multiplied by 1024, 1048576, or 1073741824 prior to output.
    ///
    /// For example, `"123k"` parses as `125952`.
    ///
    /// This also follows the same rules as ``FixedWidthInteger/parse(gitNumberString:base:)``.
    ///
    /// - Parameter value: value to parse
    /// - Returns: the result of the parsing
    /// - Throws An error if parsing failed.
    // Analogous to `git_config_parse_int32`
    static func parseInt32(_ value: String) throws(GitError) -> __int32_t {
        @inline(__always)
        var failParseError: GitError {
            GitError(message: "failed to parse '\(value)' as a 32-bit integer", kind: .config, code: .__generic)
        }
        
        
        let tmp = try mapError(try parseInt64(value)) { failParseError }
        
        let truncate = __int32_t(truncatingIfNeeded: tmp)
        guard truncate == tmp else {
            throw failParseError
        }
        
        return truncate
    }
}



// MARK: - Migration


@available(*, unavailable, renamed: "Config.parseBool")
public func git_config_parse_bool(_: inout CInt, _: CharStar) -> CInt { fatalError() }
@available(*, unavailable, renamed: "Config.parseInt32")
public func git_config_parse_int32(_:inout __int32_t, _: CharStar) -> CInt { fatalError() }
@available(*, unavailable, renamed: "Config.parseInt64")
public func git_config_parse_int64(_:inout __int64_t, _: CharStar) -> CInt { fatalError() }
