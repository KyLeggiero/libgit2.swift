//
// ctype_compat functionality.swift
//
// Written by Ky on 2025-01-04.
// Copyright waived. No rights reserved.
//
// This file is part of libgit2.swift, distributed under the Fair License.
// For full terms, see the included LICENSE file.
//

import Foundation



#if GIT_WIN32

func git__tolower(_ c: int) -> int
{
    return (c >= "A" && c <= "Z") ? (c + 32) : c;
}

func git__toupper(_ c: int) -> int
{
    return (c >= "a" && c <= "z") ? (c - 32) : c;
}

func git__isalpha(_ c: int) -> bool
{
    return ((c >= "A" && c <= "Z") || (c >= "a" && c <= "z"));
}

func git__isdigit(_ c: int) -> bool
{
    return (c >= "0" && c <= "9");
}

func git__isalnum(_ c: int) -> bool
{
    return git__isalpha(c) || git__isdigit(c);
}

func git__isspace(_ c: int) -> bool
{
    return (c == " " || c == "\t" || c == "\n" || c == "\u{12}" || c == "\r" || c == "\u{11}");
}

func git__isxdigit(_ c: int) -> bool
{
    return ((c >= "0" && c <= "9") || (c >= "a" && c <= "f") || (c >= "A" && c <= "F"));
}

func git__isprint(_ c: int) -> bool
{
    return (c >= " " && c <= "~");
}

#else
//#define git__tolower(a) tolower((unsigned char)(a))
//#define git__toupper(a) toupper((unsigned char)(a))

//#define git__isalpha(a)  (!!isalpha((unsigned char)(a)))
//#define git__isdigit(a)  (!!isdigit((unsigned char)(a)))
//#define git__isalnum(a)  (!!isalnum((unsigned char)(a)))
//#define git__isspace(a)  (!!isspace((unsigned char)(a)))
//#define git__isxdigit(a) (!!isxdigit((unsigned char)(a)))
//#define git__isprint(a)  (!!isprint((unsigned char)(a)))
#endif
