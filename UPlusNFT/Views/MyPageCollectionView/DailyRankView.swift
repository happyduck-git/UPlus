//
//  DailyRankView.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/03.
//

import UIKit

final class DailyRankView: UIView {

    private let rankStackView: UIStackView = {
       let stack = UIStackView()
        stack.distribution = .fillProportionally
        stack.spacing = 5.0
        stack.axis = .horizontal
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let rankingTitleLabel: UILabel = {
        let label = UILabel()
        label.text = MyPageConstants.dailyRank
        label.font = .systemFont(ofSize: UPlusFont.caption1, weight: .medium)
        label.textColor = .white
        return label
    }()
    
    private let rankingImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: ImageAsset.dailyTrophy)
        return imageView
    }()
    
    private let rankingLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: UPlusFont.caption1, weight: .medium)
        return label
    }()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UPlusColor.gray07.withAlphaComponent(0.9)
        self.layer.borderColor = UPlusColor.gray05.cgColor
        self.layer.borderWidth = 1.0
        
        self.setUI()
        self.setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - Configure
extension DailyRankView {
    func configure(rank: Int) {
        self.rankingLabel.text = String(format: MyPageConstants.rank, rank)
    }
}

//MARK: - Set UI & Layout
extension DailyRankView {
    private func setUI() {
        self.addSubview(self.rankStackView)
        self.rankStackView.addArrangedSubviews(self.rankingTitleLabel,
                                               self.rankingImageView,
                                               self.rankingLabel)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.rankStackView.topAnchor.constraint(equalToSystemSpacingBelow: self.topAnchor, multiplier: 1),
            self.rankStackView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.leadingAnchor, multiplier: 2),
            self.trailingAnchor.constraint(equalToSystemSpacingAfter: self.rankStackView.trailingAnchor, multiplier: 2),
            self.bottomAnchor.constraint(equalToSystemSpacingBelow: self.rankStackView.bottomAnchor, multiplier: 1)
        ])
    }
}
