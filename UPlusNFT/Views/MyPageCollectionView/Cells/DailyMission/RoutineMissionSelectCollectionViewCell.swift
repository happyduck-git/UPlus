//
//  RoutineMissionCollectionViewCell.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/31.
//

import UIKit

final class RoutineMissionSelectCollectionViewCell: UICollectionViewCell {
    private let titleStack: UIStackView = {
       let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .leading
        stack.distribution = .fillProportionally
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let missionTitle: UILabel = {
        let label = UILabel()
        label.text = "루틴 시작하기"
        label.textColor = .black
        label.font = .systemFont(ofSize: UPlusFont.head6, weight: .bold)
        return label
    }()
    
    private let missionDescription: UILabel = {
        let label = UILabel()
        label.text = "원하는 루틴 미션을 1개 골라 참여하세요"
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: UPlusFont.subTitle2, weight: .medium)
        return label
    }()
    
    private let arrowButton: UIButton = {
       let button = UIButton()
        button.setImage(UIImage(named: ImageAsset.arrowHeadRight)?.withTintColor(UPlusColor.mint, renderingMode: .alwaysOriginal), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.backgroundColor = .white
        self.setUI()
        self.setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension RoutineMissionSelectCollectionViewCell {
    private func setUI() {
        self.contentView.addSubviews(self.titleStack,
                                     self.arrowButton)
        self.titleStack.addArrangedSubviews(self.missionTitle,
                                            self.missionDescription)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.titleStack.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 2),
            self.titleStack.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 2),
            self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.titleStack.bottomAnchor, multiplier: 2),
            
            self.arrowButton.leadingAnchor.constraint(equalToSystemSpacingAfter: self.titleStack.trailingAnchor, multiplier: 2),
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.arrowButton.trailingAnchor, multiplier: 2),
            self.arrowButton.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor)
        ])
        
        self.missionDescription.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
}
