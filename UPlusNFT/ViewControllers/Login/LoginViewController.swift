//
//  ViewController.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/06/20.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    private var authStateHandler: AuthStateDidChangeListenerHandle?

    private let emailLabel: UILabel = {
        let label = UILabel()
        label.text = LoginConstants.emailLabel
        label.textColor = .black
        return label
    }()

    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.text = "rkrudtls@gmail.com"
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
        textField.text = "Pass1234"
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

    private lazy var loginButton: UIButton = {
        let button = UIButton()
        button.setTitle(LoginConstants.loginButtonTitle, for: .normal)
        button.addTarget(self, action: #selector(loginUser), for: .touchUpInside)
        button.backgroundColor = .systemBlue
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var logoutButton: UIButton = {
        let button = UIButton()
        button.setTitle(LoginConstants.logoutButtonTitle, for: .normal)
        button.addTarget(self, action: #selector(logoutUser), for: .touchUpInside)
        button.backgroundColor = .systemBlue
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var createAccountButton: UIButton = {
        let button = UIButton()
        button.setTitle(LoginConstants.singInButtonTitle, for: .normal)
        button.backgroundColor = .systemOrange
        button.layer.borderWidth = 0.0
        button.addTarget(self, action: #selector(openSignUpVC), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .tertiarySystemBackground
        setUI()
        setLayout()
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
        view.addSubview(loginButton)
        view.addSubview(logoutButton)
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
            loginButton.topAnchor.constraint(equalToSystemSpacingBelow: textFieldStackView.bottomAnchor, multiplier: 2),
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoutButton.topAnchor.constraint(equalTo: loginButton.topAnchor),
            logoutButton.leadingAnchor.constraint(equalToSystemSpacingAfter: loginButton.trailingAnchor, multiplier: 2),
            createAccountButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            createAccountButton.topAnchor.constraint(equalToSystemSpacingBelow: loginButton.bottomAnchor, multiplier: 3)
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
    
    @objc private func updateUserPhoto() {
        guard let user = Auth.auth().currentUser else { return }
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.photoURL = URL(string: "https://i.seadn.io/gae/cB8JeJwP76w_GGSvQe-WpwfzA31aQZF2fVLA0FmvcsrISfe9e7HDQ_DE9QhilMaCW88vFo_EfBA6ItrNrUOxmbWlbq6suY0v8Sln?auto=format&w=256")
        changeRequest.commitChanges { error in
            print("Error commiting user info changes: \(String(describing: error))")
        }
        print("SAVED PHOTO URL: " + (user.photoURL?.absoluteString ?? "no photo url"))

    }

    private func login(email: String, password: String) async throws {
        do {
            try await Auth.auth().signIn(withEmail: email, password: password)
            print("Signed in.")
        }
        catch (let error) {
            print("Error loging in user: \(error)")
        }
    }

    @objc private func loginUser() {
        Task {
            guard let email = emailTextField.text,
                  let password = passwordTextField.text else {
                print("Email or Password found to be nil.")
                return
            }
            try await login(email: email, password: password)
               
            
        }
    }

    @objc private func logoutUser() {
        do {
            try Auth.auth().signOut()
        }
        catch {
            print("Error logout user \(error.localizedDescription)")
        }
    }

    private func createNewUser(email: String, password: String) async throws {
        try await Auth.auth().createUser(withEmail: email, password: password)
    }

    @objc private func createUser() {
        Task {
            guard let email = emailTextField.text,
                  let password = passwordTextField.text else {
                print("Email or Password found to be nil.")
                return
            }

            do {
                try await createNewUser(email: email, password: password)
            } catch {
                print("Error creating new user \(error)")
            }
        }
    }


}

extension LoginViewController: UITextFieldDelegate {
    
}
