#  Types

This folder contains just the types (structs, enums, et al) and their fields. Functionality is in the `Functionality` folder.

Each file mirrors its C equivalent in libgit2, containing only types contained in the same-named `.h`/`.c`/etc. files in libgit2.



## File Structure

The files have the types/fields you should use at the top, and old types/fields at the bottom as aliases with `unavailable` migration directives, like this:

```swift
public struct NewTypename: AnyStructProtocol {
    public var newField: NewFieldType 
}



// MARK: - Migrated

@available(*, unavailable, renamed: "NewTypename")
typealias git_old_t = NewTypename



public extension NewTypename {
    @available(*, unavailable, renamed: "old_field")
    var old_field: old_field_t { fatalError("use newField") } // This is okay because you cannot even compile a program that uses old_field
}
```

This allows you to write code with the new Swift types, even if you are used to working with the old C types (or if you're using a libgit2 tutorial/etc.).

The placement in the file also reduces clutter, separating "here's what you're using" from "here's how it was done in libgit2".

This also functions as a bit of documentation: "Here's how things were done in libgit2, and here's how they're done here in libgit2.swift". That can help fill gaps in understanding.
