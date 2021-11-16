//
//  PasswordAttribute.swift
//  Password Generator
//
//  Created by Evgeny Koshkin on 15.11.2021.
//

import Foundation

enum PasswordAttribute: String {

    case lowercaseLetters = "abcdefghijklmnopqrstuvwxyz"
    case uppercaseLetters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    case numbers = "1234567890"
    case symbols = "!@#$%^&*();:_.+-=<>"

    var characterSet: CharacterSet {
        return CharacterSet(charactersIn: self.rawValue)
    }

}
