//
//  LogOutBottomSheetViewController.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/08/27.
//

import Foundation
import Combine
import FirebaseAuth

protocol LogOutBottomSheetViewControllerDelegate: AnyObject {
    func signOutDidTap()
}

final class LogOutBottomSheetViewController: BottomSheetViewController {
    
    // MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    // MARK: - Delegate
    weak var delegate: LogOutBottomSheetViewControllerDelegate?
    
    // MARK: - UI Elements
    private let logoutTitle: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.text = LogoutConstants.logout
        label.font = .systemFont(ofSize: UPlusFont.h2, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let logoutImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: ImageAssets.logoutFace)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let logoutDescription: UILabel = {
        let label = UILabel()
        label.textColor = UPlusColor.mint04
        label.textAlignment = .center
        label.text = LogoutConstants.logoutDesc
        label.font = .systemFont(ofSize: UPlusFont.h2, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let buttonStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 16.0
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.layer.cornerRadius = 8.0
        button.titleLabel?.font = .systemFont(ofSize: UPlusFont.body1, weight: .bold)
        button.setTitleColor(UPlusColor.gray08, for: .normal)
        button.setTitle(LogoutConstants.cancel, for: .normal)
        button.backgroundColor = UPlusColor.gray02
        return button
    }()
    
    private let logoutButton: UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.layer.cornerRadius = 8.0
        button.titleLabel?.font = .systemFont(ofSize: UPlusFont.body1, weight: .bold)
        button.setTitleColor(UPlusColor.gray08, for: .normal)
        button.setTitle(LogoutConstants.doLogout, for: .normal)
        button.backgroundColor = UPlusColor.mint03
        return button
    }()
    
    // MARK: - Init
    override init(defaultHeight: CGFloat = 380) {
        super.init(defaultHeight: defaultHeight)
        
        self.setUI()
        self.setLayout()
        
        self.bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Bind
extension LogOutBottomSheetViewController {
    private func bind() {
        func bindViewToViewModel() {
            self.cancelButton.tapPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    guard let `self` = self else { return }
                    
                    self.dismissView {}
                }
                .store(in: &bindings)
            
            self.logoutButton.tapPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    guard let `self` = self else { return }
                    
                    self.userLogOut()
                    self.dismissView {}
                }
                .store(in: &bindings)
        }
        func bindViewModelToView() {
            
        }
        
        bindViewToViewModel()
        bindViewModelToView()
    }
}

// MARK: - Private
extension LogOutBottomSheetViewController {
    private func userLogOut() {
        do {
            try Auth.auth().signOut()
            self.delegate?.signOutDidTap()
        }
        catch {
            let alert = UIAlertController(
                title: "로그아웃 실패",
                message: "로그아웃에 실패하였습니다. 잠시 후 다시 시도해주세요.",
                preferredStyle: .alert
            )
        let action = UIAlertAction(title: "확인", style: .cancel)
        alert.addAction(action)
            
            self.present(alert, animated: true)
        }
    }
}

// MARK: - Set UI & Layout
extension LogOutBottomSheetViewController {
    private func setUI() {
        self.containerView.addSubviews(self.logoutTitle,
                                       self.logoutImage,
                                       self.logoutDescription,
                                       self.buttonStack)
        
        self.buttonStack.addArrangedSubviews(self.cancelButton,
                                             self.logoutButton)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.logoutTitle.topAnchor.constraint(equalToSystemSpacingBelow: self.containerView.topAnchor, multiplier: 2),
            self.logoutTitle.leadingAnchor.constraint(equalToSystemSpacingAfter: self.containerView.leadingAnchor, multiplier: 2),
            self.containerView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.logoutTitle.trailingAnchor, multiplier: 2),
            
            self.logoutImage.topAnchor.constraint(equalToSystemSpacingBelow: self.logoutTitle.bottomAnchor, multiplier: 2),
            self.logoutImage.centerXAnchor.constraint(equalTo: self.containerView.centerXAnchor),
            
            self.logoutDescription.topAnchor.constraint(equalToSystemSpacingBelow: self.logoutImage.bottomAnchor, multiplier: 2),
            self.logoutDescription.leadingAnchor.constraint(equalToSystemSpacingAfter: self.containerView.leadingAnchor, multiplier: 2),
            self.containerView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.logoutDescription.trailingAnchor, multiplier: 2),
            
            self.buttonStack.topAnchor.constraint(equalToSystemSpacingBelow: self.logoutDescription.bottomAnchor, multiplier: 4),
            self.buttonStack.leadingAnchor.constraint(equalToSystemSpacingAfter: self.containerView.leadingAnchor, multiplier: 2),
            self.buttonStack.heightAnchor.constraint(equalToConstant: LoginConstants.buttonHeight),
            self.containerView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.buttonStack.trailingAnchor, multiplier: 2),
            self.containerView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.buttonStack.bottomAnchor, multiplier: 2)
        ])
        
        self.logoutTitle.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct LogOutBottomSheetViewController_Preview: PreviewProvider {
    static var previews: some View {
        
        LogOutBottomSheetViewController().toPreview()
    }
}
#endif
