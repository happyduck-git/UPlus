//
//  SignUpViewController.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/06/20.
//

import UIKit
import Combine

final class SignUpViewController: UIViewController {
    
    private var viewModel: SignUpViewViewModel
    private var bindings = Set<AnyCancellable>()
    
    // MARK: - UI Elements
    private let emailTitleLabel: UILabel = {
        let label = UILabel()
        label.text = SignUpConstants.emailLabel
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var emailAuthButton: UIButton = {
        let button = UIButton()
        button.setTitle(SignUpConstants.authenticate, for: .normal)
        button.backgroundColor = .systemGray2
        button.isUserInteractionEnabled = false
        button.addTarget(self, action: #selector(authButtonDidTap), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let emailTextField: UITextField = {
        let txtField = UITextField()
        txtField.text = "rkrudtls@gmail.com"
        txtField.textColor = .label
        txtField.borderStyle = .roundedRect
        txtField.translatesAutoresizingMaskIntoConstraints = false
        return txtField
    }()
    
    private let emailValidationText: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .thin)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let passwordTitleLabel: UILabel = {
        let label = UILabel()
        label.text = SignUpConstants.passwordLabel
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let passwordTextField: UITextField = {
        let txtField = UITextField()
        txtField.textColor = .black
        txtField.borderStyle = .roundedRect
        txtField.isUserInteractionEnabled = false
        txtField.text = "Pass1234"
        txtField.backgroundColor = .systemGray3
        txtField.translatesAutoresizingMaskIntoConstraints = false
        return txtField
    }()
    
    private let passwordValidationText: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .thin)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let passwordCheckTitleLabel: UILabel = {
        let label = UILabel()
        label.text = SignUpConstants.passwordCheckLabel
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let passwordCheckTextField: UITextField = {
        let txtField = UITextField()
        txtField.textColor = .black
        txtField.borderStyle = .roundedRect
        txtField.isUserInteractionEnabled = false
        txtField.backgroundColor = .systemGray3
        txtField.translatesAutoresizingMaskIntoConstraints = false
        return txtField
    }()
    
    private let passwordCheckValidationText: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .thin)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nicknameTitleLabel: UILabel = {
        let label = UILabel()
        label.text = SignUpConstants.nicknameLabel
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nicknameTextField: UITextField = {
        let txtField = UITextField()
        txtField.textColor = .black
        txtField.borderStyle = .roundedRect
        txtField.isUserInteractionEnabled = false
        txtField.backgroundColor = .systemGray3
        txtField.translatesAutoresizingMaskIntoConstraints = false
        return txtField
    }()
    
    private lazy var registerButton: UIButton = {
        let button = UIButton()
        button.setTitle(SignUpConstants.register, for: .normal)
        button.addTarget(self, action: #selector(registerButtonDidTapped), for: .touchUpInside)
        button.backgroundColor = .systemGray2
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setLayout()
        
        bind()
        
        
    }
    
    // MARK: - Init
    init(vm: SignUpViewViewModel) {
        self.viewModel = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private
    private func setUI() {
        view.addSubviews(
            emailTitleLabel,
            emailAuthButton,
            emailTextField,
            emailValidationText,
            passwordTitleLabel,
            passwordTextField,
            passwordValidationText,
            passwordCheckTitleLabel,
            passwordCheckTextField,
            passwordCheckValidationText,
            nicknameTitleLabel,
            nicknameTextField,
            registerButton
        )
    }
     
    private func setLayout() {
        NSLayoutConstraint.activate([
            emailTitleLabel.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 5),
            emailTitleLabel.leadingAnchor.constraint(lessThanOrEqualToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 3),
            emailAuthButton.centerYAnchor.constraint(equalTo: emailTitleLabel.centerYAnchor),
            emailAuthButton.leadingAnchor.constraint(equalToSystemSpacingAfter: emailTitleLabel.trailingAnchor, multiplier: 2),
            emailTextField.topAnchor.constraint(equalToSystemSpacingBelow: emailAuthButton.bottomAnchor, multiplier: 1),
            emailTextField.leadingAnchor.constraint(equalTo: emailTitleLabel.leadingAnchor),
            view.trailingAnchor.constraint(equalToSystemSpacingAfter: emailTextField.trailingAnchor, multiplier: 3),
            
            emailValidationText.topAnchor.constraint(equalToSystemSpacingBelow: emailTextField.bottomAnchor, multiplier: 1),
            emailValidationText.leadingAnchor.constraint(equalTo: emailTitleLabel.leadingAnchor),
            
            passwordTitleLabel.topAnchor.constraint(equalToSystemSpacingBelow: emailValidationText.bottomAnchor, multiplier: 2),
            passwordTitleLabel.leadingAnchor.constraint(equalTo: emailTitleLabel.leadingAnchor),
            passwordTextField.topAnchor.constraint(equalToSystemSpacingBelow: passwordTitleLabel.bottomAnchor, multiplier: 1),
            passwordTextField.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
            passwordTextField.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor),
            
            passwordValidationText.topAnchor.constraint(equalToSystemSpacingBelow: passwordTextField.bottomAnchor, multiplier: 1),
            passwordValidationText.leadingAnchor.constraint(equalTo: emailTitleLabel.leadingAnchor),
            
            passwordCheckTitleLabel.topAnchor.constraint(equalToSystemSpacingBelow: passwordValidationText.bottomAnchor, multiplier: 2),
            passwordCheckTitleLabel.leadingAnchor.constraint(equalTo: emailTitleLabel.leadingAnchor),
            passwordCheckTextField.topAnchor.constraint(equalToSystemSpacingBelow: passwordCheckTitleLabel.bottomAnchor, multiplier: 1),
            passwordCheckTextField.leadingAnchor.constraint(equalTo: emailTitleLabel.leadingAnchor),
            passwordCheckTextField.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor),
            
            passwordCheckValidationText.topAnchor.constraint(equalToSystemSpacingBelow: passwordCheckTextField.bottomAnchor, multiplier: 1),
            passwordCheckValidationText.leadingAnchor.constraint(equalTo: emailTitleLabel.leadingAnchor),
            
            nicknameTitleLabel.topAnchor.constraint(equalToSystemSpacingBelow: passwordCheckTextField.bottomAnchor, multiplier: 2),
            nicknameTitleLabel.leadingAnchor.constraint(equalTo: emailTitleLabel.leadingAnchor),
            nicknameTextField.topAnchor.constraint(equalToSystemSpacingBelow: nicknameTitleLabel.bottomAnchor, multiplier: 1),
            nicknameTextField.leadingAnchor.constraint(equalTo: emailTitleLabel.leadingAnchor),
            nicknameTextField.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor),
            
            registerButton.topAnchor.constraint(equalToSystemSpacingBelow: nicknameTextField.bottomAnchor, multiplier: 3),
            registerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func bind() {
        func bindViewToViewModel() {
            self.emailTextField.textPublisher
                .assign(to: \.email, on: viewModel)
                .store(in: &bindings)
            
            self.passwordTextField.textPublisher
                .assign(to: \.password, on: viewModel)
                .store(in: &bindings)
            
            self.passwordCheckTextField.textPublisher
                .assign(to: \.passwordCheck, on: viewModel)
                .store(in: &bindings)
            
            self.nicknameTextField.textPublisher
                .assign(to: \.nickname, on: viewModel)
                .store(in: &bindings)
        }
        
        func bindViewModelToView() {
            viewModel.isAuthenticated
                .receive(on: DispatchQueue.main)
                .sink { [weak self] value in
                    guard let `self` = self else { return }
                    if value {
                        self.emailAuthButton.setTitle(SignUpConstants.authCompleted, for: .normal)
                        self.emailAuthButton.backgroundColor = .systemGray4
                        self.emailAuthButton.isUserInteractionEnabled = false
                        self.emailTextField.isUserInteractionEnabled = false
                        self.passwordTextField.backgroundColor = .white
                        self.passwordTextField.isUserInteractionEnabled = true
                        self.nicknameTextField.backgroundColor = .white
                        self.nicknameTextField.isUserInteractionEnabled = true
                        self.passwordCheckTextField.backgroundColor = .white
                        self.passwordCheckTextField.isUserInteractionEnabled = true
                    }
                }
                .store(in: &bindings)
            
            
            viewModel.isValidated
                .receive(on: DispatchQueue.main)
                .sink { result in
                    print("Is validated? \(result)")
                }
                .store(in: &bindings)
            
            viewModel.isEmailValid
                .receive(on: DispatchQueue.main)
                .sink { [weak self] valid in
                    guard let `self` = self else { return }
                    let emailText = self.emailTextField.text ?? ""
                   print("Emailtext: \(emailText)")
                    if valid {
                        
                        self.emailAuthButton.backgroundColor = .systemTeal
                        self.emailValidationText.text = ""
                        self.emailAuthButton.isUserInteractionEnabled = true
                    } else if emailText.isEmpty {
                        self.emailValidationText.text = ""
                        self.emailAuthButton.backgroundColor = .systemGray2
                        self.emailAuthButton.isUserInteractionEnabled = false
                    } else {
                        self.emailValidationText.text = "올바른 형식의 이메일이 아닙니다."
                        self.emailAuthButton.backgroundColor = .systemGray2
                        self.emailAuthButton.isUserInteractionEnabled = false
                    }
                }
                .store(in: &bindings)
            
            viewModel.isPasswordValid
                .receive(on: DispatchQueue.main)
                .sink { [weak self] valid in
                    guard let `self` = self else { return }
                    let passwordText = self.passwordTextField.text ?? ""
                    print("passwordText: \(passwordText)")
                    if valid {
                        self.passwordValidationText.text = ""
                    } else if passwordText.isEmpty {
                        self.passwordValidationText.text = ""
                    } else {
                        self.passwordValidationText.text = "올바른 형식의 비밀번호가 아닙니다."
                    }
                }
                .store(in: &bindings)
            
            viewModel.isPasswordSame
                .receive(on: DispatchQueue.main)
                .sink { [weak self] valid in
                    guard let `self` = self else { return }
                    let passwordText = self.passwordCheckTextField.text ?? ""
                    
                    if valid {
                        self.passwordCheckValidationText.text = ""
                    } else if passwordText.isEmpty {
                        self.passwordCheckValidationText.text = ""
                    } else {
                        self.passwordCheckValidationText.text = "비밀번호가 일치하지 않습니다."
                    }
                }
                .store(in: &bindings)
            
            viewModel.isAllInfoChecked
                .receive(on: DispatchQueue.main)
                .sink { [weak self] valid in
                    guard let `self` = self else { return }
                    if valid {
                        self.registerButton.backgroundColor = .systemBlue
                    } else {
                        self.registerButton.backgroundColor = .systemGray2
                    }
                }
                .store(in: &bindings)
            
            viewModel.isUserCreated
                .receive(on: DispatchQueue.main)
                .sink { [weak self] valid in
                    guard let `self` = self else { return }
                    if valid {
                        navigationController?.popViewController(animated: true)
                    }
                }
                .store(in: &bindings)
        }
        
        bindViewToViewModel()
        bindViewModelToView()
    }
    
    @objc private func authButtonDidTap() {
        viewModel.sendEmailValification()
    }
    
    @objc private func registerButtonDidTapped() {
        // TODO: 이메일,pw register
        viewModel.createNewUser()
    }
}
