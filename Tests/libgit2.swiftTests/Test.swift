//
//  GitStyleIntegerParsingTests.swift
//  libgit2.swift
//
//  Created by Ky on 2025-01-17.
//

import Testing
import Git



@Suite("Git-style parsing tests")
struct GitStyleIntegerParsingTests {
    
    @Test("Basic decimal parsing")
    func testBasicDecimal() throws {
        let cases = [
            "123": Int64(123),
            "+123": Int64(+123),
            "-123": Int64(-123),
            "0": Int64(0),
        ]
        
        for (input, expected) in cases {
            let result = Int64.parse(gitNumberString: input, base: nil)
            #expect(try result.parsed.get() == expected)
        }
    }
    
    
    @Test("Hexadecimal parsing")
    func testHexadecimal() throws {
        let cases = [
            "0xFF": Int64(0xFF),
            "0xff": Int64(0xff),
            "+0xFF": Int64(+0xFF),
            "-0xFF": Int64(-0xFF),
            "+0xff": Int64(+0xff),
            "-0xff": Int64(-0xff),
            "0xDEADBEEF": Int64(0xDEADBEEF),
        ]
        
        for (input, expected) in cases {
            let result = Int64.parse(gitNumberString: input, base: nil)
            #expect(try result.parsed.get() == expected)
        }
    }
    
    
    @Test("Octal parsing")
    func testOctal() throws {
        let cases = [
            "0777": Int64(0o777),
            "0o777": Int64(0o777),
            "+0777": Int64(+0o777),
            "-0777": Int64(-0o777),
        ]
        
        for (input, expected) in cases {
            let result = Int64.parse(gitNumberString: input, base: nil)
            #expect(try result.parsed.get() == expected)
        }
    }
    
    
    @Test("Binary parsing")
    func testBinary() throws {
        let cases = [
            "0b1010": Int64(0b1010),
            "+0b1010": Int64(+0b1010),
            "-0b1010": Int64(-0b1010),
            "0b11111111": Int64(0b11111111),
        ]
        
        for (input, expected) in cases {
            let result = Int64.parse(gitNumberString: input, base: nil)
            #expect(try result.parsed.get() == expected)
        }
    }
    
    
    @Test("Whitespace handling")
    func testWhitespace() throws {
        let cases = [
            " 123": Int64(123),
            "123 ": Int64(123),
            " 123 ": Int64(123),
            "\t123\n": Int64(123),
            "   0xFF   ": Int64(0xFF),
        ]
        
        for (input, expected) in cases {
            let result = Int64.parse(gitNumberString: input, base: nil)
            #expect(try result.parsed.get() == expected)
        }
    }
    
    
    @Test("Explicit base handling")
    func testExplicitBase() throws {
        struct Input: Hashable {
            let unparsed: String
            let base: UInt8
            
            init(_ unparsed: String, _ base: UInt8) {
                self.unparsed = unparsed
                self.base = base
            }
        }
        
        
        
        let testCases = [
            Input("FF",      UInt8(16)): Int64(0xFF),
            Input("777",     UInt8(8)):  Int64(0o777),
            Input("1010",    UInt8(2)):  Int64(0b1010),
            Input("Zapatos", UInt8(32)): Int64(0),
            Input("ZZ",      UInt8(36)): nil,  // Should fail - base > 32
        ]
        
        for (input, expected) in testCases {
            let (input, base) = (input.unparsed, input.base)
            let result = Int64.parse(gitNumberString: input, base: base)
            if let expected {
                #expect(try result.parsed.get() == expected)
            } else {
                #expect(throws: GitError.self, performing: result.parsed.get)
            }
        }
    }
    
    
    @Test("Error cases")
    func testErrors() throws {
        let errorCases = [
            "",                 // Empty string
            " ",                // Only whitespace
            "abc",              // Invalid characters
            "12.34",            // Decimal point
            "0x", "-0x", "+0x", // Incomplete hex
            "0b", "-0b", "+0b", // Incomplete binary
            "0o", "-0o", "+0o", // Incomplete octal
            "+",                // Only sign
            "-",                // Only sign
            "9999999999999999999999999"  // Overflow
        ]
        
        for input in errorCases {
            let result = Int64.parse(gitNumberString: input, base: nil)
            #expect(throws: GitError.self, performing: result.parsed.get)
        }
    }
    
    
    @Test("Parse range validation")
    func testParseRange() throws {
        let testCases = [
            "123abc": "123",
            "0xFF!!": "0xFF",
            "-0b1010xyz": "-0b1010",
            "512M" : "512",
        ]
        
        for (input, expectedParsed) in testCases {
            let result = Int64.parse(gitNumberString: input, base: nil)
            let parsedSubstring = input[result.parseRange]
            #expect(String(parsedSubstring) == expectedParsed)
        }
    }
}



