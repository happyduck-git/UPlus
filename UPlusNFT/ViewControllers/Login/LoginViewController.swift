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
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let placeHolderView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let placeHolderLabel: UILabel = {
        let label = UILabel()
        label.text = "@uplus.net"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.textContentType = .username
        textField.keyboardType = .emailAddress
//        textField.text = "rkrudtls@gmail.com" // for debug
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let passwordLabel: UILabel = {
        let label = UILabel()
        label.text = LoginConstants.passwordLabel
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        textField.textContentType = .password
//        textField.text = "Pass1234" // for debug
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let keepLogInButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
        button.setTitle(LoginConstants.keepLoggedIn, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.isUserInteractionEnabled = false
        button.layer.cornerRadius = 3
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    /// for debug
    private lazy var logoutButton: UIButton = {
        let button = UIButton()
        button.setTitle(LoginConstants.logoutButtonTitle, for: .normal)
        button.addTarget(self, action: #selector(logoutUser), for: .touchUpInside)
        button.isHidden = true
        button.backgroundColor = .systemGray
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var changePasswordButton: UIButton = {
       let button = UIButton()
        button.setTitle(LoginConstants.changePassword, for: .normal)
        button.addTarget(self, action: #selector(changePassword), for: .touchUpInside)
        button.setTitleColor(.systemGray, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12.0)
        button.setUnderline(1.0)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var createAccountButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(openSignUpVC), for: .touchUpInside)
        button.setTitle(LoginConstants.singInButtonTitle, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.darkGray, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12.0)
        button.setUnderline(1.0)
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
        title = "로그인"
        view.backgroundColor = .secondarySystemBackground
        setUI()
        setLayout()
        setNavigationBar()
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
        
        // Views
        view.addSubviews(
            emailLabel,
            passwordLabel,
            emailTextField,
            passwordTextField,
            credentialValidationText,
            keepLogInButton,
            changePasswordButton,
            loginButton,
            createAccountButton
        )

        // Adding a PlaceHolderView
        placeHolderView.addSubview(placeHolderLabel)
        self.emailTextField.rightView = placeHolderView
        self.emailTextField.rightViewMode = .always
    }

    private func setLayout() {
        NSLayoutConstraint.activate([
            
            emailLabel.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 3),
            emailLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 3),
            emailTextField.topAnchor.constraint(equalToSystemSpacingBelow: emailLabel.bottomAnchor, multiplier: 1),
            emailTextField.leadingAnchor.constraint(equalTo: emailLabel.leadingAnchor),
            view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: emailTextField.trailingAnchor, multiplier: 3),
            
            passwordLabel.topAnchor.constraint(equalToSystemSpacingBelow: emailTextField.bottomAnchor, multiplier: 2),
            passwordLabel.leadingAnchor.constraint(equalTo: emailLabel.leadingAnchor),
            passwordTextField.topAnchor.constraint(equalToSystemSpacingBelow: passwordLabel.bottomAnchor, multiplier: 1),
            passwordTextField.leadingAnchor.constraint(equalTo: emailLabel.leadingAnchor),
            view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: passwordTextField.trailingAnchor, multiplier: 2),
            
            credentialValidationText.topAnchor.constraint(equalToSystemSpacingBelow: passwordTextField.bottomAnchor, multiplier: 1),
            credentialValidationText.leadingAnchor.constraint(equalTo: emailLabel.leadingAnchor),
            
            keepLogInButton.topAnchor.constraint(equalToSystemSpacingBelow: credentialValidationText.bottomAnchor, multiplier: 1),
            keepLogInButton.leadingAnchor.constraint(equalTo: emailLabel.leadingAnchor),
            changePasswordButton.topAnchor.constraint(equalTo: keepLogInButton.topAnchor),
            changePasswordButton.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor),
            
            loginButton.topAnchor.constraint(equalToSystemSpacingBelow: credentialValidationText.bottomAnchor, multiplier: 1),
            loginButton.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
            loginButton.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor),
            
            createAccountButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            createAccountButton.topAnchor.constraint(equalToSystemSpacingBelow: loginButton.bottomAnchor, multiplier: 2),
            
            placeHolderLabel.topAnchor.constraint(equalToSystemSpacingBelow: placeHolderView.topAnchor, multiplier: 1),
            placeHolderLabel.leadingAnchor.constraint(equalTo: placeHolderView.leadingAnchor),
            placeHolderView.trailingAnchor.constraint(equalToSystemSpacingAfter: placeHolderLabel.trailingAnchor, multiplier: 1),
            placeHolderView.bottomAnchor.constraint(equalToSystemSpacingBelow: placeHolderLabel.bottomAnchor, multiplier: 1)
        ])

        keepLogInButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }

    private func setDelegate() {
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    private func setNavigationBar() {
        self.navigationItem.backButtonTitle = ""
        self.navigationController?.navigationBar.tintColor = .systemGray
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
                        self.loginButton.backgroundColor = .black
                        self.loginButton.isUserInteractionEnabled = true
                    } else {
                        self.loginButton.backgroundColor = .systemGray
                        self.loginButton.isUserInteractionEnabled = false
                    }
                    self.credentialValidationText.text = ""
                }
                .store(in: &bindings)
            
            viewModel.isLoginSuccess
                .receive(on: DispatchQueue.main)
                .sink { [weak self] value in
                    guard let `self` = self else { return }
                    if value {
                        // Save user information when login success.
                        viewModel.saveUser()
                        
                        emailTextField.text = ""
                        passwordTextField.text = ""
                        let vm = PostViewViewModel()
                        let vc = PostViewController(vm: vm)
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
