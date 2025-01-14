//
// sysdir functionality.swift
//
// Written by Ky on 2024-12-18.
// Copyright waived. No rights reserved.
//
// This file is part of libgit2.swift, distributed under the Fair License.
// For full terms, see the included LICENSE file.
//

import Foundation

@preconcurrency import LazyContainers



public extension SysDir {
    
    /// Caches configuration file search paths.
    ///
    /// This also sets up a shutdown hook to uncache the paths
    ///
    /// - Throws: a ``GitError`` describing what failed
    // Analogous to `git_sysdir_global_init`
    @Volatile
    static func globalInit() async throws(GitError) {
        for i in Dir.allCases.indices {
            try Dir.allCases[i].guess()
        }
        
        await Runtime.registerShutdownHook(Dir.globalShutdown)
    }
}



// MARK: - Private functionality

private extension SysDir {
    @Volatile
    struct Dir: AnyStructProtocol, @preconcurrency CaseIterable {
        @ResettableLazy
        fileprivate var directory: String?
        
        
        init(guesser: @escaping Guesser) {
            self._directory = .init {
                do {
                    return try guesser()
                }
                catch {
                    return nil
                }
            }
        }
        
        
        
        typealias Guesser = @Sendable () throws(GitError) -> String?
    }
}



private extension SysDir.Dir {
    @inline(never)
    @_optimize(none)
    mutating func guess() throws(GitError) {
        _ = _directory.wrappedValue
    }
    
    
    mutating func shutdown() {
        _directory.clear()
    }
    
    
    
    @Volatile
    static var allCases: [Self] = [
        .init(guesser: guessSystemDirs),
        .init(guesser: guessGlobalDirs),
        .init(guesser: guessXdgDirs),
        .init(guesser: guessProgramdataDirs),
        .init(guesser: guessTemplateDirs),
        .init(guesser: guessHomeDirs),
    ]
    
    
    @Sendable
    @Volatile
    static func globalShutdown() async {
        for i in allCases.indices {
            allCases[i].shutdown()
        }
    }
}



private extension SysDir.Dir {
    // Analogous to `git_sysdir_guess_system_dirs`
    static func guessSystemDirs() throws(GitError) -> String {
#if GIT_WIN32
        git_win32__find_system_dirs(out, "etc");
#else
        "/etc"
#endif
    }
    
    // Analogous to `git_sysdir_guess_global_dirs`
    static func guessGlobalDirs() throws(GitError) -> String? {
        try guessHomeDirs()
    }
    
