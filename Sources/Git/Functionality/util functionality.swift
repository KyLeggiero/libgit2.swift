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



public extension Bool {
    /// Parse a string value as a boolean, just like libgit does, just like Core Git does.
    ///
    /// Valid values for true are: `"true"`, `"yes"`, `"on"`, and `nil`
    /// Valid values for false are: `"false"`, `"no"`, `"off"`, and any string beginning with NUL (U+0000)
    ///
    /// Parsing `nil` and NUL-starting strings this way are undocumented features of libgit2 1.8.4
    static func parse(gitBoolString value: String?) throws(GitError) -> Bool {
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
        
        throw .init(code: .__generic)
    }
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
    ///                      Must be `nil` or in `0...32`.
    ///                      If `nil`, `0`, or `1`, then this attempts to detect the base automatically.
    ///
    /// - Throws:
    ///   - A `GitError` if the given number string couldn't be parsed into a number
    // TODO: Test rigorously
    static func parse(gitNumberString: String, base: UInt8?)
    -> ParseResult {
        @inline(__always) let untrimmedNumberString = gitNumberString
        let trimmedNumberString = untrimmedNumberString.trimmingPrefixAndSuffix(while: CharacterSet.whitespacesAndNewlines.contains)
        
        guard !trimmedNumberString.isEmpty else {
            return ParseResult(parsed: .failure(.couldNotParseStringToInteger()),
                               parseRange: untrimmedNumberString.indexRange)
        }
        
        
        @inline(__always)
        func match<Output>(_ regex: Regex<Output>) -> Output? {
            // According to the documentation,
            // > The `firstMatch(in:)` method can throw an error if this regex includes a transformation closure that throws an error.
            // Since this regex doesn't, it won't. We can safely ignore this error if the Regex API honors its contract
            
            do {
                return try regex.firstMatch(in: trimmedNumberString)?.output
            }
            catch {
                print("Regex API violated its contract", error)
                return nil
            }
        }
        
        
        @inline(__always)
        func parse(base: Int, sign: Substring?, digits: Substring) -> ParseResult {
            let range = (sign?.startIndex ?? digits.startIndex)..<digits.endIndex
            
            if let number = Self.init((sign ?? "") + digits, radix: base) {
                return ParseResult(parsed: .success(number), parseRange: range)
            }
            else {
                return ParseResult(parsed: .failure(.couldNotParseStringToInteger()), parseRange: range)
            }
        }
        
        
        @inline(__always)
        let validCharacters = CharacterSet(charactersIn: "+-").union(.alphanumerics)
        
        @inline(__always)
        let lastAlphanumericIndex = untrimmedNumberString.lastIndex(where: validCharacters.contains)
            ?? untrimmedNumberString.startIndex
        
        let (_, sign, baseIndicator, digits): (Substring, Substring?, Substring?, Substring)
        
        guard let m = match(/(?<sign>[+-])?(?<baseIndicator>0[Xbox]?)?(?<digits>[A-Za-z0-9]+)/) else {
            
            return ParseResult(parsed: .failure(.couldNotParseStringToInteger()),
                               parseRange: trimmedNumberString.startIndex ..< lastAlphanumericIndex)
        }
        
        (_, sign, baseIndicator, digits) = m
        
        if let base,
           0 != base {
            guard base < 32 else {
                return ParseResult(parsed: .failure(.couldNotParseStringToInteger()),
                                   parseRange: trimmedNumberString.startIndex ..< lastAlphanumericIndex)
            }
            
            return parse(base: .init(base), sign: sign, digits: digits)
        }
        else {
            switch baseIndicator {
            case nil:
                return parse(base: 10, sign: sign, digits: digits)
                
            case "0X", "0x":
                return parse(base: 0x10, sign: sign, digits: digits)
                
            case "0b":
                return parse(base: 0b10, sign: sign, digits: digits)
                
            case "0", "0o":
                fallthrough
                
            default:
                return parse(base: 0o10, sign: sign, digits: digits)
            }
        }
    }
    
    
    
    typealias ParseResult = (parsed: Result<Self, GitError>, parseRange: Range<String.Index>)
}



private extension GitError {
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


@available(*, unavailable, renamed: "Int64.parse(gitNumberString:base:)")
public func git__strntol64(_: inout __int64_t, _: CharStar, _: size_t, _: inout CharStar, _: CInt) -> CInt { fatalError() }

@available(*, unavailable, renamed: "Int32.parse(gitNumberString:base:)")
public func git__strntol32(_: inout __int32_t, _: CharStar, _: size_t, _: inout CharStar, _: CInt) -> CInt { fatalError() }

@available(*, unavailable, renamed: "Bool.parse(gitNumberString:)")
public func git__parse_bool(_: inout CInt, _: CharStar) -> CInt { fatalError() }
