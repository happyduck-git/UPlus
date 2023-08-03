//
//  InformationInputView.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/07/19.
//

import UIKit

class InformationInputView: UIView {
    
    enum InputType {
        case normal
        case email
        case password
    }
    
    private let type: InputType
    
    //MARK: - UI Elements
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12.0
        stack.distribution = .fillProportionally
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 15, weight: .bold)
        return label
    }()
    
    private let textField: UITextField = {
        let txtField = UITextField()
        txtField.textColor = .black
        txtField.borderStyle = .roundedRect
        txtField.backgroundColor = .systemGray6
        return txtField
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
    
    //MARK: - Init
    init(type: InputType) {
        self.type = type
        super.init(frame: .zero)
        
        self.setUI()
        self.setLayout()
        self.setTextFieldType()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

//MARK: - Set UI & Layout
extension InformationInputView {
    private func setUI() {
        self.addSubviews(stackView)
        self.stackView.addArrangedSubviews(titleLabel,
                                           textField)

    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.stackView.topAnchor.constraint(equalTo: self.topAnchor),
            self.stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])

    }
}

extension InformationInputView {
    func setTitleText(_ text: String) {
        self.titleLabel.text = text
    }
    
    func setPlaceHolder(_ text: String) {
        self.textField.placeholder = text
    }
    
    func disableUserInteraction() {
        self.textField.isUserInteractionEnabled = false
        self.textField.backgroundColor = .systemGray3
        self.placeHolderLabel.textColor = .systemGray
    }
    
    private func setTextFieldType() {
        switch self.type {
        case .normal:
            break
        case .email:
            self.textField.textContentType = .emailAddress
            
            // Adding a PlaceHolderView
            self.placeHolderView.addSubview(placeHolderLabel)
            self.textField.rightView = placeHolderView
            self.textField.rightViewMode = .always
            
            // Setting Placeholder related views' layout.
            NSLayoutConstraint.activate([
                self.placeHolderLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.placeHolderView.topAnchor, multiplier: 1),
                self.placeHolderLabel.leadingAnchor.constraint(equalTo: self.placeHolderView.leadingAnchor),
                self.placeHolderView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.placeHolderLabel.trailingAnchor, multiplier: 1),
                self.placeHolderView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.placeHolderLabel.bottomAnchor, multiplier: 1)
            ])
        case .password:
            self.textField.isSecureTextEntry = true
            self.textField.textContentType = .newPassword
        }
    }
}
