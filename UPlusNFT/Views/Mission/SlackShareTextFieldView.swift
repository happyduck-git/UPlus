//
//  SlackShareTextFieldView.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/29.
//

import UIKit
import Combine

protocol SlackShareTextFieldViewDelegate: AnyObject {
    func keyboardShown()
}

final class SlackShareTextFieldView: UIView {

    // MARK: - Dependency
    private var vm: ShareMediaOnSlackMissionViewViewModel?
    
    // MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    //MARK: - Delegate
    weak var delegate: SlackShareTextFieldViewDelegate?
    
    // MARK: - UI Elements
    private let title: UILabel = {
        let label = UILabel()
        label.text = "STEP 3"
        label.textAlignment = .center
        label.textColor = UPlusColor.mint05
        label.font = .systemFont(ofSize: UPlusFont.h1, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subTitle: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UPlusColor.blue04
        label.font = .systemFont(ofSize: UPlusFont.body2, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let answerTextField: UITextField = {
        let txtField = UITextField()
        txtField.borderStyle = .none
        txtField.translatesAutoresizingMaskIntoConstraints = false
        return txtField
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.text = MissionConstants.pasteUrl
        label.textAlignment = .center
        label.textColor = UPlusColor.mint04
        label.font = .systemFont(ofSize: UPlusFont.body2, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        
        self.setUI()
        self.setLayout()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.answerTextField.setTextFieldUnderline(color: UPlusColor.gray04)
    }
    
}

// MARK: - 
extension SlackShareTextFieldView {
    func configure(with vm: ShareMediaOnSlackMissionViewViewModel) {
        self.bind(with: vm)
    }
    
    private func bind(with vm: ShareMediaOnSlackMissionViewViewModel) {
        
        func bindViewToViewModel() {
            self.answerTextField.textPublisher
                .removeDuplicates()
                .receive(on: DispatchQueue.main)
                .sink {
                    vm.textFieldText = $0
                }
                .store(in: &bindings)
        }
        func bindViewModelToView() {
            
        }
        
        bindViewToViewModel()
        bindViewModelToView()
        
    }
}

// MARK: - Set UI & Layout
extension SlackShareTextFieldView {
    private func setUI() {
        self.addSubviews(self.title,
                         self.subTitle,
                         self.answerTextField,
                         self.infoLabel)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.title.topAnchor.constraint(equalToSystemSpacingBelow: self.topAnchor, multiplier: 2),
            self.title.leadingAnchor.constraint(equalToSystemSpacingAfter: self.leadingAnchor, multiplier: 2),
            self.trailingAnchor.constraint(equalToSystemSpacingAfter: self.title.trailingAnchor, multiplier: 2),
            
            self.subTitle.topAnchor.constraint(equalToSystemSpacingBelow: self.title.bottomAnchor, multiplier: 2),
            self.subTitle.leadingAnchor.constraint(equalToSystemSpacingAfter: self.title.leadingAnchor, multiplier: 1),
            self.title.trailingAnchor.constraint(equalToSystemSpacingAfter: self.subTitle.trailingAnchor, multiplier: 1),
            
            self.answerTextField.topAnchor.constraint(equalToSystemSpacingBelow: self.subTitle.bottomAnchor, multiplier: 2),
            self.answerTextField.heightAnchor.constraint(equalToConstant: LoginConstants.buttonHeight),
            self.answerTextField.leadingAnchor.constraint(equalTo: self.subTitle.leadingAnchor),
            self.answerTextField.trailingAnchor.constraint(equalTo: self.subTitle.trailingAnchor),
            
            self.infoLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.answerTextField.bottomAnchor, multiplier: 1),
            self.infoLabel.leadingAnchor.constraint(equalTo: self.answerTextField.leadingAnchor),
            self.bottomAnchor.constraint(equalToSystemSpacingBelow: self.infoLabel.bottomAnchor, multiplier: 2)
        ])
    }
}

extension SlackShareTextFieldView: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.delegate?.keyboardShown()
    }
}
