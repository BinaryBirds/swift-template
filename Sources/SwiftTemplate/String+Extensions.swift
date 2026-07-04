//
//  String+CapitalizedFirstCharacter.swift
//  SwiftTemplate
//
//  Created by Tibor Bodecs on 2021. 02. 12..
//

#if canImport(FoundationEssentials)
import FoundationEssentials
#if canImport(Foundation)
import Foundation
#endif
#else
import Foundation
#endif

extension String {

    /**
     Converts the first letter of the string to an upper case letter

     The remaining characters of the String will be unchanged.

     - returns: The string with a capitalized first letter
     */
    var capitalizedFirstCharacter: String {
        guard count > 1 else {
            return capitalized
        }
        let startIndex = index(startIndex, offsetBy: 1)
        let begin = self[..<startIndex]
        let end = self[startIndex...]
        let first = begin.uppercased()
        return first + end
    }

    func pluralized() -> Self {
        self
    }

}
