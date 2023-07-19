//
//  EditUserInfoViewController.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/07/19.
//

import UIKit
import SwiftUI

class EditUserInfoViewController: UIViewController {

    //MARK: - UI Elements
    private let emailView: InformationInputView = {
        let inputView = InformationInputView(type: .email)
        inputView.setTitleText("사내 이메일")
        inputView.translatesAutoresizingMaskIntoConstraints = false
        return inputView
    }()
    
    private let currentPasswordView: InformationInputView = {
        let inputView = InformationInputView(type: .password)
        inputView.setTitleText("현재 비밀번호")
        inputView.translatesAutoresizingMaskIntoConstraints = false
        return inputView
    }()
    
    private let newPasswordView: InformationInputView = {
        let inputView = InformationInputView(type: .password)
        inputView.setTitleText("새 비밀번호")
        inputView.translatesAutoresizingMaskIntoConstraints = false
        return inputView
    }()
    
    private let newPasswordCheckView: InformationInputView = {
        let inputView = InformationInputView(type: .password)
        inputView.setTitleText("새 비밀번호 확인")
        inputView.translatesAutoresizingMaskIntoConstraints = false
        return inputView
    }()
    
    private lazy var confirmButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(editConfirmDidTap), for: .touchUpInside)
        button.setTitle(EditUserInfo.confirm, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.title = EditUserInfo.editVCTitle
        self.setUI()
        self.setLayout()
    }

}

extension EditUserInfoViewController {
    @objc private func editConfirmDidTap() {
        // TODO: 수정 완료 이후 action 구현필요.
        print("Need to define action for `수정하기` button.")
    }
}

//MARK: - Set UI & Layout
extension EditUserInfoViewController {
    
    private func setUI() {
        self.view.addSubviews(self.emailView,
                              self.currentPasswordView,
                              self.newPasswordView,
                              self.newPasswordCheckView,
                              self.confirmButton)
        
        self.emailView.disableUserInteraction()
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.emailView.topAnchor.constraint(equalToSystemSpacingBelow: self.view.safeAreaLayoutGuide.topAnchor, multiplier: 3),
            self.emailView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.view.safeAreaLayoutGuide.leadingAnchor, multiplier: 2),
            self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: self.emailView.trailingAnchor, multiplier: 2),
            
            self.currentPasswordView.topAnchor.constraint(equalToSystemSpacingBelow: self.emailView.bottomAnchor, multiplier: 3),
            self.currentPasswordView.leadingAnchor.constraint(equalTo: self.emailView.leadingAnchor),
            self.currentPasswordView.trailingAnchor.constraint(equalTo: self.emailView.trailingAnchor),
            
            self.newPasswordView.topAnchor.constraint(equalToSystemSpacingBelow: self.currentPasswordView.bottomAnchor, multiplier: 3),
            self.newPasswordView.leadingAnchor.constraint(equalTo: self.emailView.leadingAnchor),
            self.newPasswordView.trailingAnchor.constraint(equalTo: self.emailView.trailingAnchor),
            
            self.newPasswordCheckView.topAnchor.constraint(equalToSystemSpacingBelow: self.newPasswordView.bottomAnchor, multiplier: 3),
            self.newPasswordCheckView.leadingAnchor.constraint(equalTo: self.emailView.leadingAnchor),
            self.newPasswordCheckView.trailingAnchor.constraint(equalTo: self.emailView.trailingAnchor),
            
            self.confirmButton.heightAnchor.constraint(equalToConstant: self.view.frame.height / 15),
            self.view.safeAreaLayoutGuide.bottomAnchor.constraint(equalToSystemSpacingBelow: self.confirmButton.bottomAnchor, multiplier: 3),
            self.confirmButton.leadingAnchor.constraint(equalTo: self.emailView.leadingAnchor),
            self.confirmButton.trailingAnchor.constraint(equalTo: self.emailView.trailingAnchor)
        ])

    }
}
// MARK: - Preview
struct PreView: PreviewProvider {
    static var previews: some View {
        EditUserInfoViewController().toPreview()
    }
}
