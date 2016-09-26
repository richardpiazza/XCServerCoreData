//===----------------------------------------------------------------------===//
//
// Extensions.swift
//
// Copyright (c) 2016 Richard Piazza
// https://github.com/richardpiazza/XCServerCoreData
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
//===----------------------------------------------------------------------===//

import Foundation

public extension DateFormatter {
    fileprivate struct XCServerCoreDataDateFormatters {
        static var xcodeServerDateFormatter: DateFormatter {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z'"
            formatter.timeZone = TimeZone(identifier: "GMT")
            return formatter
        }
    }
    
    public static var xcodeServerDateFormatter: DateFormatter {
        return XCServerCoreDataDateFormatters.xcodeServerDateFormatter
    }
}

public extension String {
    /// Replaces a specified prefix string with the provied string.
    mutating public func replace(prefix: String, with: String?) {
        guard hasPrefix(prefix) else {
            return
        }
        
        let range = startIndex..<index(startIndex, offsetBy: prefix.characters.count)
        if let with = with {
            replaceSubrange(range, with: with)
        } else {
            replaceSubrange(range, with: "")
        }
    }
    
    /// Replaces the specified suffix with the provided string.
    mutating public func replace(suffix: String, with: String?) {
        guard hasSuffix(suffix) else {
            return
        }
        
        let range = index(endIndex, offsetBy: -suffix.characters.count)..<endIndex
        if let with = with {
            replaceSubrange(range, with: with)
        } else {
            replaceSubrange(range, with: "")
        }
    }
    
    /// Determines if a character at a given index is a member of the provided character set.
    public func character(atIndex index: Int, isInCharacterSet characterSet: CharacterSet) -> Bool {
        guard index >= 0 && index < self.characters.count else {
            return false
        }
        
        let c = self.utf16[self.utf16.startIndex.advanced(by: index)]
        return characterSet.contains(UnicodeScalar(c)!)
    }
    
    /// ## xcServerTestMethodName
    /// Provides a human-readable form of a method named (in particular XCTest method names).
    /// - example: testPerformSomeAction() -> 'Perform Some Action'
    public var xcServerTestMethodName: String {
        let characterSet = CharacterSet.uppercaseLetters
        
        var result = self
        result.replace(prefix: "test", with: nil)
        result.replace(suffix: "()", with: nil)
        
        for (index, character) in result.characters.enumerated().reversed() {
            guard index > 0 else {
                continue
            }
            
            let thisCharacter = result.character(atIndex: index, isInCharacterSet: characterSet)
            let precedingCharacter = result.character(atIndex: index.advanced(by: -1), isInCharacterSet: characterSet)
            
            if thisCharacter && !precedingCharacter {
                let range = result.characters.index(result.startIndex, offsetBy: index)...result.characters.index(result.startIndex, offsetBy: index)
                result.replaceSubrange(range, with: " \(character)")
            }
        }
        
        return result
    }
}
