//
//  SignUpViewController.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/06/20.
//

import UIKit
import Combine

final class SignUpViewController: UIViewController {
    
    private var signupVM: SignUpViewViewModel
    private var bindings = Set<AnyCancellable>()
    
    // MARK: - UI Elements
    private let emailTitleLabel: UILabel = {
        let label = UILabel()
        label.text = SignUpConstants.emailLabel
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
        label.text = "@lguplus.net"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emailTextField: UITextField = {
        let txtField = UITextField()
//        txtField.text = "rkrudtls@gmail.com" //DEBUG
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
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let passwordRuleLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.text = "비밀번호는 6자 이상 입력하여야 합니다."
        label.textColor = .systemGray
        label.font = .systemFont(ofSize: 11, weight: .thin)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let passwordTextField: UITextField = {
        let txtField = UITextField()
        txtField.textColor = .black
        txtField.borderStyle = .roundedRect
        txtField.isSecureTextEntry = true
        txtField.textContentType = .newPassword
//        txtField.text = "Pass1234" // DEBUG
        txtField.translatesAutoresizingMaskIntoConstraints = false
        return txtField
    }()
    
    private let passwordValidationText: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.font = .systemFont(ofSize: 10, weight: .thin)
        label.textColor = .systemRed
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let passwordCheckTitleLabel: UILabel = {
        let label = UILabel()
        label.text = SignUpConstants.passwordCheckLabel
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let passwordCheckTextField: UITextField = {
        let txtField = UITextField()
        txtField.textColor = .black
        txtField.borderStyle = .roundedRect
        txtField.textContentType = .newPassword
        txtField.isSecureTextEntry = true
        txtField.isUserInteractionEnabled = false
        txtField.backgroundColor = .systemGray3
        txtField.translatesAutoresizingMaskIntoConstraints = false
        return txtField
    }()
    
    private let passwordCheckValidationText: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.font = .systemFont(ofSize: 10, weight: .thin)
        label.textColor = .systemRed
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var registerButton: UIButton = {
        let button = UIButton()
        button.setTitle(SignUpConstants.register, for: .normal)
        button.addTarget(self, action: #selector(registerButtonDidTap), for: .touchUpInside)
        button.backgroundColor = .systemGray2
        button.layer.cornerRadius = 3
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "회원가입"
        view.backgroundColor = .secondarySystemBackground
        
        self.setUI()
        self.setLayout()
        self.setNavigationItem()
        
        self.bind()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationItem.hidesBackButton = true
    }
    
    // MARK: - Init
    init(vm: SignUpViewViewModel) {
        self.signupVM = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private
    private func setUI() {
        view.addSubviews(
            emailTitleLabel,
            emailTextField,
            emailValidationText,
            passwordTitleLabel,
            passwordRuleLabel,
            passwordTextField,
            passwordValidationText,
            passwordCheckTitleLabel,
            passwordCheckTextField,
            passwordCheckValidationText,
            registerButton
        )
        
        // Adding a PlaceHolderView
        placeHolderView.addSubview(placeHolderLabel)
        self.emailTextField.rightView = placeHolderView
        self.emailTextField.rightViewMode = .always
    }
     
    private func setLayout() {
        NSLayoutConstraint.activate([
            emailTitleLabel.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 3),
            emailTitleLabel.leadingAnchor.constraint(lessThanOrEqualToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 3),
            
            emailTextField.topAnchor.constraint(equalToSystemSpacingBelow: emailTitleLabel.bottomAnchor, multiplier: 1),
            emailTextField.leadingAnchor.constraint(equalTo: emailTitleLabel.leadingAnchor),
            view.trailingAnchor.constraint(equalToSystemSpacingAfter: emailTextField.trailingAnchor, multiplier: 3),
            
            emailValidationText.topAnchor.constraint(equalToSystemSpacingBelow: emailTextField.bottomAnchor, multiplier: 1),
            emailValidationText.leadingAnchor.constraint(equalTo: emailTitleLabel.leadingAnchor),
            
            placeHolderLabel.topAnchor.constraint(equalToSystemSpacingBelow: placeHolderView.topAnchor, multiplier: 1),
            placeHolderLabel.leadingAnchor.constraint(equalTo: placeHolderView.leadingAnchor),
            placeHolderView.trailingAnchor.constraint(equalToSystemSpacingAfter: placeHolderLabel.trailingAnchor, multiplier: 1),
            placeHolderView.bottomAnchor.constraint(equalToSystemSpacingBelow: placeHolderLabel.bottomAnchor, multiplier: 1),
            
            passwordTitleLabel.topAnchor.constraint(equalToSystemSpacingBelow: emailValidationText.bottomAnchor, multiplier: 2),
            passwordTitleLabel.leadingAnchor.constraint(equalTo: emailTitleLabel.leadingAnchor),
            
            passwordRuleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: passwordTitleLabel.trailingAnchor, multiplier: 1),
            passwordRuleLabel.bottomAnchor.constraint(equalTo: passwordTitleLabel.bottomAnchor),
            
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

            registerButton.topAnchor.constraint(equalToSystemSpacingBelow: passwordCheckValidationText.bottomAnchor, multiplier: 1),
            registerButton.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
            registerButton.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor)
            
        ])
    }
    
    private func setNavigationItem() {
        self.navigationItem.hidesBackButton = true
        
        let cancelButton = UIBarButtonItem(image: UIImage(named: ImageAsset.xMarkBlack)?.withTintColor(.systemGray, renderingMode: .alwaysOriginal),
                                          style: .plain,
                                          target: self,
                                           action: #selector(cancelButtonDidTap))
        
        navigationItem.setRightBarButton(cancelButton, animated: true)
    }

    
    private func bind() {
        func bindViewToViewModel() {
            self.emailTextField.textPublisher
                .debounce(for: SignUpConstants.textFieldDebounce, scheduler: RunLoop.current)
                .removeDuplicates()
                .assign(to: \.email, on: self.signupVM)
                .store(in: &bindings)
            
            self.passwordTextField.textPublisher
                .debounce(for: SignUpConstants.textFieldDebounce, scheduler: RunLoop.current)
                .removeDuplicates()
                .assign(to: \.password, on: self.signupVM)
                .store(in: &bindings)
            
            self.passwordCheckTextField.textPublisher
                .debounce(for: SignUpConstants.textFieldDebounce, scheduler: RunLoop.current)
                .removeDuplicates()
                .assign(to: \.passwordCheck, on: self.signupVM)
                .store(in: &bindings)

        }
        
        func bindViewModelToView() {
            
            self.signupVM.$email
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    guard let `self` = self else { return }
                    if $0.isEmpty {
                        self.emailValidationText.text = ""
                    }
                }
                .store(in: &bindings)
            
            self.signupVM.isPasswordValid
                .receive(on: DispatchQueue.main)
                .sink { [weak self] valid in
                    guard let `self` = self else { return }
                    let passwordText = self.passwordTextField.text ?? ""
                    
                    if valid {
                        self.passwordValidationText.text = " "
                        self.passwordCheckTextField.isUserInteractionEnabled = true
                        self.passwordCheckTextField.backgroundColor = .white
                    } else if passwordText.isEmpty {
                        self.passwordValidationText.text = " "
                        self.passwordCheckTextField.isUserInteractionEnabled = false
                        self.passwordCheckTextField.backgroundColor = .systemGray3
                    } else {
                        self.passwordValidationText.isHidden = false
                        self.passwordValidationText.text = SignUpConstants.passwordValidation
                        self.passwordCheckTextField.isUserInteractionEnabled = false
                        self.passwordCheckTextField.backgroundColor = .systemGray3
                    }
                }
                .store(in: &bindings)
            
            self.signupVM.isPasswordSame
                .receive(on: DispatchQueue.main)
                .sink { [weak self] valid in
                    guard let `self` = self else { return }
                    let passwordText = self.passwordCheckTextField.text ?? ""
                    
                    if valid {
                        self.passwordCheckValidationText.text = " "
                    } else if passwordText.isEmpty {
                        self.passwordCheckValidationText.text = " "
                    } else {
                        self.passwordCheckValidationText.isHidden = false
                        self.passwordCheckValidationText.text = SignUpConstants.passwordCheckValidation
                    }
                }
                .store(in: &bindings)
            
            self.signupVM.isAllInfoChecked
                .receive(on: DispatchQueue.main)
                .sink { [weak self] valid in
                    guard let `self` = self else { return }
                    if valid {
                        self.registerButton.isUserInteractionEnabled = true
                        self.registerButton.backgroundColor = .black
                    } else {
                        self.registerButton.isUserInteractionEnabled = false
                        self.registerButton.backgroundColor = .systemGray2
                    }
                }
                .store(in: &bindings)
            
            self.signupVM.isUserCreated
                .receive(on: DispatchQueue.main)
                .sink { [weak self] valid in
                    guard let `self` = self else { return }
                    if valid {
                       
                        let vm = SignUpCompleteViewViewModel()
                        let vc = SignUpCompleteViewController(vm: vm)
                        
                        self.navigationController?.pushViewController(vc, animated: true)
                        
                    } else {
                        self.emailValidationText.textColor = .systemRed
                        self.emailValidationText.text = self.signupVM.errorDescription
                    }
                }
                .store(in: &bindings)
            
        }
        
        bindViewToViewModel()
        bindViewModelToView()
    }
    
}

//MARK: - Private
extension SignUpViewController {

    @objc private func registerButtonDidTap() {
        Task {
            await self.signupVM.createNewUser()
            if !self.signupVM.isValidUser {
                self.emailValidationText.text = self.signupVM.errorDescription
            }
        }
    }
    
    @objc private func cancelButtonDidTap() {
        self.navigationController?.popViewController(animated: true)
    }
}
