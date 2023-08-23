//
//  Top3RankerTableViewCell.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/08/24.
//

import UIKit

final class Top3RankerTableViewCell: UITableViewCell {

    private let topLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = RankingConstants.top3
        label.textColor = UPlusColor.mint03
        label.font = .systemFont(ofSize: UPlusFont.h2, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let thirdRankView: TopRankView = {
        let view = TopRankView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let firstRankView: TopRankView = {
        let view = TopRankView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let secondRankView: TopRankView = {
        let view = TopRankView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let infoLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = RankingConstants.top3Info
        label.textColor = UPlusColor.gray09
        label.font = .systemFont(ofSize: UPlusFont.caption1, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.backgroundColor = .white
        self.contentView.clipsToBounds = true
        self.contentView.layer.cornerRadius = 12.0
        self.contentView.layer.borderColor = UPlusColor.mint03.cgColor
        self.contentView.layer.borderWidth = 2.0
        
        self.setUI()
        self.setLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.contentView.frame = self.contentView.frame.inset(by: UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10))
        
        let width = (self.frame.width - 48) / 3
        self.firstRankView.widthAnchor.constraint(equalToConstant: width).isActive = true
        self.secondRankView.widthAnchor.constraint(equalToConstant: width).isActive = true
        self.thirdRankView.widthAnchor.constraint(equalToConstant: width).isActive = true
    }

}

//MARK: - Configure
extension Top3RankerTableViewCell {
    func configure(top3Users: [UPlusUser]) {
        
        let first = top3Users.indices.contains(0) ? top3Users[0] : nil
        let second = top3Users.indices.contains(1) ? top3Users[1] : nil
        let third = top3Users.indices.contains(2) ? top3Users[2] : nil
        
        self.firstRankView.configure(image: " ",
                                     username: first?.userNickname ?? " ",
                                     point: first?.userTotalPoint ?? 0)
        
        self.secondRankView.configure(image: " ",
                                     username: second?.userNickname ?? " ",
                                     point: second?.userTotalPoint ?? 0)
        
        self.thirdRankView.configure(image: " ",
                                     username: third?.userNickname ?? " ",
                                     point: third?.userTotalPoint ?? 0)
        
        self.firstRankView.setMedalImage(name: ImageAsset.gold)
        self.secondRankView.setMedalImage(name: ImageAsset.silver)
        self.thirdRankView.setMedalImage(name: ImageAsset.bronze)
    }
    
}

//MARK: - Set UI & Layout
extension Top3RankerTableViewCell {
    private func setUI() {
        self.contentView.addSubviews(self.topLabel,
                         self.thirdRankView,
                         self.firstRankView,
                         self.secondRankView,
                         self.infoLabel)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.topLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 1),
            self.topLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 2),
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.topLabel.trailingAnchor, multiplier: 2),
            
            self.thirdRankView.topAnchor.constraint(equalToSystemSpacingBelow: self.topLabel.bottomAnchor, multiplier: 4),
            self.thirdRankView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 2),
            
            self.firstRankView.topAnchor.constraint(equalToSystemSpacingBelow: self.topLabel.bottomAnchor, multiplier: 2),
            self.firstRankView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.thirdRankView.trailingAnchor, multiplier: 1),
            self.firstRankView.bottomAnchor.constraint(equalTo: self.thirdRankView.bottomAnchor),
            
            self.secondRankView.topAnchor.constraint(equalTo: self.thirdRankView.topAnchor),
            self.secondRankView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.firstRankView.trailingAnchor, multiplier: 1),
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.secondRankView.trailingAnchor, multiplier: 2),
            self.secondRankView.bottomAnchor.constraint(equalTo: self.thirdRankView.bottomAnchor),
            
            self.infoLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.firstRankView.bottomAnchor, multiplier: 2),
            self.infoLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.leadingAnchor, multiplier: 2),
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.infoLabel.trailingAnchor, multiplier: 2),
            self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.infoLabel.bottomAnchor, multiplier: 2)
        ])
    }
}
