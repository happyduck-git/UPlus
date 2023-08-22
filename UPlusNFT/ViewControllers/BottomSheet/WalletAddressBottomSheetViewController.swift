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
        button.setImage(UIImage(named: ImageAsset.xMarkBlack), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let addressLabel: UILabel = {
        let label = UILabel()
        label.lineBreakMode = .byTruncatingMiddle
        label.numberOfLines = 1
        label.textColor = UPlusColor.gray09
        label.font = .systemFont(ofSize: UPlusFont.h2, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let warningLabel: UILabel = {
        let label = UILabel()
        label.textColor = UPlusColor.orange01
        label.backgroundColor = UPlusColor.orange02
        label.text = WalletConstants.warning
        label.textAlignment = .center
        label.font = .systemFont(ofSize: UPlusFont.body2, weight: .heavy)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let copyButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UPlusColor.buttonActivated
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
                    
                    self.dismissView()
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
            
            self.addressLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.viewTitle.bottomAnchor, multiplier: 5),
            self.addressLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.containerView.leadingAnchor, multiplier: 3),
            self.containerView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.addressLabel.trailingAnchor, multiplier: 3),
            
            self.warningLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.addressLabel.bottomAnchor, multiplier: 5),
            self.warningLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.containerView.leadingAnchor, multiplier: 5),
            self.containerView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.warningLabel.trailingAnchor, multiplier: 5),
            
            self.copyButton.topAnchor.constraint(equalToSystemSpacingBelow: self.warningLabel.bottomAnchor, multiplier: 4),
            self.copyButton.leadingAnchor.constraint(equalTo: self.warningLabel.leadingAnchor),
            self.copyButton.trailingAnchor.constraint(equalTo: self.warningLabel.trailingAnchor),
            self.containerView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.copyButton.bottomAnchor, multiplier: 3)
        ])
        self.addressLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
        self.copyButton.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
}

