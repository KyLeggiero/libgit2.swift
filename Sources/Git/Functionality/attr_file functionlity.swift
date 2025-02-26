//
//  File.swift
//  libgit2.swift
//
//  Created by Ky on 2025-02-15.
//

import Foundation



public func git_attr_get_many_with_session(
    repo: Repository,
    attr_session: git_attr_session,
    opts: git_attr_options,
    path pathname: String,
    num_attr: size_t,
    names: [String])
throws(GitError) -> [String]?
{
    var error: GitError?
    var path: git_attr_path?
    var files = SelfSortingArray<AnyTypeProtocol>()
    var i, j, k: size_t
    var file: git_attr_file
    var rule: git_attr_rule
    var info: attr_get_many_info? = nil
    var num_found: size_t = 0
    var dir_flag: git_dir_flag = .GIT_DIR_FLAG_UNKNOWN
    
    func cleanup() throws {
        path = nil
        info = nil
        
        if let error { throw error }
    }

    guard 0 != num_attr else {
        return nil
    }

    try assert(expr: repo)
    try assert(expr: pathname)
    try assert(expr: names)
    try GIT_ERROR_CHECK_VERSION(structure: opts, expectedMax: GIT_ATTR_OPTIONS_VERSION, name: "git_attr_options")

    if git_repository_is_bare(repo) {
        dir_flag = GIT_DIR_FLAG_FALSE
    }
    
    if (git_attr_path__init(&path, pathname, git_repository_workdir(repo), dir_flag) < 0)
        return -1;

    if ((error = collect_attr_files(repo, attr_session, opts, pathname, &files)) < 0)
        return try cleanup()

    info = git__calloc(num_attr, sizeof(attr_get_many_info));
    GIT_ERROR_CHECK_ALLOC(info);

    git_vector_foreach(&files, i, file) {

        git_attr_file__foreach_matching_rule(file, &path, j, rule) {

            for (k = 0; k < num_attr; k++) {
                size_t pos;

                if (info[k].found != NULL) /* already found assignment */
                    continue;

                if (!info[k].name.name) {
                    info[k].name.name = names[k];
                    info[k].name.name_hash = git_attr_file__name_hash(names[k]);
                }

                if (!git_vector_bsearch(&pos, &rule->assigns, &info[k].name)) {
                    info[k].found = (git_attr_assignment *)
                        git_vector_get(&rule->assigns, pos);
                    values[k] = info[k].found->value;

                    if (++num_found == num_attr)
                        return try cleanup()
                }
            }
        }
    }

    for (k = 0; k < num_attr; k++) {
        if (!info[k].found)
            values[k] = NULL;
    }
    
    return try cleanup()
}



public func git_attr_path__free(info: inout git_attr_path?) {
    info.full = nil
    info.path = nil
    info.basename = nil
}



// MARK: - Private to `attr.c`

private struct attr_get_many_info {
    var name: git_attr_name
    var found: git_attr_assignment
}
