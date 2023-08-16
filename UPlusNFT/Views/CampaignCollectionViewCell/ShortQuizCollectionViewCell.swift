//
//  ShortQuizCollectionViewCell.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/04.
//

import UIKit
import Combine

final class ShortQuizCollectionViewCell: UICollectionViewCell, CampaignCell {
    
    // MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    // MARK: - UI Elements
    private let campaignView: CampaignView = {
        let view = CampaignView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let missionTextLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.textAlignment = .center
        label.text = PostConstants.tempMissionSentence
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let submittedAnswerLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .white
        label.clipsToBounds = true
        label.layer.cornerRadius = 5
        label.numberOfLines = 2
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let submitButton: UIButton = {
        let button = UIButton()
        button.setTitle(PostConstants.submitButton, for: .normal)
        button.backgroundColor = .systemGray
        button.isUserInteractionEnabled = false
        button.setTitleColor(.white, for: .normal)
        button.clipsToBounds = true
        button.layer.cornerRadius = 5
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var answerTextField: UITextField = {
        let txtField = UITextField()
        txtField.placeholder = MissionConstants.inputAnswer
        txtField.rightView = submitButton
        txtField.rightViewMode = .always
        txtField.borderStyle = .roundedRect
        txtField.backgroundColor = .white
        txtField.translatesAutoresizingMaskIntoConstraints = false
        return txtField
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .systemGray3
        
        setUI()
        setLayout()
        
        let username = UserDefaults.standard.string(forKey: UserDefaultsConstants.username) ?? UserDefaultsConstants.username
        self.submittedAnswerLabel.text = username + " 님의 답변 \n??"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK: - Set UI & Layout
extension ShortQuizCollectionViewCell {
    private func setUI() {
        contentView.addSubviews(
            campaignView,
            missionTextLabel,
            submittedAnswerLabel,
            submitButton,
            answerTextField
        )
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.campaignView.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 2),
            self.campaignView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 3),
            self.trailingAnchor.constraint(equalToSystemSpacingAfter: self.campaignView.trailingAnchor, multiplier: 3),
            //TODO: Set height according to the contents size
            self.campaignView.heightAnchor.constraint(equalToConstant: 150),
          
            self.missionTextLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.campaignView.bottomAnchor, multiplier: 1),
            self.missionTextLabel.leadingAnchor.constraint(equalTo: self.campaignView.leadingAnchor),
            self.missionTextLabel.trailingAnchor.constraint(equalTo: self.campaignView.trailingAnchor),
         
            self.submittedAnswerLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.missionTextLabel.bottomAnchor, multiplier: 2),
            self.submittedAnswerLabel.leadingAnchor.constraint(equalTo: self.campaignView.leadingAnchor),
            self.submittedAnswerLabel.trailingAnchor.constraint(equalTo: self.campaignView.trailingAnchor),
            //TODO: Set height according to the contents size
//            self.submittedAnswerLabel.heightAnchor.constraint(equalToConstant: 100),
            
            self.answerTextField.topAnchor.constraint(equalToSystemSpacingBelow: self.submittedAnswerLabel.bottomAnchor, multiplier: 1),
            self.answerTextField.leadingAnchor.constraint(equalTo: self.campaignView.leadingAnchor),
            self.answerTextField.trailingAnchor.constraint(equalTo: self.campaignView.trailingAnchor),
            self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.answerTextField.bottomAnchor, multiplier: 2),
        ])
        self.submittedAnswerLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        self.answerTextField.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
}

// MARK: - Bind ViewModel
extension ShortQuizCollectionViewCell {
    func bind(with vm: CampaignCollectionViewCellViewModel) {
        func bindViewToViewModel() {
            self.answerTextField.textPublisher
                .debounce(for: 0.2, scheduler: DispatchQueue.main)
                .removeDuplicates()
                .sink(receiveValue: { txt in
                    vm.isTextFieldEmpty = txt.isEmpty
                })
                .store(in: &bindings)
            
            self.submitButton.tapPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    guard let `self` = self else { return }
                    self.submittedAnswerLabel.text = self.answerTextField.text
                }
                .store(in: &bindings)
        }
        
        func bindViewModelToView() {
            vm.$campaignMetadata
                .receive(on: DispatchQueue.main)
                .sink { [weak self] metadata in
                    guard let `self` = self else { return }
                    vm.createData()

                    // Bind other data
                    self.campaignView.configure(with: vm)
                }
                .store(in: &bindings)
            
            vm.$isTextFieldEmpty
                .receive(on: DispatchQueue.main)
                .sink { [weak self] empty in
                    guard let `self` = self else { return }
                    let backgroundColor: UIColor = empty ? .systemGray : .black
                    let enabled: Bool = empty ? false : true
                   
                    self.submitButton.backgroundColor = backgroundColor
                    self.submitButton.isUserInteractionEnabled = enabled
                }
                .store(in: &bindings)
        }
        
        bindViewToViewModel()
        bindViewModelToView()
    }
}
