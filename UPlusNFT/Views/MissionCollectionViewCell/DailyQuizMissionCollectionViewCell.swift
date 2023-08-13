//
//  DailyQuizMissionCollectionViewCell.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/18.
//

import UIKit

final class DailyQuizMissionCollectionViewCell: UICollectionViewCell {
    
    // MARK: - UI Elements
    private let containerView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let quizTitleLabel: UILabel = {
        let label = UILabel()
        label.text = MissionConstants.todayMission
        label.textColor = .black
        label.font = .systemFont(ofSize: UPlusFont.head5, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let quizDescLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: UPlusFont.subTitle3)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let pointContainer: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.backgroundColor = UPlusColor.pointCirclePink
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let pointLabel: UILabel = {
       let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: UPlusFont.head5, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.backgroundColor = .systemGray6
        setUI()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Configuration
extension DailyQuizMissionCollectionViewCell {
    func configure(with vm: Mission) {
       
        if let attVM = vm as? WeeklyQuizMission {
            self.quizTitleLabel.text = attVM.missionContentTitle ?? "No Title"
            self.quizDescLabel.text = attVM.missionContentText ?? "No Content"
            self.pointLabel.text = String(describing: attVM.missionRewardPoint) + " " + MissionConstants.pointUnit
        }
    }
}

// MARK: - Set UI & Layout
extension DailyQuizMissionCollectionViewCell {
    
    private func setUI() {
        self.contentView.addSubviews(
            self.containerView
        )
        self.containerView.addSubviews(
            self.stackView,
            self.pointContainer
        )
        self.stackView.addArrangedSubviews(
            self.quizTitleLabel,
            self.quizDescLabel
        )
        self.pointContainer.addSubview(
            self.pointLabel
        )
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.containerView.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 1),
            self.containerView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 3),
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.containerView.trailingAnchor, multiplier: 3),
            self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.containerView.bottomAnchor, multiplier: 3)
        ])
        
        NSLayoutConstraint.activate([
            self.stackView.topAnchor.constraint(equalToSystemSpacingBelow: self.containerView.topAnchor, multiplier: 2),
            self.stackView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.containerView.leadingAnchor, multiplier: 2),
            self.containerView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.stackView.bottomAnchor, multiplier: 2),
            
            self.pointContainer.centerYAnchor.constraint(equalTo: self.stackView.centerYAnchor),
           
            self.pointContainer.topAnchor.constraint(equalToSystemSpacingBelow: self.stackView.topAnchor, multiplier: 2),
            self.stackView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.pointContainer.bottomAnchor, multiplier: 2),
            self.containerView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.pointContainer.trailingAnchor, multiplier: 2),
            self.pointContainer.widthAnchor.constraint(equalTo: self.pointContainer.heightAnchor)
        ])
        
        NSLayoutConstraint.activate([
            self.pointLabel.centerXAnchor.constraint(equalTo: self.pointContainer.centerXAnchor),
            self.pointLabel.centerYAnchor.constraint(equalTo: self.pointContainer.centerYAnchor)
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        DispatchQueue.main.async {
            self.containerView.layer.cornerRadius = self.containerView.frame.width / 11
            self.pointContainer.layer.cornerRadius = self.pointContainer.frame.height / 2
        }
    }


}
