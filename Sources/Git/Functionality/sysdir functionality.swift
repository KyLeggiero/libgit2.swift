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

/**
 * Configures global data for configuration file search paths.
 *
 * @return 0 on success, <0 on failure
 */
public extension SysDir {
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
    struct Dir: AnyStructProtocol {
        var buf: String?
        
        // Analogous to `guess` in libgit2
        let guesser: @Sendable () throws(GitError) -> String
        
        mutating fileprivate func guess() throws(GitError) {
            buf = try guesser()
        }
        
        
        
        @Volatile
        static var allCases: [Dir] = [
            .init(guesser: git_sysdir_guess_system_dirs),
            .init(guesser: git_sysdir_guess_global_dirs),
            .init(guesser: git_sysdir_guess_xdg_dirs),
            .init(guesser: git_sysdir_guess_programdata_dirs),
            .init(guesser: git_sysdir_guess_template_dirs),
            .init(guesser: git_sysdir_guess_home_dirs),
        ]
        
        
        @Sendable
        @Volatile
        static func globalShutdown() async {
            for i in allCases.indices {
                allCases[i].buf = nil
            }
        }
    }
}


private func git_sysdir_guess_system_dirs() throws(GitError) -> String {
#if GIT_WIN32
    git_win32__find_system_dirs(out, "etc");
#else
    "/etc"
#endif
}

private func git_sysdir_guess_global_dirs() throws(GitError) -> String {
    return git_sysdir_guess_home_dirs()
}

private static func git_sysdir_guess_home_dirs() throws(GitError) -> String
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
        
        /**
         * If APP_SANDBOX_CONTAINER_ID is set, we are running in a
         * sandboxed environment on macOS.
         */
        let sandbox_id = getenv("APP_SANDBOX_CONTAINER_ID")
        
        /*
         * In case we are running setuid, use the configuration
         * of the effective user.
         *
         * If we are running in a sandboxed environment on macOS,
         * we have to get the HOME dir from the password entry file.
         */
        guard let sandbox_id else {
            return try _getEnv(name: "HOME")
        }
        
        return try get_passwd_home(euid)
    }
    catch {
        if error.code == .objectNotFound {
            // Ignore for some reason
        }
        else {
            throw error
        }
    }
#endif
}

#if !GIT_WIN32
func get_passwd_home(uid: uid_t) throws(GitError) -> String
{
    var pwd = passwd()
    var pwdptr: UnsafeMutablePointer<passwd>?
    var buf: UnsafeMutablePointer<CChar>
    var buflen = sysconf(_SC_GETPW_R_SIZE_MAX)
    if -1 == buflen {
        buflen = 1024
    }
    
    var error: CInt
    repeat {
        buf = UnsafeMutablePointer<CChar>.allocate(capacity: buflen)
        defer { buflen *= 2 }
        error = getpwuid_r(uid, &pwd, buf, buflen, &pwdptr)
    } while (error == ERANGE && buflen <= 8192)

    guard 0 == error else {
        throw .init(
            message: "failed to get passwd entry",
            kind: GIT_ERROR_OS,
            systemError: error
        )
    }

    if (!pwdptr) {
        git_error_set(GIT_ERROR_OS, "no passwd entry found for user");
        goto out;
    }

    if ((error = git_str_puts(out, pwdptr->pw_dir)) < 0)
        goto out;

out:
    git__free(buf);
    return error;
}
#endif



// MARK: - Migration

@available(*, unavailable, renamed: "SysDir.Dir")
private typealias git_sysdir__dir = SysDir.Dir

@available(*, unavailable, renamed: "SysDir.globalInit()")
public func git_sysdir_global_init() -> CInt { fatalError() }

@available(*, unavailable, renamed: "get_passwd_home(uid:)")
public func get_passwd_home(_: inout git_str, _: uid_t) -> CInt { fatalError() }
