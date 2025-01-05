#  libgit2.swift

A reimplementation of [libgit2](https://github.com/libgit2/libgit2) in Swift.

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


### Error translation

libgit2 signifies error conditions with functions which return negative numbers, like this:

```c
// libgit2

int git_old_style(void)
{
    if (git_setup_operation() < 0 ||
        git_process_operation() < 0)
        return -1;

    return 0;
}
```

Because Swift has an error-handling system, that's used instead. So wherever a number is returned solely to communicate an error condition, the function throws instead:

```swift
// libgit2.swift

func newStyle() throws(GitError) {
    try setupOperation()
    try processOperation()
}
```


#### Side-channel errors

libgit2 also includes side-channel errors. That is to say, sometimes it will return a negative number to signify that an error has occurred, and then set a global error variable.

This is a common C pattern (see also: `errno`), because C does not have any built-in error handling mechanism.
Since Swift _does_ have a built-in error-handling mechanism in the form of `throw`/`catch`/`try`/etc., libgit2.swift uses that instead. This means that the side-channel error handling is removed from this package, in favor of Swift builtin error handling.

That will mostly work exactly the same. It will often include more information for recovery, as well (e.g. stack traces).

However, there are some situations where it won't work the same. For example, there are situations in libgit2 where it sets that side-channel error, but _does not return a negative number_. This can be seen with the macro `GIT_ASSERT_WITH_RETVAL` and its ilk, which sav an error value to that side channel if some value is `null`, and then set that missing value to be a backup value and continue with the program instead of returning.

In libgit2.swift, these situations do not set any such error, but otherwise behave the same.


#### Fewer errors???

You might start using this and notice that some functions which "throw errors" in libgit2 (e.g. return `-1`) aren't marked as `throws` in libgit2.swift.

Perhaps you're worried that this means libgit2.swift ignores these errors and might crash if it encounters those branches. Worry not; this isn't dangerous, it's intentional and happy!
As it turns out, a lot of those errors libgit2 handles simply aren't possible in Swift.

For example, because libgit2 is platform-agnostic, it comes with nearly everything it needs, which means it implements most of the features it uses which are traditionally platform features. That means that things like variable-length arrays aren't used in libgit2, so all the arrays whose contents vary in amount are actually static-length arrays with some checks to see what the most-recently-added item's index is. So those will return `-1` if you try to add more values than it was compiled to handle.

Swift, however, has dynamic-length arrays built-in! So no such error would be thrown. So any functions where that's the only reason it would return an error code, instead always succeed!

That also means that libtit2.swift can handle some edge cases libgit2 can't, since it won't fail to handle operations which stack more items into these arrays.



### Hash algorithms

libgit2 uses SHA-1 as the default hash algorithm, and chooses various backends to perform hashing operations with, depending on the platform. 
It also hides SHA-256 behind compiler flags... mostly. 

This package always allows SHA-256, with no flags to disable/hide it.
This package also chooses _only_ CommonCrypto as the hash creation backend for all hashes.



### Strings

libgit2.swift uses the Swift native `String` type wherever the concpet of a text string exists in libgit.
Anywhere there's' a `char *`, a `git_str`, or any other text string concept, is replaced with `String`.

That means that all strings throughout this library support full Unicode and all the other fancy things Swift strings support.

That means that some places where libgit2 might handle Unicode strings (e.g. UTF-8) could either fail or produce unexpected/undefined behavior, but in libgit2.swift they work correctly. For example, if a filename has characters which use multiple bytes (like 한), libgit2 would miscount the number of bytes as the nubmer of characters, but libgit2.swift correctly counts the number of characters.



### Runtime

libgit2 implements & ships with its own runtime. libgit2.swift instead opts to use Swift's builtin runtime.

This means that rote platform/runtime things which C needs (like arrays, allocating/freeing memory, etc.) were skipped because Swift already has a very good way to handle everything those handle.

Aside from that, all original (Git-specific) types from libgit2 are included here, mostly with Swifty names.



### Copy-on-Write

libgit2 (and most C code) uses pointers to pass around a value without having to copy it each time. 

Swift has a runtime subsystem to allow this to happen with pure-value-types (like `struct`s), providing the semantics & behavior of copying it each time but not actually copying until one of those is written to.

A non-pointer value in C (like `struct my_struct`) can be thought of as a value type, and a pointer to that value (like `my_struct*`) can be thought of as a reference type.

In Swift, value vs reference are implemented as distinct kinds of types. Values are `enum`/`struct`/etc. and references are `class`/`actor`.

This library foregoes using reference types unless absolutely necessary.



### Randomness

libgit2 provides public functionality to specifically seed its random number generator, allowing for deterministic pseudo-randomness.

libgit2.swift does not provide this functionality, instead using Swift's builtin random subsystem (which automatically stirs/seeds the random number generator), resulting in non-deterministic pseudo-randomness (or true randomness, depending on the implementation used).



### Deprecation

There are parts of libgit2 which are deprecated (e.g. under `git2/deprecated.h` andor marked `GIT_DEPRECATE_HARD`).

These are not included in libgit2.swift, under the assumption that they were deprecated with good reason and that the maintainers of libgit2 would like to remove them.

That is to say, anything wrapped in a `#ifdef GIT_DEPRECATE_HARD` is included, and anything wrapped in `#ifndef GIT_DEPRECATE_HARD` is excluded from this library.



### Documentation

If documentation is missing, that's because libgit2 didn't have any. Fuckers.

We tried to fill in the blanks where We could.

If you see doc comments like `/**` then you know it's almost entirely from the original C library.
If it's like `///` then you know We rewrote that doc comment, so it's more correct for this package.

The same (usually) goes for `/*` and `//` inline comments.



## Windows

No Windows support yet, sadly. Putting in a bunch of placeholder Windows code but won't be able to make sure it compiles & runs on Windows til We have a Windows machine to test it on.



## Feedback

If you have an improvement idea, or just feel strongly about any of the decisions which cause this package to diverge from libgit2 (for example, using platform randomness and denying deterministic PRNG), please file an issue at https://github.com/KyLeggiero/libgit2.swift/issues/new/choose



## History

This started in November of 2024 by just copying the C files for libgit2 and translating each one. 
