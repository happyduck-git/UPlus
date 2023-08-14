//
//  WalletAddressBottomSheetViewController.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/14.
//

import UIKit

final class WalletAddressBottomSheetViewController: BottomSheetViewController {
    
    private let viewTitle: UILabel = {
        let label = UILabel()
        label.text = WalletConstants.walletAddress
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let cancelButton: UIButton = {
       let button = UIButton()
        button.setImage(UIImage(named: ImageAsset.xMarkBlack), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let addressLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = WalletConstants.walletAddress
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let warningLabel: UILabel = {
        let label = UILabel()
        label.textColor = UPlusColor.orange01
        label.backgroundColor = UPlusColor.orange02
        label.text = WalletConstants.warning
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let copyButton: UIButton = {
       let button = UIButton()
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.setTitle(WalletConstants.copy, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUI()
        self.setLayout()
        self.configure()
    }
    
}

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
                                       self.warningLabel,
                                       self.copyButton)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.viewTitle.topAnchor.constraint(equalToSystemSpacingBelow: self.containerView.topAnchor, multiplier: 2),
            self.viewTitle.centerXAnchor.constraint(equalTo: self.containerView.centerXAnchor),
            
            self.cancelButton.topAnchor.constraint(equalTo: self.viewTitle.topAnchor),
            self.containerView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.cancelButton.trailingAnchor, multiplier: 2),
            self.cancelButton.bottomAnchor.constraint(equalTo: self.viewTitle.bottomAnchor),
            
            self.addressLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.viewTitle.bottomAnchor, multiplier: 3),
            self.addressLabel.centerXAnchor.constraint(equalTo: self.viewTitle.centerXAnchor),
            self.warningLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.addressLabel.bottomAnchor, multiplier: 3),
            self.warningLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.containerView.leadingAnchor, multiplier: 3),
            self.containerView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.warningLabel.trailingAnchor, multiplier: 3),
            
            self.copyButton.topAnchor.constraint(equalToSystemSpacingBelow: self.warningLabel.bottomAnchor, multiplier: 4),
            self.copyButton.leadingAnchor.constraint(equalTo: self.warningLabel.leadingAnchor),
            self.copyButton.trailingAnchor.constraint(equalTo: self.warningLabel.trailingAnchor),
            self.containerView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.copyButton.bottomAnchor, multiplier: 3)
        ])
        self.addressLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
        self.copyButton.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
}
 
