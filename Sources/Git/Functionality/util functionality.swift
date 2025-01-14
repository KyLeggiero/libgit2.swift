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
//import OptionalTools



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



public extension FixedWidthInteger {
    
    /// Parses the given string to this integer type, in the style of libgit2.
    ///
    /// libgit2 allows explicitly specifying a base, and also allows implying a base by setting that to `0`.
    /// If it cannot process the given string into an integer for any reason, then it throws an error.
    /// If the given base is `0`, then it attempts to parse the string based on how it starts:
    /// - `0x` and `0X` parse as hexadecimal (e.g. `"0xC0FFEE"` is parsed as 12,648,430)
    /// - A non-zero starting number parses as decimal (e.g. `"420"` is parsed as 420)
    /// - All other strings starting with `0` are parsed as octal (e.g. `01234` is parsed as 668)
    /// - If `base` is greater than 32, an error is thrown
    ///
    /// The libgit2 function also automatically ignores preceding whitespace, and returns the pointer to the character where it stopped parsing.
    ///
    /// This function mimics that behavior, and also includes the following:
    /// - Allows the base to be `nil`, which means the same as `0`
    /// - If the base is `1`, this considers that the same as `0` (because unary is, practically speaking, never used)
    /// - Strings starting with `0o` parse as octal
    /// - Strings starting with `0b` parse as binary (e.g. `"0b01000101"` is parsed as 69)
    /// - The same code works for all integer types, not just 64- and 32-bit signed binary integers
    /// - Automatically ignores both preceding & trailing whitespace
    ///
    /// This function also opts to not return the location where it stopped parsing. If you need that functionality, please file an issue at
    /// https://github.com/KyNorthstar/libgit2.swift/issues/new/choose
    ///
    ///
    /// - Parameters:
    ///   - gitNumberString: The string to parse into a number
    ///   - base:            The base (radix) of the number.
    ///                      Must be `nil` or in `0...32`
    ///                      If `nil`, `0`, or `1`, then this attempts to detect the base automatically.
    ///
    /// - Throws:
    ///   - A `GitError` if the given number string couldn't be parsed into a number
    init(gitNumberString: String, base: UInt8?) throws(GitError) { // TODO: Test rigorously
        func parse() throws(GitError) -> Self? {
            
            let gitNumberString = gitNumberString.trimmingCharacters(in: .whitespacesAndNewlines)
            
            func match<Output>(_ regex: Regex<Output>) throws(GitError) -> Output? {
                try mapError(try regex.firstMatch(in: gitNumberString)?.output, GitError.fromIntegerParseError)
            }
            
            
            if let base, base > 1 {
                guard base <= 32 else { throw .couldNotParseStringToInteger() }
                return .init(gitNumberString, radix: .init(base))
            }
            else {
                let radix: Int
                let parseString: String
                
                if !gitNumberString.hasPrefix("0") {
                    parseString = gitNumberString
                    radix = 10
                }
                else if let (_, sign, hexString) = try match(/([+-])0[xX](.+)/) {
                    parseString = .init(sign + hexString)
                    radix = 0x10
                }
                else if let (_, sign, octString) = try match(/([+-])0o?(.+)/) {
                    parseString = .init(sign + octString)
                    radix = 0o10
                }
                else if let (_, sign, binString) = try match(/([+-])0b(.+)/) {
                    parseString = .init(sign + binString)
                    radix = 0b10
                }
                else {
                    parseString = gitNumberString
                    radix = 0o10 // not what We would do if making this Ourself, but this is how libgit2 does it
                }
                
                return .init(parseString, radix: radix)
            }
        }
        
        if let parsed = try parse() {
            self = parsed
        }
        else {
            throw .couldNotParseStringToInteger()
        }
    }
}



private extension GitError {
    static func fromIntegerParseError(_ thrownError: any Error) -> Self {
        .couldNotParseStringToInteger(cause: thrownError)
    }
    
    
    static func couldNotParseStringToInteger(cause: (any Error)? = nil) -> Self {
        .init(message: "failed to convert string to long \(nil == cause ? ": not a number" : "")",
              kind: .invalid,
              cause: cause)
    }
}




// MARK: - Migration

@available(*, unavailable, renamed: "array.count", message: "Just use Swift's builtin array.count lol")
public func ARRAY_SIZE(_ array: [any Any]) -> Int { fatalError() }

@available(*, unavailable, renamed: "_getEnv(name:)")
public func git__getenv(_: inout git_str, _: String) -> CInt { fatalError() }


@available(*, unavailable, renamed: "Int64.init(gitNumberString:base:)")
public func git__strntol64(_: inout __int64_t, _: CharStar, _: size_t, _: inout CharStar, _: CInt) -> CInt { fatalError() }

@available(*, unavailable, renamed: "Int32.init(gitNumberString:base:)")
public func git__strntol32(_: inout __int32_t, _: CharStar, _: size_t, _: inout CharStar, _: CInt) -> CInt { fatalError() }
