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
    
    private let loadingVC = LoadingViewController()
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.style = .medium
        spinner.translatesAutoresizingMaskIntoConstraints = false
        return spinner
    }()
    
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
        label.text = LoginConstants.uplusEmailSuffix
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "email"
        textField.borderStyle = .roundedRect
        textField.textContentType = .username
        textField.keyboardType = .emailAddress
        textField.text = "rkrudtls" // for debug
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
        textField.text = "Pass1234" // for debug
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
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
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12.0)
        button.setUnderline(1.0)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var createAccountButton: UIButton = {
        let button = UIButton()
        button.setTitle(LoginConstants.singInButtonTitle, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.black, for: .normal)
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

}

//MARK: - Bind with View Model
extension LoginViewController {
    
    private func bind() {
        func bindViewToViewModel() {
            self.emailTextField.textPublisher
                .assign(to: \.email, on: viewModel)
                .store(in: &bindings)
            
            self.passwordTextField.textPublisher
                .assign(to: \.password, on: viewModel)
                .store(in: &bindings)

            self.loginButton.tapPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    guard let `self` = self else { return }

                    self.addChildViewController(self.loadingVC)
                    self.viewModel.login()
                }
                .store(in: &bindings)
            
            self.createAccountButton.tapPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    guard let `self` = self else { return }
                    
                    self.openSignUpVC()
                }
                .store(in: &bindings)
            
            self.changePasswordButton.tapPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    guard let `self` = self else { return }
                    
                    self.changePassword()
                }
                .store(in: &bindings)
         
        }
        
        func bindViewModelToView() {
            self.viewModel.isCredentialNotEmpty
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
            
            self.viewModel.isLoginSuccess
                .receive(on: DispatchQueue.main)
                .sink { [weak self] value in
                    guard let `self` = self else { return }
                    
                    if value {
                        do {
                            let user = try UPlusUser.getCurrentUser()
                            self.passwordTextField.text = ""
                            self.viewModel.password = ""
                            
                            let vm = MyPageViewViewModel(user: user,
                                                         memberShip: (false, user.userHasVipNft))
                            let myPageVC = MyPageViewController(vm: vm)
                            
                            self.loadingVC.removeViewController()
                            self.show(myPageVC, sender: self)
                        }
                        catch {
                            print("Error getting saved user info from UserDefaults -- \(error)")
                            self.loadingVC.removeViewController()
                            let action = UIAlertAction(title: "확인", style: .default)
                            let alert = UIAlertController(
                                title: "로그인 실패",
                                message: "로그인에 실패하였습니다. 잠시 후 다시 시도해주시기 바랍니다.",
                                preferredStyle: .alert
                            )
                            alert.addAction(action)
                            self.show(alert, sender: self)
                        }
                        
                    } else {
                        self.credentialValidationText.text = viewModel.errorDescription
                        self.loadingVC.removeViewController()
                    }
                }
                .store(in: &bindings)

        }
        
        bindViewToViewModel()
        bindViewModelToView()
    }
}

//MARK: - Set UI & Layout
extension LoginViewController {

    private func setUI() {
        
        // Views
        self.view.addSubviews(
            self.spinner,
            self.emailLabel,
            self.passwordLabel,
            self.emailTextField,
            self.passwordTextField,
            self.credentialValidationText,
            self.changePasswordButton,
            self.loginButton,
            self.createAccountButton
        )

        // Adding a PlaceHolderView
        self.placeHolderView.addSubview(placeHolderLabel)
        self.emailTextField.rightView = placeHolderView
        self.emailTextField.rightViewMode = .always
    }

    private func setLayout() {
        NSLayoutConstraint.activate([
            self.spinner.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.spinner.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            
            self.emailLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.view.safeAreaLayoutGuide.topAnchor, multiplier: 3),
            self.emailLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.view.safeAreaLayoutGuide.leadingAnchor, multiplier: 3),
            self.emailTextField.topAnchor.constraint(equalToSystemSpacingBelow: self.emailLabel.bottomAnchor, multiplier: 1),
            self.emailTextField.leadingAnchor.constraint(equalTo: self.emailLabel.leadingAnchor),
            self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: self.emailTextField.trailingAnchor, multiplier: 3),
            
            self.passwordLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.emailTextField.bottomAnchor, multiplier: 2),
            self.passwordLabel.leadingAnchor.constraint(equalTo: self.emailLabel.leadingAnchor),
            self.passwordTextField.topAnchor.constraint(equalToSystemSpacingBelow: self.passwordLabel.bottomAnchor, multiplier: 1),
            self.passwordTextField.leadingAnchor.constraint(equalTo: self.emailTextField.leadingAnchor),
            self.passwordTextField.trailingAnchor.constraint(equalTo: self.emailTextField.trailingAnchor),
            
            self.credentialValidationText.topAnchor.constraint(equalToSystemSpacingBelow: self.passwordTextField.bottomAnchor, multiplier: 1),
            self.credentialValidationText.leadingAnchor.constraint(equalTo: self.emailLabel.leadingAnchor),
            
            self.changePasswordButton.topAnchor.constraint(equalToSystemSpacingBelow: self.credentialValidationText.bottomAnchor, multiplier: 1),
            self.changePasswordButton.trailingAnchor.constraint(equalTo: self.emailTextField.trailingAnchor),
            
            self.loginButton.topAnchor.constraint(equalToSystemSpacingBelow: self.changePasswordButton.bottomAnchor, multiplier: 2),
            self.loginButton.leadingAnchor.constraint(equalTo: self.emailTextField.leadingAnchor),
            self.loginButton.trailingAnchor.constraint(equalTo: self.emailTextField.trailingAnchor),
            
            self.createAccountButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.createAccountButton.topAnchor.constraint(equalToSystemSpacingBelow: self.loginButton.bottomAnchor, multiplier: 2),
            
            self.placeHolderLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.placeHolderView.topAnchor, multiplier: 1),
            self.placeHolderLabel.leadingAnchor.constraint(equalTo: self.placeHolderView.leadingAnchor),
            self.placeHolderView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.placeHolderLabel.trailingAnchor, multiplier: 1),
            self.placeHolderView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.placeHolderLabel.bottomAnchor, multiplier: 1)
        ])

        self.changePasswordButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }

    private func setDelegate() {
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
    }
    
    private func setNavigationBar() {
        self.navigationItem.hidesBackButton = true
    }
   
}

//MARK: - Private
extension LoginViewController {
    
    private func openSignUpVC() {
        let vm = SignUpViewViewModel()
        let vc = SignUpViewController(vm: vm)
        vc.delegate = self
        self.navigationController?.modalPresentationStyle = .fullScreen
        self.show(vc, sender: self)
    }

    private func changePassword() {
        let vm = ResetPasswordViewViewModel()
        let vc = ResetPasswordViewController(vm: vm)
        self.show(vc, sender: self)
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

}
// MARK: - UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
    
}

extension LoginViewController: SignUpViewControllerDelegate {
    func signupDidComplete() {
        
        do {
            
            //TODO: level 
            
            let user = try UPlusUser.getCurrentUser()
            
            let vm = MyPageViewViewModel(user: user,
                                         memberShip: (true, user.userHasVipNft))
            let myPageVC = MyPageViewController(vm: vm)
            self.navigationController?.pushViewController(myPageVC, animated: true)
            
        }
        catch {
            print("Error getting saved user info from UserDefaults -- \(error)")
        }
        
    }
}
