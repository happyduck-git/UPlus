//
//  GiftSendView.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/18.
//

import UIKit
import Combine

final class GiftSendView: UIView {

    // MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    // MARK: - UI Elements
    private let receiverLabel: UILabel = {
        let label = UILabel()
        label.textColor = UPlusColor.gray08
        label.text = GiftConstants.receiver
        label.font = .systemFont(ofSize: UPlusFont.h5, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let placeHolderView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let placeHolderLabel: UILabel = {
        let label = UILabel()
        label.text = LoginConstants.uplusEmailSuffix
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = GiftConstants.inputNickname
        textField.layer.borderColor = UPlusColor.gray04.cgColor
        textField.layer.borderWidth = 1.0
        textField.clipsToBounds = true
        textField.layer.cornerRadius = 8.0
        textField.textContentType = .username
        textField.keyboardType = .emailAddress
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let warningLabel: TextReCheckLabelView = {
       let label = TextReCheckLabelView()
        label.isHidden = true
        label.setLabelText(GiftConstants.checkNickname)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
     
        self.setUI()
        self.setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func layoutSubviews() {
        super.layoutSubviews()
        self.textField.heightAnchor.constraint(equalToConstant: self.frame.height / 2).isActive = true
    }
}

// MARK: - Bind with View Model
extension GiftSendView {
    func bind(vm: GiftViewControllerViewViewModel) {
        self.textField.textPublisher
            .removeDuplicates()
            .assign(to: \.username, on: vm)
            .store(in: &bindings)
    }
}

// MARK: - Set UI & Layout
extension GiftSendView {
    private func setUI() {
        self.addSubviews(self.receiverLabel,
                         self.textField,
                         self.warningLabel)
        
        self.placeHolderView.addSubview(placeHolderLabel)
        self.textField.rightView = placeHolderView
        self.textField.rightViewMode = .always
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.receiverLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.topAnchor, multiplier: 2),
            self.receiverLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.leadingAnchor, multiplier: 2),
            self.trailingAnchor.constraint(equalToSystemSpacingAfter: self.receiverLabel.trailingAnchor, multiplier: 2),
            
            self.textField.topAnchor.constraint(equalToSystemSpacingBelow: self.receiverLabel.bottomAnchor, multiplier: 2),
            self.textField.leadingAnchor.constraint(equalTo: self.receiverLabel.leadingAnchor),
            self.trailingAnchor.constraint(equalToSystemSpacingAfter: self.textField.trailingAnchor, multiplier: 2),
            self.textField.heightAnchor.constraint(equalToConstant: 50),
            
            self.warningLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.textField.bottomAnchor, multiplier: 1),
            self.warningLabel.leadingAnchor.constraint(equalTo: self.textField.leadingAnchor),
            self.warningLabel.trailingAnchor.constraint(equalTo: self.textField.trailingAnchor),
            
            self.bottomAnchor.constraint(equalToSystemSpacingBelow: self.warningLabel.bottomAnchor, multiplier: 2)
        ])
        
        // Place holder label
        NSLayoutConstraint.activate([
            self.placeHolderLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.placeHolderView.topAnchor, multiplier: 1),
            self.placeHolderLabel.leadingAnchor.constraint(equalTo: self.placeHolderView.leadingAnchor),
            self.placeHolderView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.placeHolderLabel.trailingAnchor, multiplier: 1),
            self.placeHolderView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.placeHolderLabel.bottomAnchor, multiplier: 1)
        ])

    }
}

extension GiftSendView {
    func setInfoLabelText() {
        self.warningLabel.isHidden = false
        self.warningLabel.setLabelText(GiftConstants.checkNickname)
        self.warningLabel.setLabelColor(UPlusColor.orange01)
    }
    
    func hideInfoLabel() {
        self.warningLabel.hideInfoImageAndText()
    }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct GiftViewPreView: PreviewProvider{
    static var previews: some View {
        UIViewPreview {
            let view = GiftSendView(frame: .zero)
            return view
        }.previewLayout(.sizeThatFits)
    }
}
#endif
