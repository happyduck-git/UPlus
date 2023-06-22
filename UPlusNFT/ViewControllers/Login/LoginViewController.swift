//
//  ViewController.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/06/20.
//

import UIKit
import FirebaseAuth
import Combine

class LoginViewController: UIViewController {

    // MARK: - Dependency
    private var viewModel: LoginViewViewModel
    
    // MARK: - Handlers
    private var authStateHandler: AuthStateDidChangeListenerHandle?
    private var bindings = Set<AnyCancellable>()
    
    // MARK: - UI Elements
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.text = LoginConstants.emailLabel
        label.textColor = .black
        return label
    }()

    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
//        textField.text = "rkrudtls@gmail.com" // for debug
        return textField
    }()

    private let passwordLabel: UILabel = {
        let label = UILabel()
        label.text = LoginConstants.passwordLabel
        label.textColor = .black
        return label
    }()

    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
//        textField.text = "Pass1234" // for debug
        return textField
    }()

    private let labelStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = LoginConstants.stackSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let textFieldStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = LoginConstants.stackSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let credentialValidationText: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .thin)
        label.text = " "
        label.textColor = .systemRed
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var loginButton: UIButton = {
        let button = UIButton()
        button.setTitle(LoginConstants.loginButtonTitle, for: .normal)
        button.addTarget(self, action: #selector(loginUser), for: .touchUpInside)
        button.backgroundColor = .systemGray
        button.isUserInteractionEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    /// for debug
    private lazy var logoutButton: UIButton = {
        let button = UIButton()
        button.setTitle(LoginConstants.logoutButtonTitle, for: .normal)
        button.addTarget(self, action: #selector(logoutUser), for: .touchUpInside)
        button.backgroundColor = .systemGray
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var changePasswordButton: UIButton = {
       let button = UIButton()
        button.setTitle(LoginConstants.changePassword, for: .normal)
        button.backgroundColor = .systemGray2
        button.addTarget(self, action: #selector(changePassword), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var createAccountButton: UIButton = {
        let button = UIButton()
        button.setTitle(LoginConstants.singInButtonTitle, for: .normal)
        button.backgroundColor = .systemOrange
        button.addTarget(self, action: #selector(openSignUpVC), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Init
    init(vm: LoginViewViewModel) {
        self.viewModel = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .tertiarySystemBackground
        setUI()
        setLayout()
        bind()
        
        hideKeyboardWhenTappedAround()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        /// Connect FIRAuth instance and a listener.
        /// This listener is called whenever the user login state is changed.
        authStateHandler = Auth.auth().addStateDidChangeListener { auth, user in
            guard let user = user else {
                print("User found to be nil.")
                return
            }
            print("Logged in user: " + user.uid + " " + (user.email ?? "no email found."))

        }

    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        /// Disconnect FIRAuth instance and a listener.
        Auth.auth().removeStateDidChangeListener(authStateHandler!)
    }

    //MARK: - Set UI & Layout
    private func setUI() {
        view.addSubview(labelStackView)
        labelStackView.addArrangedSubview(emailLabel)
        labelStackView.addArrangedSubview(passwordLabel)
        view.addSubview(textFieldStackView)
        textFieldStackView.addArrangedSubview(emailTextField)
        textFieldStackView.addArrangedSubview(passwordTextField)
        view.addSubview(credentialValidationText)
        view.addSubview(loginButton)
        view.addSubview(logoutButton)
        view.addSubview(changePasswordButton)
        view.addSubview(createAccountButton)
    }

    private func setLayout() {
        NSLayoutConstraint.activate([
            labelStackView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 2),
            labelStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            labelStackView.widthAnchor.constraint(equalToConstant: 100),
            textFieldStackView.leadingAnchor.constraint(equalToSystemSpacingAfter: labelStackView.trailingAnchor, multiplier: 2),
            textFieldStackView.centerYAnchor.constraint(equalTo: labelStackView.centerYAnchor),
            view.trailingAnchor.constraint(equalToSystemSpacingAfter: textFieldStackView.trailingAnchor, multiplier: 2),
            credentialValidationText.topAnchor.constraint(equalToSystemSpacingBelow: textFieldStackView.bottomAnchor, multiplier: 1),
            credentialValidationText.leadingAnchor.constraint(equalTo: labelStackView.leadingAnchor),
            loginButton.topAnchor.constraint(equalToSystemSpacingBelow: credentialValidationText.bottomAnchor, multiplier: 1),
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoutButton.topAnchor.constraint(equalTo: loginButton.topAnchor),
            logoutButton.leadingAnchor.constraint(equalToSystemSpacingAfter: loginButton.trailingAnchor, multiplier: 2),
            changePasswordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            changePasswordButton.topAnchor.constraint(equalToSystemSpacingBelow: loginButton.bottomAnchor, multiplier: 3),
            createAccountButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            createAccountButton.topAnchor.constraint(equalToSystemSpacingBelow: changePasswordButton.bottomAnchor, multiplier: 3)
        ])

        labelStackView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }

    private func setDelegate() {
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }

    //MARK: - Private
    @objc private func openSignUpVC() {
        let vm = SignUpViewViewModel()
        let vc = SignUpViewController(vm: vm)
        navigationController?.modalPresentationStyle = .fullScreen
        show(vc, sender: self)
    }

    @objc private func loginUser() {
        self.viewModel.login()
    }

    @objc private func changePassword() {
        let vm = ResetPasswordViewViewModel()
        let vc = ResetPasswordViewController(vm: vm)
        show(vc, sender: self)
    }
    
    /// for debug
    @objc private func logoutUser() {
        do {
            try Auth.auth().signOut()
        }
        catch {
            print("Error logout user \(error.localizedDescription)")
        }
    }

    private func bind() {
        func bindViewToViewModel() {
            self.emailTextField.textPublisher
                .assign(to: \.email, on: viewModel)
                .store(in: &bindings)
            
            self.passwordTextField.textPublisher
                .assign(to: \.password, on: viewModel)
                .store(in: &bindings)
        }
        
        func bindViewModelToView() {
            viewModel.isCredentialNotEmpty
                .receive(on: DispatchQueue.main)
                .sink { [weak self] value in
                    guard let `self` = self else { return }
                    if value {
                        self.loginButton.backgroundColor = .systemBlue
                        self.loginButton.isUserInteractionEnabled = true
                    } else {
                        self.loginButton.backgroundColor = .systemGray
                        self.loginButton.isUserInteractionEnabled = false
                    }
                }
                .store(in: &bindings)
            
            viewModel.isLoginSuccess
                .receive(on: DispatchQueue.main)
                .sink { [weak self] value in
                    guard let `self` = self else { return }
                    if value {
                        let vc = PostViewController()
                        self.show(vc, sender: self)
                    } else {
                        // TODO: Show UIAlert indicating login failed.
                        self.credentialValidationText.text = viewModel.errorDescription
                    }
                }
                .store(in: &bindings)
        }
        
        bindViewToViewModel()
        bindViewModelToView()
    }

}

// MARK: - UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
    
}
