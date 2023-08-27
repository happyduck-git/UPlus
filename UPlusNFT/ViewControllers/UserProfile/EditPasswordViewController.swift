//
//  EditUserInfoViewController.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/07/19.
//

import UIKit
import SwiftUI
import Combine

class EditPasswordViewController: UIViewController {

    // MARK: - Dependency
    private let vm: EditPasswordViewViewModel
    
    // MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    //MARK: - UI Elements
    private let topContainerView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 8.0
        view.backgroundColor = UPlusColor.gray02
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let emailInfo: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = EditPasswordConstants.emailInfo
        label.font = .systemFont(ofSize: UPlusFont.body1, weight: .regular)
        label.textColor = UPlusColor.gray06
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let email: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: UPlusFont.body1, weight: .bold)
        label.textColor = UPlusColor.gray08
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let currentPasswordView: InformationInputView = {
        let inputView = InformationInputView(type: .password)
        inputView.setTitleText("현재 비밀번호")
        inputView.translatesAutoresizingMaskIntoConstraints = false
        return inputView
    }()
    
    private let currentPasswordValidationText: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .thin)
        label.text = " "
        label.textColor = .systemRed
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let newPasswordView: InformationInputView = {
        let inputView = InformationInputView(type: .password)
        inputView.setTitleText("새 비밀번호")
        inputView.translatesAutoresizingMaskIntoConstraints = false
        return inputView
    }()
    
    private let newPasswordValidationText: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .thin)
        label.text = " "
        label.textColor = .systemRed
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let newPasswordCheckView: InformationInputView = {
        let inputView = InformationInputView(type: .password)
        inputView.setTitleText("새 비밀번호 확인")
        inputView.translatesAutoresizingMaskIntoConstraints = false
        return inputView
    }()
    
    private let newPasswordCheckValidationText: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .thin)
        label.text = " "
        label.textColor = .systemRed
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var confirmButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(editConfirmDidTap), for: .touchUpInside)
        button.setTitle(EditPasswordConstants.edit, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    // MARK: - Init
    init(vm: EditPasswordViewViewModel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.title = EditPasswordConstants.editVCTitle
        
        self.setUI()
        self.setLayout()
        self.configure()
        self.bind()
        hideKeyboardWhenTappedAround()
    }

}

extension EditPasswordViewController {
    private func bind() {
        func bindViewToViewModel() {
            self.currentPasswordView.textField.textPublisher
                .assign(to: \.currentPassword, on: self.vm)
                .store(in: &bindings)
            
            self.newPasswordView.textField.textPublisher
                .assign(to: \.newPassword, on: self.vm)
                .store(in: &bindings)
            
            self.newPasswordCheckView.textField.textPublisher
                .assign(to: \.newPasswordCheck, on: self.vm)
                .store(in: &bindings)
            
            self.confirmButton.tapPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    guard let `self` = self else { return }
                    
                    self.editConfirmDidTap()
                }
                .store(in: &bindings)
        }
        func bindViewModelToView() {
            self.vm.$currentPassword
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    guard let `self` = self else { return }
                    
                    var text: String = ""
                    
                    if (!$0.isEmpty && $0.count < 6) {
                        text = "비밀번호는 6자리 이상입니다."
                    }
                    self.currentPasswordValidationText.text = text
                }
                .store(in: &bindings)
            
            self.vm.$newPassword
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    guard let `self` = self else { return }
                    var text: String = ""
                    
                    if (!$0.isEmpty && $0.count < 6) {
                        text = "비밀번호는 6자리 이상입니다."
                    }
                    self.newPasswordValidationText.text = text
                }
                .store(in: &bindings)
            
            self.vm.isAllFilled
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    guard let `self` = self else { return }
                    
                    let textColor: UIColor = $0 ? .white : UPlusColor.gray08
                    let bgColor: UIColor = $0 ? UPlusColor.mint03 : UPlusColor.gray02
                    let interactive: Bool = $0 ? true : false
                        
                    self.confirmButton.setTitleColor(textColor, for: .normal)
                    self.confirmButton.backgroundColor = bgColor
                    self.confirmButton.isUserInteractionEnabled = interactive
                }
                .store(in: &bindings)
            
            self.vm.isSame
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    guard let `self` = self else { return }
                    var text: String = ""
                    
                    if !self.vm.newPasswordCheck.isEmpty && !$0 {
                        text = "비밀번호가 일치하지 않습니다."
                    } else {
                        text = ""
                    }
                    
                    self.newPasswordCheckValidationText.text = text
                }
                .store(in: &bindings)
            
        }
        
        bindViewToViewModel()
        bindViewModelToView()
    }
}

extension EditPasswordViewController {
    @objc private func editConfirmDidTap() {
        
        Task {
            do {
                try await self.vm.updatePassword(newPassword: self.vm.newPassword)
            }
            catch {
                print("Error updating password -- \(error)")
            }
        }
    }
    
