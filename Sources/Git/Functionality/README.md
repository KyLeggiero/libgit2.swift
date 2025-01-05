# Functionality

This folder contains just the functionality (functions, dynamic properties, et al). The types and fields are in the `Types` folder.

Each file mirrors its C equivalent in libgit2, containing only types contained in the same-named `.h`/`.c`/etc. files in libgit2.



## File Structure

The files have the declarations you should use at the top, and old declarations at the bottom as aliases with `unavailable` migration directives, like this:

```swift
public extension String {
    public func newFunction() throws(GitError) {
        // ...
    } 
}



// MARK: - Migrated

@available(*, unavailable, renamed: "String.newFunction()")
public func git_str_old_fn(_: inout git_str) -> CInt { fatalError() }
```

This allows you to write code with the new Swift calls, even if you are used to working with the old C types (or if you're using a libgit2 tutorial/etc.). You'll just be notified how to use the libgit2.swift version by a compiler error.

The placement in the file also reduces clutter, separating "here's what you're using" from "here's how it was done in libgit2".

This also functions as a bit of documentation: "Here's how things were done in libgit2, and here's how they're done here in libgit2.swift". That can help fill gaps in understanding.
