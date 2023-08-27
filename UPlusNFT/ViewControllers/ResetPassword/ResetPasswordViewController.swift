//
//  ResetPasswordViewController.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/06/22.
//

import UIKit
import Combine

final class ResetPasswordViewController: UIViewController {
    
    // MARK: - Dependency
    private var viewModel: ResetPasswordViewViewModel
    private var bindings = Set<AnyCancellable>()
    
    // MARK: - UI Elements
    private let pwResetContainer: UIView = {
        let view = UIView()
        view.accessibilityIdentifier = "pwResetContainer"
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let findInfoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        
        let bold: UIFont = .systemFont(ofSize: UPlusFont.body2, weight: .bold)
        let regular: UIFont = .systemFont(ofSize: UPlusFont.body2, weight: .regular)
        
        let attributedString = NSMutableAttributedString(string: ResetPasswordConstants.findInfo, attributes: [
            .font: bold
        ])
        
        let regularString = NSAttributedString(string: ResetPasswordConstants.findDescription, attributes: [
            .font: regular
        ])
        
        attributedString.append(regularString)
        label.attributedText = attributedString
        
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        let font: UIFont = .systemFont(ofSize: UPlusFont.body1, weight: .regular)
        let attributedString = NSMutableAttributedString(string: LoginConstants.emailLabel, attributes: [
            .foregroundColor: UIColor.black,
            .font: font
        ])
        let star = NSAttributedString(string: SignUpConstants.star, attributes: [
            .foregroundColor: UPlusColor.mint04,
            .font: font
        ])
        
        attributedString.append(star)
        label.attributedText = attributedString
        
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.font = .systemFont(ofSize: UPlusFont.body1, weight: .bold)
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let placeHolderView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let placeHolderLabel: UILabel = {
        let label = UILabel()
        label.text = LoginConstants.uplusEmailSuffix
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emailValidationStack: UIStackView = {
        let stack = UIStackView()
        stack.isHidden = true
        stack.axis = .horizontal
        stack.spacing = 5.0
        stack.distribution = .fillProportionally
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let emailValidationImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: ImageAsset.infoRed)
        return imageView
    }()
    
    private let emailValidationText: UILabel = {
        let label = UILabel()
        label.textColor = UPlusColor.orange01
        label.text = ResetPasswordConstants.checkEmail
        label.font = .systemFont(ofSize: UPlusFont.body2, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var sendEmailButton: UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.layer.cornerRadius = 8.0
        button.titleLabel?.font = .systemFont(ofSize: UPlusFont.body1, weight: .bold)
        button.setTitle(ResetPasswordConstants.sendEmailButton, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var backToLoginButton: UIButton = {
        let button = UIButton()
        button.accessibilityIdentifier = "backToLoginButton"
        button.isHidden = true
        button.clipsToBounds = true
        button.layer.cornerRadius = 8.0
        button.setTitle(ResetPasswordConstants.login, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = UPlusColor.mint03
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    //MARK: - UI Elements (After email sent)
    private let emailSentContainer: UIView = {
        let view = UIView()
        view.accessibilityIdentifier = "emailSentContainer"
        view.isHidden = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let emailImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: ImageAsset.emailBig)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let checkEmailLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = ResetPasswordConstants.checkMailBox
        label.font = .systemFont(ofSize: UPlusFont.h2, weight: .bold)
        label.textColor = UPlusColor.mint04
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emailSentLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = ResetPasswordConstants.emailSent
        label.font = .systemFont(ofSize: UPlusFont.body2, weight: .regular)
        label.textColor = UPlusColor.gray05
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = ResetPasswordConstants.findPassword
        self.view.backgroundColor = .white
        
        self.setUI()
        self.setLayout()
        self.setEmailSentLayout()
        
        self.setDelegate()
        
        self.bind()
    }
    
    // MARK: - Init
    init(vm: ResetPasswordViewViewModel) {
        self.viewModel = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

//MARK: - Bind
extension ResetPasswordViewController {
    
    private func bind() {
        func bindViewToViewModel() {
            self.emailTextField.textPublisher
                .removeDuplicates()
                .debounce(for: 0.5, scheduler: RunLoop.main)
                .assign(to: \.email, on: viewModel)
                .store(in: &bindings)
            
            self.sendEmailButton.tapPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] value in
                    guard let `self` = self else { return }
                    
                    self.sendResetEmailDidTap()
                }
                .store(in: &bindings)
            
            self.backToLoginButton.tapPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] value in
                    guard let `self` = self else { return }
                    
                    self.backToLoginDidTap()
                }
                .store(in: &bindings)
        }
        
        func bindViewModelToView() {
            viewModel.hasEmailSent
                .receive(on: RunLoop.main)
                .sink { [weak self] value in
                    guard let `self` = self else { return }
                    if value {
                        self.emailValidationStack.isHidden = true
                        self.pwResetContainer.isHidden = true
                        self.emailSentContainer.isHidden = false
                        self.sendEmailButton.setTitle(ResetPasswordConstants.login, for: .normal)
                    } else {
                        self.emailValidationStack.isHidden = false
                        self.emailValidationText.text = viewModel.errorDescription
                    }
                }
                .store(in: &bindings)
            
            viewModel.$email.sink { [weak self] value in
                guard let `self` = self else { return }
            
                var isInteractive = false
                var bgColor: UIColor?
                var textColor: UIColor?
                
                if value.isEmpty {
                    isInteractive = false
                    bgColor = UPlusColor.gray02
                    textColor = .white
                } else {
                    isInteractive = true
                    bgColor = UPlusColor.mint03
                    textColor = UPlusColor.gray08
                }
                
                self.sendEmailButton.isUserInteractionEnabled = isInteractive
                self.sendEmailButton.backgroundColor = bgColor
                self.sendEmailButton.setTitleColor(textColor, for: .normal)
            }
            .store(in: &bindings)
            
        }
        
        bindViewToViewModel()
        bindViewModelToView()
    }
}

//MARK: - Private
extension ResetPasswordViewController {
    
    
    private func sendResetEmailDidTap() {
        self.viewModel.sendResetEmail()
    }
    
    private func backToLoginDidTap() {
        self.navigationController?.popViewController(animated: true)
    }
}

//MARK: - TextFieldDelegate
extension ResetPasswordViewController: UITextFieldDelegate {
    
}

//MARK: - Set UI & Layout
extension ResetPasswordViewController {
    private func setUI() {
        self.view.addSubviews(self.pwResetContainer,
                              self.emailSentContainer,
                              self.sendEmailButton,
                              self.backToLoginButton)
        
        self.pwResetContainer.addSubviews(self.findInfoLabel,
                                          self.emailLabel,
                                          self.emailValidationStack,
                                          self.emailTextField)
        
        self.emailSentContainer.addSubviews(self.emailImage,
                                            self.checkEmailLabel,
                                            self.emailSentLabel)
        
        self.placeHolderView.addSubview(self.placeHolderLabel)
        self.emailTextField.rightView = self.placeHolderView
        self.emailTextField.rightViewMode = .always
        
        self.emailValidationStack.addArrangedSubviews(self.emailValidationImage,
                                                      self.emailValidationText)
    }

    private func setLayout() {
        NSLayoutConstraint.activate([
            self.pwResetContainer.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.pwResetContainer.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            self.pwResetContainer.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            self.pwResetContainer.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            self.findInfoLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.pwResetContainer.topAnchor, multiplier: 3),
            self.findInfoLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.pwResetContainer.leadingAnchor, multiplier: 2),
            self.pwResetContainer.trailingAnchor.constraint(equalToSystemSpacingAfter: self.findInfoLabel.trailingAnchor, multiplier: 2),
            
            self.emailLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.findInfoLabel.bottomAnchor, multiplier: 6),
            self.emailLabel.leadingAnchor.constraint(equalTo: self.findInfoLabel.leadingAnchor),
            
            self.emailTextField.topAnchor.constraint(equalToSystemSpacingBelow: emailLabel.bottomAnchor, multiplier: 1),
            self.emailTextField.leadingAnchor.constraint(equalTo: emailLabel.leadingAnchor),
            self.emailTextField.heightAnchor.constraint(equalToConstant: LoginConstants.textFieldHeight),
            self.emailTextField.trailingAnchor.constraint(equalTo: self.findInfoLabel.trailingAnchor),
            
            self.emailValidationStack.topAnchor.constraint(equalToSystemSpacingBelow: self.emailTextField.bottomAnchor, multiplier: 1),
            self.emailValidationStack.leadingAnchor.constraint(equalTo: self.emailTextField.leadingAnchor),
            
            self.sendEmailButton.heightAnchor.constraint(equalToConstant: LoginConstants.buttonHeight),
            self.sendEmailButton.leadingAnchor.constraint(equalTo: self.findInfoLabel.leadingAnchor),
            self.sendEmailButton.trailingAnchor.constraint(equalTo: self.findInfoLabel.trailingAnchor),
            self.pwResetContainer.bottomAnchor.constraint(equalToSystemSpacingBelow: self.sendEmailButton.bottomAnchor, multiplier: 2)
        ])
        
        NSLayoutConstraint.activate([
            self.placeHolderLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.placeHolderView.topAnchor, multiplier: 1),
            self.placeHolderLabel.leadingAnchor.constraint(equalTo: self.placeHolderView.leadingAnchor),
            self.placeHolderView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.placeHolderLabel.trailingAnchor, multiplier: 1),
            self.placeHolderView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.placeHolderLabel.bottomAnchor, multiplier: 1)
        ])
    }
    
    private func setEmailSentLayout() {
        NSLayoutConstraint.activate([
            self.emailSentContainer.topAnchor.constraint(equalTo: self.pwResetContainer.topAnchor),
            self.emailSentContainer.leadingAnchor.constraint(equalTo: self.pwResetContainer.leadingAnchor),
            self.emailSentContainer.trailingAnchor.constraint(equalTo: self.pwResetContainer.trailingAnchor),
            self.emailSentContainer.bottomAnchor.constraint(equalTo: self.pwResetContainer.bottomAnchor),
            
            self.backToLoginButton.heightAnchor.constraint(equalToConstant: LoginConstants.buttonHeight),
            self.backToLoginButton.leadingAnchor.constraint(equalTo: self.findInfoLabel.leadingAnchor),
            self.backToLoginButton.trailingAnchor.constraint(equalTo: self.findInfoLabel.trailingAnchor),
            self.pwResetContainer.bottomAnchor.constraint(equalToSystemSpacingBelow: self.backToLoginButton.bottomAnchor, multiplier: 2)
        ])
        
        NSLayoutConstraint.activate([
            self.emailImage.topAnchor.constraint(equalToSystemSpacingBelow: self.emailSentContainer.topAnchor, multiplier: 20),
            self.emailImage.centerXAnchor.constraint(equalTo: self.emailSentContainer.centerXAnchor),
            
            self.checkEmailLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.emailImage.bottomAnchor, multiplier: 2),
            self.checkEmailLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.emailSentContainer.leadingAnchor, multiplier: 2),
            self.emailSentContainer.trailingAnchor.constraint(equalToSystemSpacingAfter: self.checkEmailLabel.trailingAnchor, multiplier: 2),
            
            self.emailSentLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.checkEmailLabel.bottomAnchor, multiplier: 2),
            self.emailSentLabel.leadingAnchor.constraint(equalTo: self.checkEmailLabel.leadingAnchor),
            self.emailSentLabel.trailingAnchor.constraint(equalTo: self.checkEmailLabel.trailingAnchor)
        ])
    }
    

    private func setDelegate() {
        emailTextField.delegate = self
    }
}
