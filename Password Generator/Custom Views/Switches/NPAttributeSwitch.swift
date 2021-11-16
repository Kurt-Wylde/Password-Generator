//
//  NPAttributeSwitch.swift
//  Password Generator
//
//  Created by Evgeny Koshkin on 15.11.2021.
//

import UIKit

class NPAttributeSwitch: UISwitch {

    // Force unwrapped because all password switches must have an attribute assigned to them
    var attributeType: PasswordAttribute!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        // Make sure all switches are initially off so they can be animated on when view appears
        self.isOn = false
    }

}
