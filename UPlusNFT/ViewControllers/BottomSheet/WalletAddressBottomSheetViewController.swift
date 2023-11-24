//
//  WalletAddressBottomSheetViewController.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/14.
//

import UIKit
import Combine

final class WalletAddressBottomSheetViewController: BottomSheetViewController {
    
    // MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    // MARK: - UI Elements
    private let viewTitle: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: UPlusFont.h2, weight: .bold)
        label.textColor = .black
        label.text = WalletConstants.walletAddress
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: ImageAssets.xMarkBlack), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let addressLabel: UILabel = {
        let label = UILabel()
        label.lineBreakMode = .byTruncatingMiddle
        label.numberOfLines = 1
        label.textAlignment = .center
        label.textColor = UPlusColor.gray09
        label.font = .systemFont(ofSize: UPlusFont.h2, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let copyButton: UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.layer.cornerRadius = 8.0
        button.backgroundColor = UPlusColor.buttonActivated
        button.setTitleColor(UPlusColor.gray08, for: .normal)
        button.setTitle(WalletConstants.copy, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(defaultHeight: CGFloat = 600) {
        super.init(defaultHeight: 250)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUI()
        self.setLayout()
        
        self.configure()
        self.bind()
    }
    
}

// MARK: - Bind
extension WalletAddressBottomSheetViewController {
    
    private func bind() {
        func bindViewToViewModel() {
            
            self.cancelButton.tapPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    guard let `self` = self else { return }
                    
                    self.dismissView {
                        
                    }
                }
                .store(in: &bindings)
            
            self.copyButton.tapPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    guard let `self` = self else { return }
                    
                    UIPasteboard.general.string = self.addressLabel.text
                    // TEMP
                    self.copyButton.setTitle("복사 완료!", for: .normal)
                }
                .store(in: &bindings)
        }
        
        func bindViewModelToView() {
            
        }
        
        bindViewToViewModel()
        bindViewModelToView()
    }
    
}

// MARK: - Configure
extension WalletAddressBottomSheetViewController {
    private func configure() {
        do {
            let user = try UPlusUser.getCurrentUser()
            self.addressLabel.text = user.userWalletAddress
        }
        catch {
            print("Error getting user from UserDefaults -- \(error)")
        }
    }
}

extension WalletAddressBottomSheetViewController {
    private func setUI() {
        self.containerView.addSubviews(self.viewTitle,
                                       self.cancelButton,
                                       self.addressLabel,
                                       self.copyButton)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.viewTitle.topAnchor.constraint(equalToSystemSpacingBelow: self.containerView.topAnchor, multiplier: 3),
            self.viewTitle.centerXAnchor.constraint(equalTo: self.containerView.centerXAnchor),
            
            self.cancelButton.topAnchor.constraint(equalTo: self.viewTitle.topAnchor),
            self.containerView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.cancelButton.trailingAnchor, multiplier: 2),
            self.cancelButton.bottomAnchor.constraint(equalTo: self.viewTitle.bottomAnchor),
            
            self.addressLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.viewTitle.bottomAnchor, multiplier: 3),
            self.addressLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.containerView.leadingAnchor, multiplier: 5),
            self.containerView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.addressLabel.trailingAnchor, multiplier: 5),
            
            self.copyButton.topAnchor.constraint(equalToSystemSpacingBelow: self.addressLabel.bottomAnchor, multiplier: 2),
            self.copyButton.heightAnchor.constraint(equalToConstant: LoginConstants.buttonHeight),
            self.copyButton.leadingAnchor.constraint(equalTo: self.addressLabel.leadingAnchor),
            self.copyButton.trailingAnchor.constraint(equalTo: self.addressLabel.trailingAnchor),
            self.containerView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.copyButton.bottomAnchor, multiplier: 3)
        ])
        self.addressLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
        self.copyButton.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct WalletAddressBottomSheetViewController_Preview: PreviewProvider {
    static var previews: some View {
        
        WalletAddressBottomSheetViewController().toPreview()
    }
}
#endif