    private func updatePassword() {
        
    }
}

// MARK: - Configure
extension EditPasswordViewController {
    private func configure() {
        do {
            let user = try UPlusUser.getCurrentUser()
            self.email.text = user.userNickname + LoginConstants.uplusEmailSuffix
        }
        catch {
            // TODO: 유저정보 에러 Alert.
        }
        
    }
}

//MARK: - Set UI & Layout
extension EditPasswordViewController {
    
    private func setUI() {
        self.view.addSubviews(self.topContainerView,
                              self.currentPasswordView,
                              self.currentPasswordValidationText,
                              self.newPasswordView,
                              self.newPasswordValidationText,
                              self.newPasswordCheckView,
                              self.newPasswordCheckValidationText,
                              self.confirmButton)
        
        self.topContainerView.addSubviews(self.emailInfo,
                                          self.email)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.topContainerView.topAnchor.constraint(equalToSystemSpacingBelow: self.view.safeAreaLayoutGuide.topAnchor, multiplier: 3),
            self.topContainerView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.view.safeAreaLayoutGuide.leadingAnchor, multiplier: 2),
            self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: self.topContainerView.trailingAnchor, multiplier: 2),
            self.topContainerView.heightAnchor.constraint(equalToConstant: 84),
            
            self.currentPasswordView.topAnchor.constraint(equalToSystemSpacingBelow: self.topContainerView.bottomAnchor, multiplier: 6),
            self.currentPasswordView.leadingAnchor.constraint(equalTo: self.topContainerView.leadingAnchor),
            self.currentPasswordView.trailingAnchor.constraint(equalTo: self.topContainerView.trailingAnchor),
            
            self.currentPasswordValidationText.topAnchor.constraint(equalTo: self.currentPasswordView.bottomAnchor),
            self.currentPasswordValidationText.leadingAnchor.constraint(equalTo: self.currentPasswordView.leadingAnchor),
            self.currentPasswordValidationText.trailingAnchor.constraint(equalTo: self.currentPasswordView.trailingAnchor),
            
            self.newPasswordView.topAnchor.constraint(equalToSystemSpacingBelow: self.currentPasswordValidationText.bottomAnchor, multiplier: 3),
            self.newPasswordView.leadingAnchor.constraint(equalTo: self.topContainerView.leadingAnchor),
            self.newPasswordView.trailingAnchor.constraint(equalTo: self.topContainerView.trailingAnchor),
            
            self.newPasswordValidationText.topAnchor.constraint(equalTo: self.newPasswordView.bottomAnchor),
            self.newPasswordValidationText.leadingAnchor.constraint(equalTo: self.newPasswordView.leadingAnchor),
            self.newPasswordValidationText.trailingAnchor.constraint(equalTo: self.newPasswordView.trailingAnchor),
            
            self.newPasswordCheckView.topAnchor.constraint(equalToSystemSpacingBelow: self.newPasswordValidationText.bottomAnchor, multiplier: 3),
            self.newPasswordCheckView.leadingAnchor.constraint(equalTo: self.topContainerView.leadingAnchor),
            self.newPasswordCheckView.trailingAnchor.constraint(equalTo: self.topContainerView.trailingAnchor),
            
            self.newPasswordCheckValidationText.topAnchor.constraint(equalTo: self.newPasswordCheckView.bottomAnchor),
            self.newPasswordCheckValidationText.leadingAnchor.constraint(equalTo: self.newPasswordCheckView.leadingAnchor),
            self.newPasswordCheckValidationText.trailingAnchor.constraint(equalTo: self.newPasswordCheckView.trailingAnchor),
            
            self.confirmButton.heightAnchor.constraint(equalToConstant: self.view.frame.height / 15),
            self.view.safeAreaLayoutGuide.bottomAnchor.constraint(equalToSystemSpacingBelow: self.confirmButton.bottomAnchor, multiplier: 3),
            self.confirmButton.leadingAnchor.constraint(equalTo: self.topContainerView.leadingAnchor),
            self.confirmButton.trailingAnchor.constraint(equalTo: self.topContainerView.trailingAnchor)
        ])

        NSLayoutConstraint.activate([
            self.emailInfo.topAnchor.constraint(equalToSystemSpacingBelow: self.topContainerView.topAnchor, multiplier: 2),
            self.emailInfo.leadingAnchor.constraint(equalToSystemSpacingAfter: self.topContainerView.leadingAnchor, multiplier: 1),
            self.topContainerView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.emailInfo.trailingAnchor, multiplier: 1),
            
            self.email.topAnchor.constraint(equalToSystemSpacingBelow: self.emailInfo.bottomAnchor, multiplier: 1),
            self.email.leadingAnchor.constraint(equalTo: self.emailInfo.leadingAnchor),
            self.email.trailingAnchor.constraint(equalTo: self.emailInfo.trailingAnchor),
            self.topContainerView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.email.bottomAnchor, multiplier: 2)
        ])
    }
}

