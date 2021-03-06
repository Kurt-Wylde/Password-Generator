//
//  ViewController.swift
//  Password Generator
//
//  Created by Evgeny Koshkin on 15.11.2021.
//

import UIKit

import UIKit

final class PasswordGeneratorViewController: UIViewController {

    private var viewModel = PasswordGeneratorViewModel(passwordAttributes: Constants.defaultPasswordAttributes,
                                                       passwordLength: Constants.defaultPasswordLength)
    private var passwordSwitches: [NPAttributeSwitch]!

    @IBOutlet weak var passwordLabelViewContainer: UIView!
    @IBOutlet weak var passwordFadeOutLabel: UILabel!
    @IBOutlet weak var passwordFadeOutLabelBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var passwordFadeInLabel: UILabel!
    @IBOutlet weak var passwordFadeInLabelBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var passwordLengthLabel: UILabel!
    @IBOutlet weak var passwordLengthSlider: UISlider!
    @IBOutlet weak var lowercaseLetterSwitch: NPAttributeSwitch!
    @IBOutlet weak var uppercaseLetterSwitch: NPAttributeSwitch!
    @IBOutlet weak var numberSwitch: NPAttributeSwitch!
    @IBOutlet weak var symbolSwitch: NPAttributeSwitch!
    @IBOutlet weak var generatePasswordButton: UIButton!
    @IBOutlet weak var copiedLabel: UILabel!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        configureViews()
        configureInitialState()
    }

    // MARK: View Layout

    private func configureViews() {
        passwordLabelViewContainer.roundify(cornerRadius: 8)
        passwordFadeOutLabel.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(presentPasswordShare)))

        lowercaseLetterSwitch.attributeType = .lowercaseLetters
        uppercaseLetterSwitch.attributeType = .uppercaseLetters
        numberSwitch.attributeType = .numbers
        symbolSwitch.attributeType = .symbols
        passwordSwitches = [lowercaseLetterSwitch, numberSwitch, symbolSwitch, uppercaseLetterSwitch]

        generatePasswordButton.addTarget(self, action: #selector(generatePasswordTouchBegan(_:)), for: .touchDown)
        generatePasswordButton.roundify(cornerRadius: 8)
    }

    /// Sets default view states and generates initial password
    private func configureInitialState() {
        viewModel.fetchNewPassword()

        for passwordSwitch in passwordSwitches {
            if viewModel.passwordAttributes.contains(passwordSwitch.attributeType) {
                passwordSwitch.setOn(true, animated: true)
            }
        }

        passwordLengthSlider.setValue(Float(viewModel.passwordLength), animated: true)
        passwordLengthLabel.text = "Password Length: \(viewModel.passwordLength)"
        passwordFadeOutLabel.attributedText = viewModel.styledPassword
        copiedLabel.isHidden = true
    }

    /// Animates the `passwordFadeOutLabel` up out of view and `passwordFadeInLabel` up (from bottom) in to view.
    /// This is a recursive function that will perform a faster animation and continue generating passwords if
    /// the user keeps holding down the `generatePasswordButton`.
    ///
    /// - parameters:
    ///     - withFastAnimation: Determines if faster animation should be configured
    ///
    private func animateLabelUpdates(withFastAnimation: Bool = false) {
        // Label with new password that will animate into view
        passwordFadeInLabel.attributedText = viewModel.styledPassword

        UIView.animate(withDuration: withFastAnimation ? 0.07 : 0.32,
                       delay: 0,
                       usingSpringWithDamping: withFastAnimation ? 0.1 : 0.5,
                       initialSpringVelocity: 5,
                       options: [],
                       animations: { performLayoutUpdatesForAnimation() },
                       completion: { _ in
                        self.generatePasswordButton.isEnabled = true
                        self.passwordFadeOutLabel.attributedText = self.passwordFadeInLabel.attributedText
                        performLayoutUpdatesForCompletion()

                        if self.generatePasswordButton.state == .highlighted {
                            // Fetch new password in case user made changes during last animation
                            self.fetchNewPassword()
                            if self.viewModel.hasSelectedPasswordAttributes {
                                self.animateLabelUpdates(withFastAnimation: true)
                            }
                        }
        })

        /// Animates the old password out of view and new password in to view
        func performLayoutUpdatesForAnimation() {
            self.passwordFadeOutLabel.alpha = 0
            self.passwordFadeOutLabelBottomConstraint.constant = self.passwordLabelViewContainer.frame.height
            self.passwordFadeInLabel.alpha = 1
            self.passwordFadeInLabelBottomConstraint.constant = 0
            self.view.layoutIfNeeded()
        }

        /// Reposition labels to prepare for next animation
        func performLayoutUpdatesForCompletion() {
            self.passwordFadeOutLabel.alpha = 1
            self.passwordFadeOutLabelBottomConstraint.constant = 0
            self.passwordFadeInLabel.alpha = 0
            self.passwordFadeInLabelBottomConstraint.constant = 0 - self.passwordLabelViewContainer.frame.height
            self.view.layoutIfNeeded()
        }
    }

    // MARK: - Actions

    @IBAction private func attributeSwitchDidChange(_ attributeSwitch: NPAttributeSwitch) {
        let attributes = passwordSwitches.filter { $0.isOn }.map { switchThatIsOn -> PasswordAttribute in
            return switchThatIsOn.attributeType
        }

        viewModel.update(attributes: attributes)
    }

    @IBAction private func passwordLengthSliderDidMove(_ sender: UISlider) {
        viewModel.update(length: Int(passwordLengthSlider.value))
        passwordLengthLabel.text = "Password Length: \(viewModel.passwordLength)"
    }

    @IBAction private func generatePasswordTouchBegan(_ sender: UIButton) {
        fetchNewPassword()
        animateLabelUpdates()
    }

    private func fetchNewPassword() {
        generatePasswordButton.isEnabled = false

        if viewModel.hasSelectedPasswordAttributes {
            HapticEngine().hapticTap()
            viewModel.fetchNewPassword()
            let pasteboard = UIPasteboard.general
            pasteboard.string = viewModel.passwordString
            copiedLabel.isHidden = false
        } else {
            presentAlertForEmptyAttributes()
        }
    }

    // MARK: - Share Activity

    @objc private func presentPasswordShare() {
        let items = [viewModel.styledPassword.string]
        let vc = UIActivityViewController(activityItems: items, applicationActivities: nil)
        // Because why...
        let excludedActivityTypes: [UIActivity.ActivityType] = [.postToFacebook, .postToTwitter]

        vc.excludedActivityTypes = excludedActivityTypes
        present(vc, animated: true, completion: nil)
    }

    private func presentAlertForEmptyAttributes() {
        let alertViewController = NPAlertViewController(title: "Wait a sec.",
                                                        message: "You need at least one attribute selected to generate a password.",
                                                        buttonTitle: "OK")
        alertViewController.modalPresentationStyle = .overFullScreen
        alertViewController.modalTransitionStyle = .crossDissolve
        alertViewController.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        alertViewController.buttonHandler = {
            self.generatePasswordButton.isEnabled = true
        }

        self.present(alertViewController, animated: true)
        HapticEngine().hapticWarning()
    }

}

extension PasswordGeneratorViewController {

    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        switch motion {
        case .motionShake:
            fetchNewPassword()
            animateLabelUpdates()
        default:
            break
        }
    }

}


