#  libgit2.swift

A reimplementation of libgit2 in Swift.

Based on libgit2 1.8.4 because that was the most recent release when We started writing it.

Written by Ky, who doesn't recommend you use this. Instead, they recommend you use their package [Gitsune](https://GitHub.com/KyLeggiero/Gitsune), which is a more-Swiftey wrapper around this package.

This package attempts to be a 1-to-1 Swift rewrite of libgit2, and as such it doesn't attempt to introduce any sugar or other refinements. Gitsune's goal is to be fully Swift-first, rather than just a rewrite.



## Why?

We like Swift better than C and feel like it'll be a good langauge to rewrite libit2 in. Safer and compile-guaranteed and all that.



## How?

How do you use it?

Well, mostly just like libgit2, just without unnecessary C bullshit like pointer-juggling and explicit freeing.

```swift
import Git

// TODO: EXAMPLE CODE HERE
```



## Important Usage Notes

### File Names

Since this is a 1-to-1 rewrite of libgit2, very nearly all code is arranged into files with the same names as used in libgit2. For example, if some code is in `commit.h`/`commit.c` in libgit2, then the analogous code here is in `commit.swift` libgit2.swift!

This pattern is only broken where some code is split across a header file with one name and an implementation file with another. In those cases, the header file's name is used.
 
For instance, the function `git_libgit2_init` is declared in the header `global.h`, but it's implemented in `libgit2.c`. So, libgit2.swift places this in `global.swift`.



### Code Names

Included types have been given more-Swiftey names, often along with more Swiftey paradigms.

For example, `git_commit` contains "`git_`"  because C doesn't have namespacing.
Since Swift has namespacing in the form of module names, `git_commit` has been renamed to `Commit` in this package. If you need to disambiguate, you can include the module: `Git.Commit`.

In order to make that easier on users of this package coming from libgit2, this package also includes typealiases so if you try to use the libgit2 name, it'll tell you the correct Swift name to use:

```swift
~/test.swift:12:18: error: 'GIT_OBJECT_BLOB' has been renamed to 'Object.Kind.blob'
let objectType = GIT_OBJECT_BLOB
                 ^~~~~~~~~~~~~~~
                 Object.Kind.blob
```

Public functions & others get this treatment as well. Implementation-only functions (e.g. those only declared in `.c` files) aren't included in this migration sugar for obvious reasons.


Some types have simply been omitted in favor of Swift types.

For example, `git_str` exists because C has no builtin string type and libgit2 doesn't want to rely on much external to itself. So here, `git_str` (and `char *` and similar) has been replaced with Swift's `String`. Same story with all the various forms of arrays.


### Methods & Initializers

Swift supports methods and initializers on types, so this package does too.

This means that top-level functions that initialize a type, are instead initializers on that type. Same with top-level functions which are dedicated to reading/mutating/etc. an instance of a type. Hooray!


### Concurrency

This assumes concurrency is desired!

That is to say, anywhere in libgit2 where concurrency is offered optionally (i.e. with `#if GIT_THREADS`), this package implements the version with concurrency.

Obviously, since this is Swift, the long-`await`ed structured concurrency is used!


### Documentation

If documentation is missing, that's because libgit2 didn't have any. Fuckers.

We tried to fill in the blanks where We could.

If you see doc comments like `/**` then you know it's almost entirely from the original C library.
If it's like `///` then you know We rewrote that doc comment, so it's more correct for this package.

The same (usually) goes for `/*` and `//` inline comments.


### Exclusions

Rote platform/runtime things which C needs (like `str.h`) were skipped because Swift already has a very good way to handle everything those handle (like `String`).

Aside from that, all original (Git-specific) types from libgit2 are included here.



## History

This started in November of 2024 by just copying the C files for libgit2 and translating each one. 
