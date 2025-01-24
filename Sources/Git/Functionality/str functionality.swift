//
// str functionality.swift
//
// Written by Ky on 2024-12-18.
// Copyright waived. No rights reserved.
//
// This file is part of libgit2.swift, distributed under the Fair License.
// For full terms, see the included LICENSE file.
//

import Foundation

public let git_str__oom = "\u{0}"

@available(*, deprecated, renamed: "nil", message: "You should only have to nilify the String and the Swift runtime will take care of the rest.")
@inline(__always)
public func git_str_dispose(string: inout String?) {
    string = nil
}



public extension String {
    
    /// If the given new string is not `nil`, then this string becomes a copy of it. If it is `nil`, then this function throws an error
    ///
    /// - Parameters:
    ///   - newString:       The string to overwrite this one with
    ///   - expressionLabel: _optional_ - **Encouraged!** Labels the expression in the thrown error. This should be the name of the argument you're using as the new string. Defaults to `#function`.
    ///
    /// - Throws: A ``GitError`` iff `newString` is `nil`
    // Analogous to `git_str_puts`
    mutating func checkedSet(to newString: String?, expressionLabel: String = #function) throws(GitError) {
        self = try .init(checking: newString)
    }
    
    
    /// If the given new string is not `nil`, then this string is initialized as a copy of it. If it is `nil`, then this initializer throws an error
    ///
    /// - Parameters:
    ///   - newString:       The string to initialize this new string as
    ///   - expressionLabel: _optional_ - **Encouraged!** Labels the expression in the thrown error. This should be the name of the argument you're using as the new string. Defaults to `#function`.
    ///
    /// - Throws: A ``GitError`` iff `newString` is `nil`
    // Analogous to `git_str_puts`
    init(checking newString: String?, expressionLabel: String = #function) throws(GitError) {
        self = try assert(expr: newString, expressionLabel: expressionLabel)
    }
    
    
    /// If the given new string is not `nil`, then this string is initialized as a copy of it. If it is `nil`, then this initializer throws an error
    ///
    /// - Parameters:
    ///   - cString:         The C string to initialize this new string as
    ///   - expressionLabel: _optional_ - **Encouraged!** Labels the expression in the thrown error. This should be the name of the argument you're using as the new string. Defaults to `#function`.
    ///
    /// - Returns: `nil` if the given C string is non-nil but can't be converted into a Swift string
    ///
    /// - Throws: A ``GitError`` iff `newString` is `nil`
    // Analogous to `git_str_puts`
    init?(checking cString: [CChar]?, expressionLabel: String = #function) throws(GitError) {
        var cString = try assert(expr: cString, expressionLabel: expressionLabel)
        self.init(validatingCString: &cString)
    }
    
    
    /// If the given new string is not `nil`, then this string is initialized as a copy of it. If it is `nil`, then this initializer throws an error
    ///
    /// - Parameters:
    ///   - cString:         The C string to initialize this new string as
    ///   - expressionLabel: _optional_ - **Encouraged!** Labels the expression in the thrown error. This should be the name of the argument you're using as the new string. Defaults to `#function`.
    ///
    /// - Returns: `nil` if the given C string is non-nil but can't be converted into a Swift string
    ///
    /// - Throws: A ``GitError`` iff `newString` is `nil`
    // Analogous to `git_str_puts`
    init?(checking cString: UnsafeMutablePointer<CChar>?, expressionLabel: String = #function) throws(GitError) {
        var cString = try assert(expr: cString, expressionLabel: expressionLabel)
        self.init(validatingCString: cString)
    }
    
    /**
     * Join two strings as paths, inserting a slash between as needed.
     * @return 0 on success, -1 on failure
     */
    @inline(__always)
    // Analogous to `git_str_joinpath`
    init(joiningPath a: String, withPathComponent b: String) { // TODO: Unit tests
        self.init(joining: a, with: b, separator: "/")
        
        // The above code translates this original C code:
        //
        // return git_str_join(str, '/', a, b);
    }
    
