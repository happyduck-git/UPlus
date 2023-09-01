//
//  Top3RankerTableViewCell.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/08/24.
//

import UIKit

final class Top3RankerTableViewCell: UITableViewCell {

    private let titleImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: ImageAssets.top3Title)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let rankerStack: UIStackView = {
       let stack = UIStackView()
        stack.spacing = 8.0
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let firstRankView: TopRankView = {
        let view = TopRankView()
        return view
    }()
    
    private let secondRankView: TopRankView = {
        let view = TopRankView()
        return view
    }()
    
    private let thirdRankView: TopRankView = {
        let view = TopRankView()
        return view
    }()

    private let infoLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = RankingConstants.top3Info
        label.textColor = UPlusColor.blue04
        label.font = .systemFont(ofSize: UPlusFont.caption1, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.backgroundColor = UPlusColor.blue02
        self.contentView.layer.borderColor = UPlusColor.blue04.cgColor
        self.contentView.layer.borderWidth = 6.0
        
        self.setUI()
        self.setLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.contentView.frame = self.contentView.frame.inset(by: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
     
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
        
        self.firstRankView.setMedalImage(name: ImageAssets.goldMedal)
        self.secondRankView.setMedalImage(name: ImageAssets.silverMedal)
        self.thirdRankView.setMedalImage(name: ImageAssets.bronzeMedal)
    }
    
}

//MARK: - Set UI & Layout
extension Top3RankerTableViewCell {
    private func setUI() {
        self.contentView.addSubviews(self.titleImage,
                                     self.rankerStack,
                                     self.infoLabel)
        
        self.rankerStack.addArrangedSubviews(self.firstRankView,
                                             self.secondRankView,
                                             self.thirdRankView)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.titleImage.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 2),
            self.titleImage.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 2),
            self.titleImage.heightAnchor.constraint(equalToConstant: 32),
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.titleImage.trailingAnchor, multiplier: 2),
            
            self.rankerStack.topAnchor.constraint(equalToSystemSpacingBelow: self.titleImage.bottomAnchor, multiplier: 3),
            self.rankerStack.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 2),
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.rankerStack.trailingAnchor, multiplier: 2),
            
            self.infoLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.rankerStack.bottomAnchor, multiplier: 3),
            self.infoLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 2),
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.infoLabel.trailingAnchor, multiplier: 2),
            self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.infoLabel.bottomAnchor, multiplier: 2)
        ])
    }
}
