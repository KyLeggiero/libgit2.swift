#  libgit2.swift

A reimplementation of libgit2 in Swift.

Based on libgit2 1.8.4 because that was the most recent release when We started writing it.

Written by Ky, who doesn't recommend you use this. Instead, they recommend you use their package [Gitsune](https://GitHub.com/KyLeggiero/Gitsune), which is a more-Swiftey wrapper around this package.
This package attempts to be a Swift rewrite of libgit2, and as such it doesn't attempt to introduce any sugar or other refinements. Gitsune's goal is to be fully Swift-first, rather than just a rewrite.



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

### Names

Included types have been given more-Swiftey names.

For example, `git_commit` contains "`git_`"  because C doesn't have namespacing.
Since Swift has namespacing in the form of module names, `git_commit` has been renamed to `Commit` in this package. If you need to disambiguate, you can include the module: `Git.Commit`.

In order to make that easier on users of this package coming from libgit2, this package also includes typealiases so if you try to use the libgit2 name, it'll tell you the correct Swift name to use:

```swift
~/test.swift:12:18: error: 'GIT_OBJECT_BLOB' has been renamed to 'Object.Kind.blob'
let objectType = GIT_OBJECT_BLOB
                 ^~~~~~~~~~~~~~~
                 Object.Kind.blob
```


### Methods & Initializers

Swift supports methods and initializers on types, so this package does too.


### Exclusions

Rote platform/runtime things which C needs (like `str.h`) were skipped because Swift already has a very good way to handle everything those handle (like `String`).

Aside from that, all original (Git-specific) types from libgit2 are included here.



## History

This started in November of 2024 by just copying the C files for libgit2 and translating each one. 
