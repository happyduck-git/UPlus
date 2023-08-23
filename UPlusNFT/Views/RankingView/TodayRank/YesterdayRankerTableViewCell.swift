//
//  YesterdayRankerTableViewCell.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/08/24.
//

import UIKit

final class YesterdayRankerTableViewCell: UITableViewCell {

    private let title: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UPlusColor.mint03
        label.font = .systemFont(ofSize: UPlusFont.h5, weight: .bold)
        label.text = RankingConstants.yesterdayRanker
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let rankerLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UPlusColor.gray09
        label.font = .systemFont(ofSize: UPlusFont.body2, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let pointImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: ImageAsset.point)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let pointLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UPlusColor.gray09
        label.font = .systemFont(ofSize: UPlusFont.body2, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
   
    //MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.setUI()
        self.setLayout()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
//        self.contentView.frame = self.contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
    }
}

//MARK: - Configure
extension YesterdayRankerTableViewCell {
    func configure(ranker: UPlusUser?) {
        
        guard let ranker = ranker else {
            self.rankerLabel.text = "랭커가 없습니다!"
            self.pointLabel.text = String(describing: 0)
            return
        }
        
        self.rankerLabel.text = "1위 \(ranker.userNickname)"
        self.pointLabel.text = String(describing: ranker.userTotalPoint)
    }
}

//MARK: - Set UI & Layout
extension YesterdayRankerTableViewCell {
    private func setUI() {
        self.contentView.addSubviews(self.title,
                                     self.rankerLabel,
                                     self.pointImage,
                                     self.pointLabel)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.title.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 2),
            self.title.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 2),
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.title.trailingAnchor, multiplier: 2),
            
            self.rankerLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.title.bottomAnchor, multiplier: 1),
            self.rankerLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 2),
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.rankerLabel.trailingAnchor, multiplier: 2),
            self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.rankerLabel.bottomAnchor, multiplier: 2),
            
            self.pointImage.topAnchor.constraint(equalTo: self.rankerLabel.topAnchor),
            self.pointImage.leadingAnchor.constraint(equalToSystemSpacingAfter: self.rankerLabel.trailingAnchor, multiplier: 2),
            self.pointImage.bottomAnchor.constraint(equalTo: self.rankerLabel.bottomAnchor),
            
            self.pointLabel.topAnchor.constraint(equalTo: self.rankerLabel.topAnchor),
            self.pointImage.leadingAnchor.constraint(equalToSystemSpacingAfter: self.pointImage.trailingAnchor, multiplier: 1),
            self.pointLabel.bottomAnchor.constraint(equalTo: self.pointImage.bottomAnchor),
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.pointLabel.trailingAnchor, multiplier: 2)
        ])
    }
}
