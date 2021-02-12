//
//  String+CapitalizedFirstCharacter.swift
//  SwiftTemplate
//
//  Created by Tibor Bodecs on 2021. 02. 12..
//

import Foundation

extension String {

    /**
     Converts the first letter of the string to an upper case letter
     
     The remaining characters of the String will be unchanged.

     - returns: The string with a capitalized first letter
     */
    var capitalizedFirstCharacter: String {
        if self.count > 1 {
            let startIndex = self.index(self.startIndex, offsetBy: 1)
            let begin = self[..<startIndex]
            let end = self[startIndex...]
            let first = begin.uppercased()
            return first + end
        }
        return self.capitalized
    }

}
