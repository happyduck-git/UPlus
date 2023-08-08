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
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.text = LoginConstants.emailLabel
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let emailValidationText: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .thin)
        label.textColor = .systemRed
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var sendButton: UIButton = {
        let button = UIButton()
        button.setTitle(ResetPasswordConstants.sendButton, for: .normal)
        button.addTarget(self, action: #selector(sendResetEmailDidTap), for: .touchUpInside)
        button.backgroundColor = .systemGray
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let emailSentLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.text = LoginConstants.emailSentLabel
        label.numberOfLines = 2
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var backToLoginButton: UIButton = {
        let button = UIButton()
        button.isHidden = true
        button.setTitle(ResetPasswordConstants.backToLoginButton, for: .normal)
        button.addTarget(self, action: #selector(backToLoginDidTap), for: .touchUpInside)
        button.backgroundColor = .systemGray
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "비밀번호 변경"
        view.backgroundColor = .tertiarySystemBackground
        
        setUI()
        setLayout()
        setDelegate()
        
        bind()
    }
    
    // MARK: - Init
    init(vm: ResetPasswordViewViewModel) {
        self.viewModel = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Set UI & Layout
    private func setUI() {
        view.addSubviews(
            emailLabel,
            emailValidationText,
            emailTextField,
            sendButton,
            emailSentLabel,
            backToLoginButton
        )
    }

    private func setLayout() {
        NSLayoutConstraint.activate([
            emailLabel.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 5),
            emailLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 3),
            emailValidationText.centerYAnchor.constraint(equalTo: emailLabel.centerYAnchor),
            emailValidationText.leadingAnchor.constraint(equalToSystemSpacingAfter: emailLabel.trailingAnchor, multiplier: 1),
            emailTextField.topAnchor.constraint(equalToSystemSpacingBelow: emailLabel.bottomAnchor, multiplier: 2),
            emailTextField.leadingAnchor.constraint(equalTo: emailLabel.leadingAnchor),
            view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: emailTextField.trailingAnchor, multiplier: 3),
            sendButton.topAnchor.constraint(equalToSystemSpacingBelow: emailTextField.bottomAnchor, multiplier: 2),
            sendButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            emailSentLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emailSentLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            backToLoginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            backToLoginButton.topAnchor.constraint(equalToSystemSpacingBelow: emailSentLabel.bottomAnchor, multiplier: 2)
        ])
    }

    private func setDelegate() {
        emailTextField.delegate = self
    }
    
    private func bind() {
        func bindViewToViewModel() {
            self.emailTextField.textPublisher
                .removeDuplicates()
                .debounce(for: 0.5, scheduler: RunLoop.main)
                .assign(to: \.email, on: viewModel)
                .store(in: &bindings)
        }
        
        func bindViewModelToView() {
            viewModel.hasEmailSent
                .receive(on: RunLoop.main)
                .sink { [weak self] value in
                    guard let `self` = self else { return }
                    if value {
                        let vc = BackToLoginViewController(desc: LoginConstants.emailSentLabel)
                        navigationController?.pushViewController(vc, animated: true)
                    } else {
                        self.emailValidationText.text = viewModel.errorDescription
                    }
                }
                .store(in: &bindings)
            
            viewModel.$email.sink { value in
                if value.isEmpty {
                    self.emailValidationText.text = ""
                }
            }
            .store(in: &bindings)
            
        }
        
        bindViewToViewModel()
        bindViewModelToView()
    }
    
    @objc func sendResetEmailDidTap() {
        viewModel.sendResetEmail()
    }
    
    @objc func backToLoginDidTap() {
        navigationController?.popViewController(animated: true)
    }
}

extension ResetPasswordViewController: UITextFieldDelegate {
    
}
