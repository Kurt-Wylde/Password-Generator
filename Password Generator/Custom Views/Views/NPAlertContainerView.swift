//
//  NPAlertContainerView.swift
//  Password Generator
//
//  Created by Evgeny Koshkin on 15.11.2021.
//

import UIKit

class NPAlertContainerView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        backgroundColor = UIColor(red: 43/255, green: 43/255, blue: 43/255, alpha: 1)
        layer.cornerRadius = 16
        translatesAutoresizingMaskIntoConstraints = false
    }

}
