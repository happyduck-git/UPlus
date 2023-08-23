//
//  MissionHistoryNoParticipationCollectionViewCell.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/23.
//

import UIKit
import Combine

final class MissionHistoryNoParticipationCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    // MARK: - UI Elements
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = MyPageConstants.noParticipate
        label.font = .systemFont(ofSize: UPlusFont.h2, weight: .regular)
        label.textColor = UPlusColor.gray04
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let goToMissionButton: UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.setTitle(MyPageConstants.makeTodoList, for: .normal)
        button.backgroundColor = UPlusColor.mint03
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.backgroundColor = UPlusColor.grayBackground
        
        self.setUI()
        self.setLayout()
        
        self.bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.goToMissionButton.layer.cornerRadius = self.goToMissionButton.frame.height / 2
    }
}

extension MissionHistoryNoParticipationCollectionViewCell {
    
    private func bind() {
        func bindViewToViewModel() {
            self.goToMissionButton.tapPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    guard let `self` = self else { return }
                    
                    // TODO: 어떤 미션으로 안내?
                    
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
extension MissionHistoryNoParticipationCollectionViewCell {
    
    private func setUI() {
        self.contentView.addSubviews(self.descriptionLabel,
                                     self.goToMissionButton)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.descriptionLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 3),
            self.descriptionLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 2),
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.descriptionLabel.trailingAnchor, multiplier: 2),
            
            self.goToMissionButton.topAnchor.constraint(equalToSystemSpacingBelow: self.descriptionLabel.bottomAnchor, multiplier: 2),
            self.goToMissionButton.heightAnchor.constraint(equalToConstant: 40),
            self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.goToMissionButton.bottomAnchor, multiplier: 3)
        ])
    }
    
}