extension GitStyleIntegerParsingTests {
    
    @Test("Basic • Int8")
    func basic_int8() throws {
        #expect(throws: GitError.self, performing: try Int8.parse(gitNumberString: "-129", base: nil).parsed.get)
        #expect(try Int8.parse(gitNumberString: "-128", base: nil).parsed.get() == -128)
        #expect(try Int8.parse(gitNumberString: "-127", base: nil).parsed.get() == -127)
        #expect(try Int8.parse(gitNumberString: "-123", base: nil).parsed.get() == -123)
        #expect(try Int8.parse(gitNumberString: "-1",   base: nil).parsed.get() == -1)
        #expect(try Int8.parse(gitNumberString: "-0",   base: nil).parsed.get() == 0)
        #expect(try Int8.parse(gitNumberString: "0",    base: nil).parsed.get() == 0)
        #expect(try Int8.parse(gitNumberString: "+0",   base: nil).parsed.get() == 0)
        #expect(try Int8.parse(gitNumberString: "+1",   base: nil).parsed.get() == 1)
        #expect(try Int8.parse(gitNumberString: "1",    base: nil).parsed.get() == 1)
        #expect(try Int8.parse(gitNumberString: "123",  base: nil).parsed.get() == 123)
        #expect(try Int8.parse(gitNumberString: "127",  base: nil).parsed.get() == 127)
        #expect(throws: GitError.self, performing: try Int8.parse(gitNumberString: "128", base: nil).parsed.get)
        
        for testNumber in Int8.min...Int8.max {
            #expect(try Int8.parse(gitNumberString: testNumber.description, base: nil).parsed.get() == testNumber)
            #expect(try Int8.parse(gitNumberString: testNumber.description, base: 10).parsed.get()  == testNumber)
        }
    }
    
    
    @Test("Basic • Int16")
    func basic_int16() throws {
        #expect(throws: GitError.self, performing: try Int16.parse(gitNumberString: "-32769", base: nil).parsed.get)
        #expect(try Int16.parse(gitNumberString: "-32768", base: nil).parsed.get() == -32768)
        #expect(try Int16.parse(gitNumberString: "-32767", base: nil).parsed.get() == -32767)
        #expect(try Int16.parse(gitNumberString: "-12345", base: nil).parsed.get() == -12345)
        #expect(try Int16.parse(gitNumberString: "-129",   base: nil).parsed.get() == -129)
        #expect(try Int16.parse(gitNumberString: "-128",   base: nil).parsed.get() == -128)
        #expect(try Int16.parse(gitNumberString: "-127",   base: nil).parsed.get() == -127)
        #expect(try Int16.parse(gitNumberString: "-123",   base: nil).parsed.get() == -123)
        #expect(try Int16.parse(gitNumberString: "-1",     base: nil).parsed.get() == -1)
        #expect(try Int16.parse(gitNumberString: "-0",     base: nil).parsed.get() == 0)
        #expect(try Int16.parse(gitNumberString: "0",      base: nil).parsed.get() == 0)
        #expect(try Int16.parse(gitNumberString: "+0",     base: nil).parsed.get() == 0)
        #expect(try Int16.parse(gitNumberString: "+1",     base: nil).parsed.get() == 1)
        #expect(try Int16.parse(gitNumberString: "1",      base: nil).parsed.get() == 1)
        #expect(try Int16.parse(gitNumberString: "123",    base: nil).parsed.get() == 123)
        #expect(try Int16.parse(gitNumberString: "127",    base: nil).parsed.get() == 127)
        #expect(try Int16.parse(gitNumberString: "128",    base: nil).parsed.get() == 128)
        #expect(try Int16.parse(gitNumberString: "12345",  base: nil).parsed.get() == 12345)
        #expect(try Int16.parse(gitNumberString: "32767",  base: nil).parsed.get() == 32767)
        #expect(throws: GitError.self, performing: try Int16.parse(gitNumberString: "32768", base: nil).parsed.get)
        
        for testNumber in Int16.min...Int16.max {
            #expect(try Int16.parse(gitNumberString: testNumber.description, base: nil).parsed.get() == testNumber)
            #expect(try Int16.parse(gitNumberString: testNumber.description, base: 10).parsed.get()  == testNumber)
        }
    }
    
    
    @Test("Basic • Int32")
    func basic_int32() throws {
        #expect(throws: GitError.self, performing: try Int32.parse(gitNumberString: "-2147483649", base: nil).parsed.get)
        #expect(try Int32.parse(gitNumberString: "-2147483648", base: nil).parsed.get() == -2147483648)
        #expect(try Int32.parse(gitNumberString: "-2147483647", base: nil).parsed.get() == -2147483647)
        #expect(try Int32.parse(gitNumberString: "-1234567890", base: nil).parsed.get() == -1234567890)
        #expect(try Int32.parse(gitNumberString: "-32769",      base: nil).parsed.get() == -32769)
        #expect(try Int32.parse(gitNumberString: "-32768",      base: nil).parsed.get() == -32768)
        #expect(try Int32.parse(gitNumberString: "-32767",      base: nil).parsed.get() == -32767)
        #expect(try Int32.parse(gitNumberString: "-12345",      base: nil).parsed.get() == -12345)
        #expect(try Int32.parse(gitNumberString: "-129",        base: nil).parsed.get() == -129)
        #expect(try Int32.parse(gitNumberString: "-128",        base: nil).parsed.get() == -128)
        #expect(try Int32.parse(gitNumberString: "-127",        base: nil).parsed.get() == -127)
        #expect(try Int32.parse(gitNumberString: "-123",        base: nil).parsed.get() == -123)
        #expect(try Int32.parse(gitNumberString: "-1",          base: nil).parsed.get() == -1)
        #expect(try Int32.parse(gitNumberString: "-0",          base: nil).parsed.get() == 0)
        #expect(try Int32.parse(gitNumberString: "0",           base: nil).parsed.get() == 0)
        #expect(try Int32.parse(gitNumberString: "+0",          base: nil).parsed.get() == 0)
        #expect(try Int32.parse(gitNumberString: "+1",          base: nil).parsed.get() == 1)
        #expect(try Int32.parse(gitNumberString: "1",           base: nil).parsed.get() == 1)
        #expect(try Int32.parse(gitNumberString: "123",         base: nil).parsed.get() == 123)
        #expect(try Int32.parse(gitNumberString: "127",         base: nil).parsed.get() == 127)
        #expect(try Int32.parse(gitNumberString: "128",         base: nil).parsed.get() == 128)
        #expect(try Int32.parse(gitNumberString: "12345",       base: nil).parsed.get() == 12345)
        #expect(try Int32.parse(gitNumberString: "32767",       base: nil).parsed.get() == 32767)
        #expect(try Int32.parse(gitNumberString: "32768",       base: nil).parsed.get() == 32768)
        #expect(try Int32.parse(gitNumberString: "1234567890",  base: nil).parsed.get() == 1234567890)
        #expect(try Int32.parse(gitNumberString: "2147483646",  base: nil).parsed.get() == 2147483646)
        #expect(try Int32.parse(gitNumberString: "2147483647",  base: nil).parsed.get() == 2147483647)
        #expect(throws: GitError.self, performing: try Int32.parse(gitNumberString: "2147483648", base: nil).parsed.get)
        
        for testNumber in (0...10000).map({ _ in Int32.random(in: .min ... .max)}) {
            #expect(try Int32.parse(gitNumberString: testNumber.description, base: nil).parsed.get() == testNumber)
            #expect(try Int32.parse(gitNumberString: testNumber.description, base: 10).parsed.get()  == testNumber)
        }
    }
    
    
    @Test("Basic • Int64")
    func basic_int64() throws {
        #expect(throws: GitError.self, performing: try Int64.parse(gitNumberString: "-9223372036854775809", base: nil).parsed.get)
        #expect(try Int64.parse(gitNumberString: "-9223372036854775808", base: nil).parsed.get() == -9223372036854775808)
        #expect(try Int64.parse(gitNumberString: "-9223372036854775807", base: nil).parsed.get() == -9223372036854775807)
        #expect(try Int64.parse(gitNumberString: "-1234567890123456789", base: nil).parsed.get() == -1234567890123456789)
        #expect(try Int64.parse(gitNumberString: "-2147483649",          base: nil).parsed.get() == -2147483649)
        #expect(try Int64.parse(gitNumberString: "-2147483648",          base: nil).parsed.get() == -2147483648)
        #expect(try Int64.parse(gitNumberString: "-2147483647",          base: nil).parsed.get() == -2147483647)
        #expect(try Int64.parse(gitNumberString: "-1234567890",          base: nil).parsed.get() == -1234567890)
        #expect(try Int64.parse(gitNumberString: "-32769",               base: nil).parsed.get() == -32769)
        #expect(try Int64.parse(gitNumberString: "-32768",               base: nil).parsed.get() == -32768)
        #expect(try Int64.parse(gitNumberString: "-32767",               base: nil).parsed.get() == -32767)
        #expect(try Int64.parse(gitNumberString: "-12345",               base: nil).parsed.get() == -12345)
        #expect(try Int64.parse(gitNumberString: "-129",                 base: nil).parsed.get() == -129)
        #expect(try Int64.parse(gitNumberString: "-128",                 base: nil).parsed.get() == -128)
        #expect(try Int64.parse(gitNumberString: "-127",                 base: nil).parsed.get() == -127)
        #expect(try Int64.parse(gitNumberString: "-123",                 base: nil).parsed.get() == -123)
        #expect(try Int64.parse(gitNumberString: "-1",                   base: nil).parsed.get() == -1)
        #expect(try Int64.parse(gitNumberString: "-0",                   base: nil).parsed.get() == 0)
        #expect(try Int64.parse(gitNumberString: "0",                    base: nil).parsed.get() == 0)
        #expect(try Int64.parse(gitNumberString: "+0",                   base: nil).parsed.get() == 0)
        #expect(try Int64.parse(gitNumberString: "+1",                   base: nil).parsed.get() == 1)
        #expect(try Int64.parse(gitNumberString: "1",                    base: nil).parsed.get() == 1)
        #expect(try Int64.parse(gitNumberString: "123",                  base: nil).parsed.get() == 123)
        #expect(try Int64.parse(gitNumberString: "127",                  base: nil).parsed.get() == 127)
        #expect(try Int64.parse(gitNumberString: "128",                  base: nil).parsed.get() == 128)
        #expect(try Int64.parse(gitNumberString: "12345",                base: nil).parsed.get() == 12345)
        #expect(try Int64.parse(gitNumberString: "32767",                base: nil).parsed.get() == 32767)
        #expect(try Int64.parse(gitNumberString: "32768",                base: nil).parsed.get() == 32768)
        #expect(try Int64.parse(gitNumberString: "1234567890",           base: nil).parsed.get() == 1234567890)
        #expect(try Int64.parse(gitNumberString: "2147483646",           base: nil).parsed.get() == 2147483646)
        #expect(try Int64.parse(gitNumberString: "2147483647",           base: nil).parsed.get() == 2147483647)
        #expect(try Int64.parse(gitNumberString: "1234567890123456789", base: nil).parsed.get() == 1234567890123456789)
        #expect(try Int64.parse(gitNumberString: "9223372036854775806", base: nil).parsed.get() == 9223372036854775806)
        #expect(try Int64.parse(gitNumberString: "9223372036854775807", base: nil).parsed.get() == 9223372036854775807)
        #expect(throws: GitError.self, performing: try Int64.parse(gitNumberString: "9223372036854775808", base: nil).parsed.get)
        
        for testNumber in (0...10000).map({ _ in Int64.random(in: .min ... .max)}) {
            #expect(try Int64.parse(gitNumberString: testNumber.description, base: nil).parsed.get() == testNumber)
            #expect(try Int64.parse(gitNumberString: testNumber.description, base: 10).parsed.get()  == testNumber)
        }
    }
    
    
    @Test("Basic • Int128")
    @available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
    func basic_int128() throws {
        #expect(throws: GitError.self, performing: try Int128.parse(gitNumberString: "-170141183460469231731687303715884105729", base: nil).parsed.get)
        #expect(try Int128.parse(gitNumberString: "-170141183460469231731687303715884105728", base: nil).parsed.get() == -170141183460469231731687303715884105728)
        #expect(try Int128.parse(gitNumberString: "-170141183460469231731687303715884105727", base: nil).parsed.get() == -170141183460469231731687303715884105727)
        #expect(try Int128.parse(gitNumberString: "-123456789012345678901234567890123456789", base: nil).parsed.get() == -123456789012345678901234567890123456789)
        #expect(try Int128.parse(gitNumberString: "-9223372036854775808", base: nil).parsed.get() == -9223372036854775808)
        #expect(try Int128.parse(gitNumberString: "-9223372036854775807", base: nil).parsed.get() == -9223372036854775807)
        #expect(try Int128.parse(gitNumberString: "-1234567890123456789", base: nil).parsed.get() == -1234567890123456789)
        #expect(try Int128.parse(gitNumberString: "-2147483649",          base: nil).parsed.get() == -2147483649)
        #expect(try Int128.parse(gitNumberString: "-2147483648",          base: nil).parsed.get() == -2147483648)
        #expect(try Int128.parse(gitNumberString: "-2147483647",          base: nil).parsed.get() == -2147483647)
        #expect(try Int128.parse(gitNumberString: "-1234567890",          base: nil).parsed.get() == -1234567890)
        #expect(try Int128.parse(gitNumberString: "-32769",               base: nil).parsed.get() == -32769)
        #expect(try Int128.parse(gitNumberString: "-32768",               base: nil).parsed.get() == -32768)
        #expect(try Int128.parse(gitNumberString: "-32767",               base: nil).parsed.get() == -32767)
        #expect(try Int128.parse(gitNumberString: "-12345",               base: nil).parsed.get() == -12345)
        #expect(try Int128.parse(gitNumberString: "-129",                 base: nil).parsed.get() == -129)
        #expect(try Int128.parse(gitNumberString: "-128",                 base: nil).parsed.get() == -128)
        #expect(try Int128.parse(gitNumberString: "-127",                 base: nil).parsed.get() == -127)
        #expect(try Int128.parse(gitNumberString: "-123",                 base: nil).parsed.get() == -123)
        #expect(try Int128.parse(gitNumberString: "-1",                   base: nil).parsed.get() == -1)
        #expect(try Int128.parse(gitNumberString: "-0",                   base: nil).parsed.get() == 0)
        #expect(try Int128.parse(gitNumberString: "0",                    base: nil).parsed.get() == 0)
        #expect(try Int128.parse(gitNumberString: "+0",                   base: nil).parsed.get() == 0)
        #expect(try Int128.parse(gitNumberString: "+1",                   base: nil).parsed.get() == 1)
        #expect(try Int128.parse(gitNumberString: "1",                    base: nil).parsed.get() == 1)
        #expect(try Int128.parse(gitNumberString: "123",                  base: nil).parsed.get() == 123)
        #expect(try Int128.parse(gitNumberString: "127",                  base: nil).parsed.get() == 127)
        #expect(try Int128.parse(gitNumberString: "128",                  base: nil).parsed.get() == 128)
        #expect(try Int128.parse(gitNumberString: "12345",                base: nil).parsed.get() == 12345)
        #expect(try Int128.parse(gitNumberString: "32767",                base: nil).parsed.get() == 32767)
        #expect(try Int128.parse(gitNumberString: "32768",                base: nil).parsed.get() == 32768)
        #expect(try Int128.parse(gitNumberString: "1234567890",           base: nil).parsed.get() == 1234567890)
        #expect(try Int128.parse(gitNumberString: "2147483646",           base: nil).parsed.get() == 2147483646)
        #expect(try Int128.parse(gitNumberString: "2147483647",           base: nil).parsed.get() == 2147483647)
        #expect(try Int128.parse(gitNumberString: "1234567890123456789", base: nil).parsed.get() == 1234567890123456789)
        #expect(try Int128.parse(gitNumberString: "9223372036854775806", base: nil).parsed.get() == 9223372036854775806)
        #expect(try Int128.parse(gitNumberString: "9223372036854775807", base: nil).parsed.get() == 9223372036854775807)
        #expect(try Int128.parse(gitNumberString: "123456789012345678901234567890123456789", base: nil).parsed.get() == 123456789012345678901234567890123456789)
        #expect(try Int128.parse(gitNumberString: "170141183460469231731687303715884105726", base: nil).parsed.get() == 170141183460469231731687303715884105726)
        #expect(try Int128.parse(gitNumberString: "170141183460469231731687303715884105727", base: nil).parsed.get() == 170141183460469231731687303715884105727)
        #expect(throws: GitError.self, performing: try Int128.parse(gitNumberString: "170141183460469231731687303715884105728", base: nil).parsed.get)
        
        for testNumber in (0...10000).map({ _ in Int128.random(in: .min ... .max)}) {
            #expect(try Int64.parse(gitNumberString: testNumber.description, base: nil).parsed.get() == testNumber)
            #expect(try Int64.parse(gitNumberString: testNumber.description, base: 10).parsed.get()  == testNumber)
        }
    }
    
    
    @Test("Basic • UInt8")
    func basic_uint8() throws {
        #expect(throws: GitError.self, performing: try UInt8.parse(gitNumberString: "-1", base: nil).parsed.get)
        #expect(try UInt8.parse(gitNumberString: "-0",   base: nil).parsed.get() == 0)
        #expect(try UInt8.parse(gitNumberString: "0",    base: nil).parsed.get() == 0)
        #expect(try UInt8.parse(gitNumberString: "+0",   base: nil).parsed.get() == 0)
        #expect(try UInt8.parse(gitNumberString: "+1",   base: nil).parsed.get() == 1)
        #expect(try UInt8.parse(gitNumberString: "1",    base: nil).parsed.get() == 1)
        #expect(try UInt8.parse(gitNumberString: "123",  base: nil).parsed.get() == 123)
        #expect(try UInt8.parse(gitNumberString: "127",  base: nil).parsed.get() == 127)
        #expect(try UInt8.parse(gitNumberString: "128",  base: nil).parsed.get() == 128)
        #expect(try UInt8.parse(gitNumberString: "129",  base: nil).parsed.get() == 129)
        #expect(try UInt8.parse(gitNumberString: "254",  base: nil).parsed.get() == 254)
        #expect(try UInt8.parse(gitNumberString: "255",  base: nil).parsed.get() == 255)
        #expect(throws: GitError.self, performing: try UInt8.parse(gitNumberString: "256", base: nil).parsed.get)
        
        for testNumber in UInt8.min...UInt8.max {
            #expect(try UInt8.parse(gitNumberString: testNumber.description, base: nil).parsed.get() == testNumber)
            #expect(try UInt8.parse(gitNumberString: testNumber.description, base: 10).parsed.get()  == testNumber)
        }
    }
    
    
    @Test("Basic • UInt16")
    func basic_uint16() throws {
        #expect(throws: GitError.self, performing: try UInt16.parse(gitNumberString: "-1", base: nil).parsed.get)
        #expect(try UInt16.parse(gitNumberString: "-0",     base: nil).parsed.get() == 0)
        #expect(try UInt16.parse(gitNumberString: "0",      base: nil).parsed.get() == 0)
        #expect(try UInt16.parse(gitNumberString: "+0",     base: nil).parsed.get() == 0)
        #expect(try UInt16.parse(gitNumberString: "+1",     base: nil).parsed.get() == 1)
        #expect(try UInt16.parse(gitNumberString: "1",      base: nil).parsed.get() == 1)
        #expect(try UInt16.parse(gitNumberString: "123",    base: nil).parsed.get() == 123)
        #expect(try UInt16.parse(gitNumberString: "127",    base: nil).parsed.get() == 127)
        #expect(try UInt16.parse(gitNumberString: "128",    base: nil).parsed.get() == 128)
        #expect(try UInt16.parse(gitNumberString: "254",    base: nil).parsed.get() == 254)
        #expect(try UInt16.parse(gitNumberString: "255",    base: nil).parsed.get() == 255)
        #expect(try UInt16.parse(gitNumberString: "256",    base: nil).parsed.get() == 256)
        #expect(try UInt16.parse(gitNumberString: "257",    base: nil).parsed.get() == 257)
        #expect(try UInt16.parse(gitNumberString: "12345",  base: nil).parsed.get() == 12345)
        #expect(try UInt16.parse(gitNumberString: "32767",  base: nil).parsed.get() == 32767)
        #expect(try UInt16.parse(gitNumberString: "32768",  base: nil).parsed.get() == 32768)
        #expect(try UInt16.parse(gitNumberString: "32769",  base: nil).parsed.get() == 32769)
        #expect(try UInt16.parse(gitNumberString: "65534",  base: nil).parsed.get() == 65534)
        #expect(try UInt16.parse(gitNumberString: "65535",  base: nil).parsed.get() == 65535)
        #expect(throws: GitError.self, performing: try UInt16.parse(gitNumberString: "65536", base: nil).parsed.get)
        
        for testNumber in UInt16.min...UInt16.max {
            #expect(try UInt16.parse(gitNumberString: testNumber.description, base: nil).parsed.get() == testNumber)
            #expect(try UInt16.parse(gitNumberString: testNumber.description, base: 10).parsed.get()  == testNumber)
        }
    }
    
    
    @Test("Basic • UInt32")
    func basic_uint32() throws {
        #expect(throws: GitError.self, performing: try UInt32.parse(gitNumberString: "-1", base: nil).parsed.get)
        #expect(try UInt32.parse(gitNumberString: "-0",          base: nil).parsed.get() == 0)
        #expect(try UInt32.parse(gitNumberString: "0",           base: nil).parsed.get() == 0)
        #expect(try UInt32.parse(gitNumberString: "+0",          base: nil).parsed.get() == 0)
        #expect(try UInt32.parse(gitNumberString: "+1",          base: nil).parsed.get() == 1)
        #expect(try UInt32.parse(gitNumberString: "1",           base: nil).parsed.get() == 1)
        #expect(try UInt32.parse(gitNumberString: "123",         base: nil).parsed.get() == 123)
        #expect(try UInt32.parse(gitNumberString: "127",         base: nil).parsed.get() == 127)
        #expect(try UInt32.parse(gitNumberString: "128",         base: nil).parsed.get() == 128)
        #expect(try UInt32.parse(gitNumberString: "12345",       base: nil).parsed.get() == 12345)
        #expect(try UInt32.parse(gitNumberString: "32767",       base: nil).parsed.get() == 32767)
        #expect(try UInt32.parse(gitNumberString: "32768",       base: nil).parsed.get() == 32768)
        #expect(try UInt32.parse(gitNumberString: "1234567890",  base: nil).parsed.get() == 1234567890)
        #expect(try UInt32.parse(gitNumberString: "2147483646",  base: nil).parsed.get() == 2147483646)
        #expect(try UInt32.parse(gitNumberString: "2147483647",  base: nil).parsed.get() == 2147483647)
        #expect(try UInt32.parse(gitNumberString: "2147483647",  base: nil).parsed.get() == 2147483648)
        #expect(try UInt32.parse(gitNumberString: "4294967294",  base: nil).parsed.get() == 4294967294)
        #expect(try UInt32.parse(gitNumberString: "4294967295",  base: nil).parsed.get() == 4294967295)
        #expect(throws: GitError.self, performing: try UInt32.parse(gitNumberString: "4294967296", base: nil).parsed.get)
        
        for testNumber in (0...10000).map({ _ in UInt32.random(in: .min ... .max)}) {
            #expect(try UInt32.parse(gitNumberString: testNumber.description, base: nil).parsed.get() == testNumber)
            #expect(try UInt32.parse(gitNumberString: testNumber.description, base: 10).parsed.get()  == testNumber)
        }
    }
    
    
    @Test("Basic • UInt64")
    func basic_uint64() throws {
        #expect(throws: GitError.self, performing: try UInt64.parse(gitNumberString: "-1", base: nil).parsed.get)
        #expect(try UInt64.parse(gitNumberString: "-0",                   base: nil).parsed.get() == 0)
        #expect(try UInt64.parse(gitNumberString: "0",                    base: nil).parsed.get() == 0)
        #expect(try UInt64.parse(gitNumberString: "+0",                   base: nil).parsed.get() == 0)
        #expect(try UInt64.parse(gitNumberString: "+1",                   base: nil).parsed.get() == 1)
        #expect(try UInt64.parse(gitNumberString: "1",                    base: nil).parsed.get() == 1)
        #expect(try UInt64.parse(gitNumberString: "123",                  base: nil).parsed.get() == 123)
        #expect(try UInt64.parse(gitNumberString: "127",                  base: nil).parsed.get() == 127)
        #expect(try UInt64.parse(gitNumberString: "128",                  base: nil).parsed.get() == 128)
        #expect(try UInt64.parse(gitNumberString: "12345",                base: nil).parsed.get() == 12345)
        #expect(try UInt64.parse(gitNumberString: "32767",                base: nil).parsed.get() == 32767)
        #expect(try UInt64.parse(gitNumberString: "32768",                base: nil).parsed.get() == 32768)
        #expect(try UInt64.parse(gitNumberString: "1234567890",           base: nil).parsed.get() == 1234567890)
        #expect(try UInt64.parse(gitNumberString: "2147483646",           base: nil).parsed.get() == 2147483646)
        #expect(try UInt64.parse(gitNumberString: "2147483647",           base: nil).parsed.get() == 2147483647)
        #expect(try UInt64.parse(gitNumberString: "1234567890123456789",  base: nil).parsed.get() == 1234567890123456789)
        #expect(try UInt64.parse(gitNumberString: "9223372036854775806",  base: nil).parsed.get() == 9223372036854775806)
        #expect(try UInt64.parse(gitNumberString: "9223372036854775807",  base: nil).parsed.get() == 9223372036854775807)
        #expect(try UInt64.parse(gitNumberString: "9223372036854775808",  base: nil).parsed.get() == 9223372036854775808)
        #expect(try UInt64.parse(gitNumberString: "18446744073709551614", base: nil).parsed.get() == 18446744073709551614)
        #expect(try UInt64.parse(gitNumberString: "18446744073709551615", base: nil).parsed.get() == 18446744073709551615)
        #expect(throws: GitError.self, performing: try UInt64.parse(gitNumberString: "18446744073709551616", base: nil).parsed.get)
        
        for testNumber in (0...10000).map({ _ in UInt64.random(in: .min ... .max)}) {
            #expect(try UInt64.parse(gitNumberString: testNumber.description, base: nil).parsed.get() == testNumber)
            #expect(try UInt64.parse(gitNumberString: testNumber.description, base: 10).parsed.get()  == testNumber)
        }
    }
    
    
    @Test("Basic • UInt128")
    @available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
    func basic_uint128() throws {
        #expect(throws: GitError.self, performing: try UInt128.parse(gitNumberString: "-1", base: nil).parsed.get)
        #expect(try UInt128.parse(gitNumberString: "-0",                   base: nil).parsed.get() == 0)
        #expect(try UInt128.parse(gitNumberString: "0",                    base: nil).parsed.get() == 0)
        #expect(try UInt128.parse(gitNumberString: "+0",                   base: nil).parsed.get() == 0)
        #expect(try UInt128.parse(gitNumberString: "+1",                   base: nil).parsed.get() == 1)
        #expect(try UInt128.parse(gitNumberString: "1",                    base: nil).parsed.get() == 1)
        #expect(try UInt128.parse(gitNumberString: "123",                  base: nil).parsed.get() == 123)
        #expect(try UInt128.parse(gitNumberString: "127",                  base: nil).parsed.get() == 127)
        #expect(try UInt128.parse(gitNumberString: "128",                  base: nil).parsed.get() == 128)
        #expect(try UInt128.parse(gitNumberString: "12345",                base: nil).parsed.get() == 12345)
        #expect(try UInt128.parse(gitNumberString: "32767",                base: nil).parsed.get() == 32767)
        #expect(try UInt128.parse(gitNumberString: "32768",                base: nil).parsed.get() == 32768)
        #expect(try UInt128.parse(gitNumberString: "1234567890",           base: nil).parsed.get() == 1234567890)
        #expect(try UInt128.parse(gitNumberString: "2147483646",           base: nil).parsed.get() == 2147483646)
        #expect(try UInt128.parse(gitNumberString: "2147483647",           base: nil).parsed.get() == 2147483647)
        #expect(try UInt128.parse(gitNumberString: "1234567890123456789", base: nil).parsed.get() == 1234567890123456789)
        #expect(try UInt128.parse(gitNumberString: "9223372036854775806", base: nil).parsed.get() == 9223372036854775806)
        #expect(try UInt128.parse(gitNumberString: "9223372036854775807", base: nil).parsed.get() == 9223372036854775807)
        #expect(try UInt128.parse(gitNumberString: "123456789012345678901234567890123456789", base: nil).parsed.get() == 123456789012345678901234567890123456789)
        #expect(try UInt128.parse(gitNumberString: "170141183460469231731687303715884105726", base: nil).parsed.get() == 170141183460469231731687303715884105726)
        #expect(try UInt128.parse(gitNumberString: "170141183460469231731687303715884105727", base: nil).parsed.get() == 170141183460469231731687303715884105727)
        #expect(try UInt128.parse(gitNumberString: "340282366920938463463374607431768211454", base: nil).parsed.get() == 340282366920938463463374607431768211454)
        #expect(try UInt128.parse(gitNumberString: "340282366920938463463374607431768211455", base: nil).parsed.get() == 340282366920938463463374607431768211455)
        #expect(throws: GitError.self, performing: try UInt128.parse(gitNumberString: "340282366920938463463374607431768211456", base: nil).parsed.get)
        
        for testNumber in (0...10000).map({ _ in UInt128.random(in: .min ... .max)}) {
            #expect(try UInt64.parse(gitNumberString: testNumber.description, base: nil).parsed.get() == testNumber)
            #expect(try UInt64.parse(gitNumberString: testNumber.description, base: 10).parsed.get()  == testNumber)
        }
    }
}
