//
//  HapticEngine.swift
//  Password Generator
//
//  Created by Evgeny Koshkin on 15.11.2021.
//

import UIKit

struct HapticEngine {

    func hapticWarning() {
        let warningNotificationFeedbackGenerator = UINotificationFeedbackGenerator()
        warningNotificationFeedbackGenerator.notificationOccurred(.error)
    }

    func hapticTap() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}
