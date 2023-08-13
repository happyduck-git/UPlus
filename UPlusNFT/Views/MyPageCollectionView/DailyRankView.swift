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
        label.text = "일일랭킹"
        label.textColor = .white
        return label
    }()
    
    private let rankingImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: ImageAsset.trophy)
        return imageView
    }()
    
    private let rankingButton: UIButton = {
        let button = UIButton()
        button.setTitle("13위", for: .normal)
        button.setImage(UIImage(named: ImageAsset.arrowHeadRight), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.semanticContentAttribute = .forceRightToLeft
        return button
    }()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UPlusColor.grayNavy.withAlphaComponent(0.3)
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
        self.rankingButton.setTitle(String(describing: rank) + "위", for: .normal)
    }
}

//MARK: - Set UI & Layout
extension DailyRankView {
    private func setUI() {
        self.addSubview(self.rankStackView)
        self.rankStackView.addArrangedSubviews(self.rankingTitleLabel,
                                                self.rankingImageView,
                                                self.rankingButton)
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