    /** General join with separator */
    // Analogous to `git_str_join`
    init(joining str_a: String?, with str_b: String, separator: Character?) { // TODO: Unit tests
        if let separator {
            if let str_a {
                self = "\(str_a)\(separator)\(str_b)"
            }
            else {
                self = "\(separator)\(str_b)"
            }
        }
        else {
            if let str_a {
                self = str_a + str_b
            }
            else {
                self = str_b
            }
        }
        
        // The above code translates this original C code:
        //
        // int git_str_join(
        //     git_str *buf,
        //     char separator,
        //     const char *str_a,
        //     const char *str_b)
        // {
        //     size_t strlen_a = str_a ? strlen(str_a) : 0;
        //     size_t strlen_b = strlen(str_b);
        //     size_t alloc_len;
        //     int need_sep = 0;
        //     ssize_t offset_a = -1;
        //
        //     /* not safe to have str_b point internally to the buffer */
        //     if (buf->size)
        //         GIT_ASSERT_ARG(str_b < buf->ptr || str_b >= buf->ptr + buf->size);
        //
        //     /* figure out if we need to insert a separator */
        //     if (separator && strlen_a) {
        //         while (*str_b == separator) { str_b++; strlen_b--; }
        //         if (str_a[strlen_a - 1] != separator)
        //             need_sep = 1;
        //     }
        //
        //     /* str_a could be part of the buffer */
        //     if (buf->size && str_a >= buf->ptr && str_a < buf->ptr + buf->size)
        //         offset_a = str_a - buf->ptr;
        //
        //     GIT_ERROR_CHECK_ALLOC_ADD(&alloc_len, strlen_a, strlen_b);
        //     GIT_ERROR_CHECK_ALLOC_ADD(&alloc_len, alloc_len, need_sep);
        //     GIT_ERROR_CHECK_ALLOC_ADD(&alloc_len, alloc_len, 1);
        //     ENSURE_SIZE(buf, alloc_len);
        //
        //     /* fix up internal pointers */
        //     if (offset_a >= 0)
        //         str_a = buf->ptr + offset_a;
        //
        //     /* do the actual copying */
        //     if (offset_a != 0 && str_a)
        //         memmove(buf->ptr, str_a, strlen_a);
        //     if (need_sep)
        //         buf->ptr[strlen_a] = separator;
        //     memcpy(buf->ptr + strlen_a + need_sep, str_b, strlen_b);
        //
        //     buf->size = strlen_a + strlen_b + need_sep;
        //     buf->ptr[buf->size] = '\0';
        //
        //     return 0;
        // }
    }
    
    
    /// This treats `buffer` as a data buffer and appends `stringToAppend` at the end of it.
    ///
    /// This is different from `buffer.append(stringToAppend)` because it performs additional checks and guarantees that `buffer` can act as a buffer.
    /// For example, this explicitly treats the `buffer`'s capacity separately from its character `count`.
    ///
    /// - Parameters:
    ///   - buffer:         The buffer which will have the given new data appended to its end
    ///   - stringToAppend: The new data to append to the end of the buffer
    // Analogous to `git_buf_put``
    static func bufferAppend(buffer: inout String, stringToAppend: String) {
        guard !stringToAppend.isEmpty else { return }
        buffer.reserveCapacity(buffer.count + stringToAppend.count)
        buffer.append(stringToAppend)
    }
}



// MARK: - Migration

@available(*, unavailable, renamed: "String()")
@inline(__always)
public var GIT_STR_INIT: git_str { .init() }

@available(*, unavailable, renamed: "git_str_dispose(string:)", message: "Evaluate whether this is necessary in Swift (original was mostly deallocation)")
public func git_str_dispose(_: inout git_str?) { fatalError() }

@available(*, unavailable, renamed: "String.bufferAppend(buffer:stringToAppend:)")
public func git_str_put(_: inout git_str, _: CharStar, _: size_t) throws(GitError) { fatalError() }

@available(*, unavailable, renamed: "String.init(checking:expressionLabel:)")
public func git_str_puts(_: inout git_str?, _: CharStar?) -> CInt { fatalError() }

@available(*, unavailable, renamed: "String.init(joining:with:separator:)")
public func git_str_join(_: inout git_str?, _: CChar, _: CharStar, _: CharStar) -> CInt { fatalError() }

@available(*, unavailable, renamed: "init(joiningPath:withPathComponent:)")
public func git_str_joinpath(_: inout git_str?, _: CharStar, _: CharStar) -> CInt { fatalError() }

@available(*, unavailable, message: "This is equivalent to `.removeAll(keepingCapacity: true)``")
public func git_str_clear(_: inout git_str?) -> CInt { fatalError() }

@available(*, unavailable, renamed: "String.count", message: "just use .count")
public func git_str_len(_: inout git_str?) -> size_t { fatalError() }


public extension String {
    @available(*, unavailable, message: "This is identical to Swift = assignment if the new string isn't Optional")
    init(checking _: String, expressionLabel _: String = #function) throws(GitError) { fatalError() }
}
