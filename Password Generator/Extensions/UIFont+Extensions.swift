//
//  UIFont+Extensions.swift
//  Password Generator
//
//  Created by Evgeny Koshkin on 15.11.2021.
//

import UIKit

extension UIFont {

    var bold: UIFont {
        return with(.traitBold)
    }

    var italic: UIFont {
        return with(.traitItalic)
    }

    var boldItalic: UIFont {
        return with([.traitBold, .traitItalic])
    }

    func with(_ traits: UIFontDescriptor.SymbolicTraits...) -> UIFont {
        let symbolicTraits = UIFontDescriptor.SymbolicTraits(traits).union(fontDescriptor.symbolicTraits)

        guard let descriptor = fontDescriptor.withSymbolicTraits(symbolicTraits) else {
            return self
        }

        return UIFont(descriptor: descriptor, size: 0)
    }

}

