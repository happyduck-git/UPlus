//
//  UserMissionDataView.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/21.
//

import UIKit

class UserMissionDataView: UIView {

    private let levelDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "다음 레벨까지 3P 남았어요"
        label.font = .systemFont(ofSize: UPlusFont.subTitle3)
        label.textColor = UPlusColor.pointCirclePink
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let levelProgressBar: UIProgressView = {
        let bar = UIProgressView()
        bar.progress = 0.0
        bar.clipsToBounds = true
        bar.progressViewStyle = .default
        bar.progressTintColor = UPlusColor.pointCirclePink
        bar.trackTintColor = .systemGray
        bar.translatesAutoresizingMaskIntoConstraints = false
        return bar
    }()
    
    private let pointImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: SFSymbol.point)?.withTintColor(UPlusColor.pointCirclePink, renderingMode: .alwaysOriginal) // TEMP ASSET
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let pointLabel: UILabel = {
        let label = UILabel()
        label.text = "12"
        label.font = .systemFont(ofSize: UPlusFont.subTitle3, weight: .bold)
        label.textColor = UPlusColor.pointCirclePink
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let rankingView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.backgroundColor = .systemGray4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let rankStackView: UIStackView = {
       let stack = UIStackView()
        stack.distribution = .fillProportionally
        stack.spacing = 1.0
        stack.axis = .horizontal
        return stack
    }()
    
    private let rankingTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "일일랭킹"
        label.textColor = UPlusColor.rankYellow
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let rankingImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: SFSymbol.medalFill)?.withTintColor(UPlusColor.trophyYellow, renderingMode: .alwaysOriginal) // TEMP ASSET
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let rankingButton: UIButton = {
        let button = UIButton()
        button.setTitle("13위", for: .normal)
        button.setImage(UIImage(systemName: SFSymbol.arrowTriangleRight)?.withTintColor(.systemGray, renderingMode: .alwaysOriginal), for: .normal)
        button.setTitleColor(UPlusColor.rankBrown, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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
    
}

extension UserMissionDataView {
    private func setUI() {
        self.addSubviews(levelDescriptionLabel,
                         levelProgressBar,
                         pointImageView,
                         pointLabel,
                         rankingView)
        self.rankingView.addSubview(rankStackView)
        self.rankStackView.addArrangedSubviews(rankingTitleLabel,
                                               rankingImageView,
                                               rankingButton)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.levelDescriptionLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.topAnchor, multiplier: 2),
            self.levelDescriptionLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.leadingAnchor, multiplier: 2),
            self.trailingAnchor.constraint(equalToSystemSpacingAfter: self.levelDescriptionLabel.trailingAnchor, multiplier: 2),
            
            self.levelProgressBar.topAnchor.constraint(equalToSystemSpacingBelow: self.levelDescriptionLabel.bottomAnchor, multiplier: 2),
            self.levelProgressBar.leadingAnchor.constraint(equalTo: self.levelDescriptionLabel.leadingAnchor),
            self.levelProgressBar.trailingAnchor.constraint(equalTo: self.levelDescriptionLabel.trailingAnchor),
            self.levelProgressBar.heightAnchor.constraint(equalToConstant: self.frame.height / 10),
            self.pointImageView.leadingAnchor.constraint(equalTo: self.levelDescriptionLabel.leadingAnchor),
            self.pointImageView.heightAnchor.constraint(equalToConstant: self.frame.height / 8),
            self.pointImageView.widthAnchor.constraint(equalTo: self.pointImageView.heightAnchor),
            self.pointImageView.centerYAnchor.constraint(equalTo: self.rankingView.centerYAnchor),
            
            self.pointLabel.centerYAnchor.constraint(equalTo: self.rankingView.centerYAnchor),
            self.pointLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.pointImageView.trailingAnchor, multiplier: 1),
            
            self.rankingView.topAnchor.constraint(equalToSystemSpacingBelow: self.levelProgressBar.bottomAnchor, multiplier: 2),
            self.bottomAnchor.constraint(equalToSystemSpacingBelow: self.rankingView.bottomAnchor, multiplier: 2),
            self.rankingView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.pointLabel.trailingAnchor, multiplier: 5)
        ])
        
        NSLayoutConstraint.activate([
            self.rankStackView.topAnchor.constraint(equalToSystemSpacingBelow: self.rankingView.topAnchor, multiplier: 1),
            self.rankStackView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.rankingView.leadingAnchor, multiplier: 1),
            self.rankingView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.rankStackView.trailingAnchor, multiplier: 1),
            self.rankingView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.rankStackView.bottomAnchor, multiplier: 1)
        ])
    }
}