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
        bar.clipsToBounds = true
        bar.progressViewStyle = .default
        bar.progressTintColor = UPlusColor.pointCirclePink
        bar.trackTintColor = .systemGray
        bar.translatesAutoresizingMaskIntoConstraints = false
        return bar
    }()
    
    private let pointImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: ImageAsset.pointSticker)
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
        stack.axis = .horizontal
        stack.translatesAutoresizingMaskIntoConstraints = false
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
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: ImageAsset.trophy)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let rankingButton: UIButton = {
        let button = UIButton()
        button.setTitle("13위", for: .normal)
        button.setTitleColor(UPlusColor.rankBrown, for: .normal)
        button.semanticContentAttribute = .forceRightToLeft
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UPlusColor.lightBlue
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 8.0
        self.setUI()
        self.setLayout()

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.levelProgressBar.setProgress(0.7, animated: true)
        DispatchQueue.main.async {
            self.rankingView.layer.cornerRadius = self.rankingView.frame.height / 2
        }
    }
    
}

extension UserMissionDataView {
    func configure(vm: MyPageViewViewModel) {
        self.pointLabel.text = String(describing: vm.ownedPoints)
        self.rankingButton.setTitle(String(describing: vm.todayRank) + "위", for: .normal)
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
           
            self.pointImageView.leadingAnchor.constraint(equalTo: self.levelDescriptionLabel.leadingAnchor),
            self.pointImageView.widthAnchor.constraint(equalTo: self.pointImageView.heightAnchor),
            self.pointImageView.centerYAnchor.constraint(equalTo: self.rankingView.centerYAnchor),
            
            self.pointLabel.centerYAnchor.constraint(equalTo: self.rankingView.centerYAnchor),
            self.pointLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.pointImageView.trailingAnchor, multiplier: 1),
            
            self.rankingView.topAnchor.constraint(equalToSystemSpacingBelow: self.levelProgressBar.bottomAnchor, multiplier: 2),
            self.bottomAnchor.constraint(equalToSystemSpacingBelow: self.rankingView.bottomAnchor, multiplier: 2),
            self.rankingView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.pointLabel.trailingAnchor, multiplier: 5),
            self.trailingAnchor.constraint(equalToSystemSpacingAfter: self.rankingView.trailingAnchor, multiplier: 8)
        ])
        
        NSLayoutConstraint.activate([
            self.rankStackView.topAnchor.constraint(equalToSystemSpacingBelow: self.rankingView.topAnchor, multiplier: 1),
            self.rankStackView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.rankingView.leadingAnchor, multiplier: 1),
            self.rankingView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.rankStackView.trailingAnchor, multiplier: 1),
            self.rankingView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.rankStackView.bottomAnchor, multiplier: 1)
        ])
        
        self.levelProgressBar.setContentHuggingPriority(.defaultLow, for: .horizontal)
    }

}
