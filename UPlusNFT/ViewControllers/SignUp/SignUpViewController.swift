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
//        txtField.text = "rkrudtls@gmail.com"
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
    
    private lazy var emailAuthButton: UIButton = {
        let button = UIButton()
        button.setTitle(SignUpConstants.authenticate, for: .normal)
        button.backgroundColor = .systemGray2
        button.isUserInteractionEnabled = false
        button.addTarget(self, action: #selector(authButtonDidTap), for: .touchUpInside)
        button.layer.cornerRadius = 3
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let emailAuthText: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 12, weight: .thin)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let passwordTitleLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.text = SignUpConstants.passwordLabel
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
//    private let passwordRuleLabel: UILabel = {
//        let label = UILabel()
//        label.isHidden = true
//        label.text = "8자리 이상 영대소문자와 숫자를 포함해야 합니다."
//        label.textColor = .systemGray
//        label.font = .systemFont(ofSize: 11, weight: .thin)
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
    
    private let passwordTextField: UITextField = {
        let txtField = UITextField()
        txtField.isHidden = true
        txtField.textColor = .black
        txtField.borderStyle = .roundedRect
        txtField.isSecureTextEntry = true
        txtField.textContentType = .newPassword
//        txtField.text = "Pass1234"
        txtField.backgroundColor = .systemGray3
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
        label.isHidden = true
        label.text = SignUpConstants.passwordCheckLabel
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let passwordCheckTextField: UITextField = {
        let txtField = UITextField()
        txtField.isHidden = true
        txtField.textColor = .black
        txtField.borderStyle = .roundedRect
        txtField.textContentType = .newPassword
        txtField.isSecureTextEntry = true
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
    
    /*
    private let nicknameTitleLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.text = SignUpConstants.nicknameLabel
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nicknameTextField: UITextField = {
        let txtField = UITextField()
        txtField.isHidden = true
        txtField.textColor = .black
        txtField.borderStyle = .roundedRect
        txtField.isUserInteractionEnabled = false
        txtField.backgroundColor = .systemGray3
        txtField.translatesAutoresizingMaskIntoConstraints = false
        return txtField
    }()
   */
    
    private let registerStatusLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.font = .systemFont(ofSize: 10, weight: .thin)
        label.textColor = .systemRed
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var registerButton: UIButton = {
        let button = UIButton()
        button.isHidden = true
        button.setTitle(SignUpConstants.register, for: .normal)
        button.addTarget(self, action: #selector(registerButtonDidTapped), for: .touchUpInside)
        button.backgroundColor = .systemGray2
        button.layer.cornerRadius = 3
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "회원가입"
        view.backgroundColor = .secondarySystemBackground
        setUI()
        setLayout()
        
        bind()
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
            emailAuthButton,
            emailTextField,
            emailValidationText,
            emailAuthText,
            passwordTitleLabel,
//            passwordRuleLabel,
            passwordTextField,
            passwordValidationText,
            passwordCheckTitleLabel,
            passwordCheckTextField,
            passwordCheckValidationText,
//            nicknameTitleLabel,
//            nicknameTextField,
            registerStatusLabel,
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
            
            emailAuthButton.topAnchor.constraint(equalToSystemSpacingBelow: emailValidationText.bottomAnchor, multiplier: 3),
            emailAuthButton.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
            emailAuthButton.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor),
            
            emailAuthText.topAnchor.constraint(equalToSystemSpacingBelow: emailAuthButton.bottomAnchor, multiplier: 2),
            emailAuthText.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            placeHolderLabel.topAnchor.constraint(equalToSystemSpacingBelow: placeHolderView.topAnchor, multiplier: 1),
            placeHolderLabel.leadingAnchor.constraint(equalTo: placeHolderView.leadingAnchor),
            placeHolderView.trailingAnchor.constraint(equalToSystemSpacingAfter: placeHolderLabel.trailingAnchor, multiplier: 1),
            placeHolderView.bottomAnchor.constraint(equalToSystemSpacingBelow: placeHolderLabel.bottomAnchor, multiplier: 1),
            
            passwordTitleLabel.topAnchor.constraint(equalToSystemSpacingBelow: emailValidationText.bottomAnchor, multiplier: 2),
            passwordTitleLabel.leadingAnchor.constraint(equalTo: emailTitleLabel.leadingAnchor),
            
//            passwordRuleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: passwordTitleLabel.trailingAnchor, multiplier: 1),
//            passwordRuleLabel.bottomAnchor.constraint(equalTo: passwordTitleLabel.bottomAnchor),
            
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
            
            registerStatusLabel.topAnchor.constraint(equalToSystemSpacingBelow: passwordCheckValidationText.bottomAnchor, multiplier: 6),
            registerStatusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            registerButton.topAnchor.constraint(equalToSystemSpacingBelow: registerStatusLabel.bottomAnchor, multiplier: 1),
            registerButton.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
            registerButton.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor)
            
        ])
    }
    

    
    private func bind() {
        func bindViewToViewModel() {
            self.emailTextField.textPublisher
                .debounce(for: SignUpConstants.textFieldDebounce, scheduler: RunLoop.current)
                .removeDuplicates()
                .assign(to: \.email, on: signupVM)
                .store(in: &bindings)
            
            self.passwordTextField.textPublisher
                .debounce(for: SignUpConstants.textFieldDebounce, scheduler: RunLoop.current)
                .removeDuplicates()
                .assign(to: \.password, on: signupVM)
                .store(in: &bindings)
            
            self.passwordCheckTextField.textPublisher
                .debounce(for: SignUpConstants.textFieldDebounce, scheduler: RunLoop.current)
                .removeDuplicates()
                .assign(to: \.passwordCheck, on: signupVM)
                .store(in: &bindings)
            
//            self.nicknameTextField.textPublisher
//                .debounce(for: SignUpConstants.textFieldDebounce, scheduler: RunLoop.current)
//                .removeDuplicates()
//                .assign(to: \.nickname, on: signupVM)
//                .store(in: &bindings)
        }
        
        func bindViewModelToView() {
            
            signupVM.isEmailSent
                .receive(on: DispatchQueue.main)
                .sink { [weak self] isSent in
                    guard let `self` = self else { return }
                   
                    let alertText: String = isSent ? "인증메일이 \(signupVM.fullEmail)(으)로 전송되었습니다.\n받으신 이메일을 열어 회원가입을 완료해주세요." : "이메일 전송에 실패하였습니다."
                    let backgroundColor: UIColor = isSent ? .systemGray : .black
                    let textColor: UIColor = isSent ? .systemBlue : .systemRed
                    
                    self.emailTextField.isUserInteractionEnabled = false
                    self.emailValidationText.text = " "
                    self.emailAuthButton.backgroundColor = backgroundColor
                    self.emailAuthButton.isUserInteractionEnabled = false
                    self.emailAuthText.text = alertText
                    self.emailAuthText.textColor = textColor
                    
                }
                .store(in: &bindings)
            
            signupVM.isAuthenticated
                .receive(on: DispatchQueue.main)
                .sink { [weak self] value in
                    guard let `self` = self else { return }
                    if value {

                        // TODO: Hide navigation back button & show X(cancel icon) on the rightNavButton
                        self.emailAuthText.isHidden = true
                        self.emailTextField.isUserInteractionEnabled = false
                        self.emailAuthButton.isHidden = true
                        self.emailValidationText.text = SignUpConstants.authCompleted // TODO: check symbol 넣기
                        
                        self.passwordTitleLabel.isHidden = false
                        self.passwordTextField.isHidden = false
                        self.passwordTextField.backgroundColor = .white
                       
                        self.passwordCheckTitleLabel.isHidden = false
                        self.passwordCheckTextField.isHidden = false
                        self.passwordCheckTextField.backgroundColor = .white
                     
                        self.registerButton.isHidden = false
                        
                    }
                }
                .store(in: &bindings)

            signupVM.isEmailValid
                .receive(on: DispatchQueue.main)
                .sink { [weak self] valid in
                    guard let `self` = self else { return }
                    let emailText = self.emailTextField.text ?? ""
                   
                    if valid {
                        self.emailAuthButton.backgroundColor = .black
                        self.emailValidationText.text = "올바른 이메일 주소입니다."
                        self.emailValidationText.textColor = .systemBlue
                        self.emailAuthButton.isUserInteractionEnabled = true
                    } else if emailText.isEmpty {
                        self.emailValidationText.text = " "
                        self.emailAuthButton.backgroundColor = .systemGray2
                        self.emailAuthButton.isUserInteractionEnabled = false
                    } else {
                        self.emailValidationText.text = "올바른 형식의 이메일이 아닙니다."
                        self.emailValidationText.textColor = .systemRed
                        self.emailAuthButton.backgroundColor = .systemGray2
                        self.emailAuthButton.isUserInteractionEnabled = false
                    }
                }
                .store(in: &bindings)
            
            signupVM.isPasswordValid
                .receive(on: DispatchQueue.main)
                .sink { [weak self] valid in
                    guard let `self` = self else { return }
                    let passwordText = self.passwordTextField.text ?? ""
                    
                    if valid {
                        self.passwordValidationText.text = " "
                    } else if passwordText.isEmpty {
                        self.passwordValidationText.text = " "
                    } else {
                        self.passwordValidationText.isHidden = false
                        self.passwordValidationText.text = SignUpConstants.passwordValidation
                    }
                }
                .store(in: &bindings)
            
            signupVM.isPasswordSame
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
            
            signupVM.isAllInfoChecked
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
            
            signupVM.isUserCreated
                .receive(on: DispatchQueue.main)
                .sink { [weak self] valid in
                    guard let `self` = self else { return }
                    if valid {
                       /*
                        navigationController?.popViewController(animated: true)
                        */
                        let vc = BackToLoginViewController(desc: SignUpConstants.sinUpSuccessLabel)
                        navigationController?.pushViewController(vc, animated: true)
                        
                    } else {
                        self.emailValidationText.text = self.signupVM.errorDescription
                    }
                }
                .store(in: &bindings)
        }
        
        bindViewToViewModel()
        bindViewModelToView()
    }
    
    @objc private func authButtonDidTap() {
        self.signupVM.sendEmailValification()
    }
    
    @objc private func registerButtonDidTapped() {
        self.signupVM.createNewUser()
    }
}