    // Analogous to `git_sysdir_guess_home_dirs`
    static func guessHomeDirs() throws(GitError) -> String?
    {
#if GIT_WIN32
        find_win32_dirs([
            "%HOME%\\",
            "%HOMEDRIVE%%HOMEPATH%\\",
            "%USERPROFILE%\\"
        ])
#else
        do {
            let uid = getuid()
            let euid = geteuid()
            
            /*
             * If APP_SANDBOX_CONTAINER_ID is set, we are running in a
             * sandboxed environment on macOS.
             */
            /*
             * In case we are running setuid, use the configuration
             * of the effective user.
             *
             * If we are running in a sandboxed environment on macOS,
             * we have to get the HOME dir from the password entry file.
             */
            guard let _ = getenv("APP_SANDBOX_CONTAINER_ID"),
                  uid == euid else {
                return try _getEnv(name: "HOME")
            }
            
            return try passwdHome(uid: euid)
        }
        catch {
            if error.code == .objectNotFound {
                // Ignore for some reason
                return nil // TODO: Is this the proper interpretation of the C code?
            }
            else {
                throw error
            }
        }
#endif
        
        
        // The above code translates this original C code:
        //
        // static int git_sysdir_guess_home_dirs(git_str *out)
        // {
        // #ifdef GIT_WIN32
        //     static const wchar_t *global_tmpls[4] = {
        //         L"%HOME%\\",
        //         L"%HOMEDRIVE%%HOMEPATH%\\",
        //         L"%USERPROFILE%\\",
        //         NULL,
        //     };
        //
        //     return find_win32_dirs(out, global_tmpls);
        // #else
        //     int error;
        //     uid_t uid, euid;
        //     const char *sandbox_id;
        //
        //     uid = getuid();
        //     euid = geteuid();
        //
        //     /**
        //      * If APP_SANDBOX_CONTAINER_ID is set, we are running in a
        //      * sandboxed environment on macOS.
        //      */
        //     sandbox_id = getenv("APP_SANDBOX_CONTAINER_ID");
        //
        //     /*
        //      * In case we are running setuid, use the configuration
        //      * of the effective user.
        //      *
        //      * If we are running in a sandboxed environment on macOS,
        //      * we have to get the HOME dir from the password entry file.
        //      */
        //     if (!sandbox_id && uid == euid)
        //         error = git__getenv(out, "HOME");
        //     else
        //         error = get_passwd_home(out, euid);
        //
        //     if (error == GIT_ENOTFOUND) {
        //         git_error_clear();
        //         error = 0;
        //     }
        //
        //     return error;
        // #endif
        // }
    }
    
    
    // Analogous to `git_sysdir_guess_xdg_dirs`
    static func guessXdgDirs() throws(GitError) -> String {
#if GIT_WIN32
        try find_win32_dirs([
            "%XDG_CONFIG_HOME%\\git",
            "%APPDATA%\\git",
            "%LOCALAPPDATA%\\git",
            "%HOME%\\.config\\git",
            "%HOMEDRIVE%%HOMEPATH%\\.config\\git",
            "%USERPROFILE%\\.config\\git",
        ]);
#else
        let euid = geteuid()
        
        /*
         * In case we are running setuid, only look up passwd
         * directory of the effective user.
         */
        if getuid() == euid {
            do {
                return String(joiningPath: try _getEnv(name: "XDG_CONFIG_HOME"), withPathComponent: "git")
            }
            catch where .objectNotFound == error.code {
                return String(joiningPath: try _getEnv(name: "HOME"), withPathComponent: ".config/git")
            }
        }
        else {
            return String(joiningPath: try passwdHome(uid: euid), withPathComponent: ".config/git")
        }
#endif
        // The above code translates this original C code:
        //
        // static int git_sysdir_guess_xdg_dirs(git_str *out)
        // {
        // #ifdef GIT_WIN32
        //     static const wchar_t *global_tmpls[7] = {
        //         L"%XDG_CONFIG_HOME%\\git",
        //         L"%APPDATA%\\git",
        //         L"%LOCALAPPDATA%\\git",
        //         L"%HOME%\\.config\\git",
        //         L"%HOMEDRIVE%%HOMEPATH%\\.config\\git",
        //         L"%USERPROFILE%\\.config\\git",
        //         NULL,
        //     };
        //
        //     return find_win32_dirs(out, global_tmpls);
        // #else
        //     git_str env = GIT_STR_INIT;
        //     int error;
        //     uid_t uid, euid;
        //
        //     uid = getuid();
        //     euid = geteuid();
        //
        //     /*
        //      * In case we are running setuid, only look up passwd
        //      * directory of the effective user.
        //      */
        //     if (uid == euid) {
        //         if ((error = git__getenv(&env, "XDG_CONFIG_HOME")) == 0)
        //             error = git_str_joinpath(out, env.ptr, "git");
        //
        //         if (error == GIT_ENOTFOUND && (error = git__getenv(&env, "HOME")) == 0)
        //             error = git_str_joinpath(out, env.ptr, ".config/git");
        //     } else {
        //         if ((error = get_passwd_home(&env, euid)) == 0)
        //             error = git_str_joinpath(out, env.ptr, ".config/git");
        //     }
        //
        //     if (error == GIT_ENOTFOUND) {
        //         git_error_clear();
        //         error = 0;
        //     }
        //
        //     git_str_dispose(&env);
        //     return error;
        // #endif
        // }
    }
    
    
    // Analogous to `git_sysdir_guess_programdata_dirs`
    static func guessProgramdataDirs() throws(GitError) -> String? {
#if GIT_WIN32
        try find_win32_dirs([
            "%PROGRAMDATA%\\Git",
        ])
#else
        return nil
#endif
    }
    
    
    // Analogous to `git_sysdir_guess_template_dirs`
    static func guessTemplateDirs() throws(GitError) -> String? {
#if GIT_WIN32
        try git_win32__find_system_dirs("share/git-core/templates")
#else
        "/usr/share/git-core/templates"
#endif
    }
    
    
#if !GIT_WIN32
    static func passwdHome(uid: uid_t) throws(GitError) -> String
    {
        var pwd = passwd()
        var pwdptr: UnsafeMutablePointer<passwd>?
        
        
        var buffer = String()
        var bufferCapacity: Int = {
            let bufferCapacity = Int(_SC_GETPW_R_SIZE_MAX)
            if bufferCapacity < 0 {
                return 1024
            }
            else {
                return bufferCapacity
            }
        }()
        
        var error: CInt
        repeat {
            buffer.reserveCapacity(bufferCapacity)
            error = getpwuid_r(uid, &pwd, &buffer.chars, bufferCapacity, &pwdptr)
            bufferCapacity *= 2
        } while error == ERANGE && bufferCapacity <= 8192
        
        guard 0 == error else {
            throw .init(
                message: "failed to get passwd entry",
                kind: .os,
                systemError: error
            )
        }
        
        guard let pwdptr else {
            throw .init(
                message: "no passwd entry found for user",
                kind: .os,
                systemError: error
            )
        }
        
        if let converted = try String(checking: pwdptr.pointee.pw_dir, expressionLabel: "pwdptr->pw_dir") {
            return converted
        }
        else {
            throw GitError(message: "Failed to convert C string to Swift string", kind: .internal)
        }
        
        // The above code translates this original C code:
        //
        // static int get_passwd_home(git_str *out, uid_t uid)
        // {
        //     struct passwd pwd, *pwdptr;
        //     char *buf = NULL;
        //     long buflen;
        //     int error;
        //
        //     GIT_ASSERT_ARG(out);
        //
        //     if ((buflen = sysconf(_SC_GETPW_R_SIZE_MAX)) == -1)
        //         buflen = 1024;
        //
        //     do {
        //         buf = git__realloc(buf, buflen);
        //         error = getpwuid_r(uid, &pwd, buf, buflen, &pwdptr);
        //         buflen *= 2;
        //     } while (error == ERANGE && buflen <= 8192);
        //
        //     if (error) {
        //         git_error_set(GIT_ERROR_OS, "failed to get passwd entry");
        //         goto out;
        //     }
        //
        //     if (!pwdptr) {
        //         git_error_set(GIT_ERROR_OS, "no passwd entry found for user");
        //         goto out;
        //     }
        //
        //     if ((error = git_str_puts(out, pwdptr->pw_dir)) < 0)
        //         goto out;
        //
        // out:
        //     git__free(buf);
        //     return error;
        // }
    }
#endif
}



// MARK: - Migration

@available(*, unavailable, renamed: "SysDir.Dir")
private typealias git_sysdir__dir = SysDir.Dir

@available(*, unavailable, renamed: "SysDir.initialize()")
public func git_sysdir_global_init() -> CInt { fatalError() }
