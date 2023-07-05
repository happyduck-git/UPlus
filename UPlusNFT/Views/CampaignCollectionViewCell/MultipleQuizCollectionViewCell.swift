//
//  MultipleQuizCollectionViewCell.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/04.
//

import UIKit
import Combine

final class MultipleQuizCollectionViewCell: UICollectionViewCell {
    
    private var bindings = Set<AnyCancellable>()
    private var isButtonCreated: Bool = false
    
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
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
        label.text = PostConstants.tempMissionSentence
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let buttonStack: UIStackView = {
        let stack = UIStackView()
        stack.spacing = 5.0
        stack.distribution = .fillEqually
        stack.axis = .horizontal
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .systemGray3
        
        setUI()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Set UI & Layout
    private func setUI() {
        self.addSubviews(
            campaignView,
            missionTextLabel,
            buttonStack
        )
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            campaignView.topAnchor.constraint(equalToSystemSpacingBelow: self.topAnchor, multiplier: 1),
            campaignView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.leadingAnchor, multiplier: 3),
            self.trailingAnchor.constraint(equalToSystemSpacingAfter: campaignView.trailingAnchor, multiplier: 3),
            //TODO: Set height according to the contents size/
            campaignView.heightAnchor.constraint(equalToConstant: 150),
            
            missionTextLabel.topAnchor.constraint(equalToSystemSpacingBelow: campaignView.bottomAnchor, multiplier: 1),
            missionTextLabel.leadingAnchor.constraint(equalTo: campaignView.leadingAnchor),
            missionTextLabel.trailingAnchor.constraint(equalTo: campaignView.trailingAnchor),
            
            buttonStack.topAnchor.constraint(equalToSystemSpacingBelow: missionTextLabel.bottomAnchor, multiplier: 1),
            buttonStack.leadingAnchor.constraint(equalTo: campaignView.leadingAnchor),
            buttonStack.trailingAnchor.constraint(equalTo: campaignView.trailingAnchor),
            self.bottomAnchor.constraint(equalToSystemSpacingBelow: buttonStack.bottomAnchor, multiplier: 2)
        ])
    }
    
    // MARK: - Private
    private func createChoiceButtons(_ metadata: [CampaignItem]) -> [UIButton] {
        var buttons: [UIButton] = []
        for data in metadata {
            let button = UIButton()
            button.backgroundColor = .white
            button.clipsToBounds = true
            button.layer.cornerRadius = 10
            button.setTitleColor(.black, for: .normal)
            button.setTitle(data.caption, for: .normal)
            buttons.append(button)
        }
        return buttons
    }
    
    // MARK: - Internal
    func bind(with vm: CampaignCollectionViewCellViewModel) {
        func bindViewToViewModel() {
            
        }
        func bindViewModelToView() {
            vm.$campaignMetadata
                .receive(on: DispatchQueue.main)
                .sink { [weak self] metadata in
                    guard let `self` = self else { return }
                    vm.createData()
                    
                    // Create buttons
                    let choices = metadata?.items ?? []
                    if !choices.isEmpty && !self.isButtonCreated {
                        let buttons = self.createChoiceButtons(choices)
                        for button in buttons {
                            self.buttonStack.addArrangedSubview(button)
                        }
                        self.isButtonCreated = true
                    }
                    
                    // Bind other data
                    self.campaignView.configure(with: vm)
                }
                .store(in: &bindings)
        }
        
        bindViewToViewModel()
        bindViewModelToView()
    }
}
