//
//  TotalRankTableViewCell.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/23.
//

import UIKit

final class TotalRankTableViewCell: UITableViewCell {
    
    // MARK: - UI Elements
    private let rankImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isHidden = true
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let rankLabel: UILabel = {
        let label = UILabel()
        label.textColor = UPlusColor.gray05
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: UPlusFont.body1, weight: .bold)
        
        return label
    }()
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.borderColor = UIColor(ciColor: .white).cgColor
        imageView.layer.borderWidth = 1.0
        imageView.clipsToBounds = true
        imageView.backgroundColor = UPlusColor.grayBackground
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let username: UILabel = {
        let label = UILabel()
        label.textColor = UPlusColor.mint05
        label.font = .systemFont(ofSize: UPlusFont.body1, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let level: UILabel = {
        let label = UILabel()
        label.textColor = UPlusColor.mint04
        label.font = .systemFont(ofSize: UPlusFont.caption1, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let popScoreLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UPlusColor.gray05
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.backgroundColor = .white
        setUI()
        setLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
    }
    
    // MARK: - Private
    private func setUI() {
        self.contentView.addSubviews(rankImageView,
                                     rankLabel,
                                     profileImageView,
                                     username,
                                     level,
                                     popScoreLabel)
    }
    
    private func setLayout() {
        
        let height = contentView.frame.size.height
        
        NSLayoutConstraint.activate([
            self.rankImageView.topAnchor.constraint(equalToSystemSpacingBelow: contentView.topAnchor, multiplier: 1),
            self.rankImageView.leadingAnchor.constraint(equalToSystemSpacingAfter: contentView.leadingAnchor, multiplier: 2),
            self.rankImageView.widthAnchor.constraint(equalToConstant: height / 2),
            self.rankImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            self.rankLabel.topAnchor.constraint(equalTo: self.rankImageView.topAnchor),
            self.rankLabel.leadingAnchor.constraint(equalTo: self.rankImageView.leadingAnchor),
            contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.rankLabel.bottomAnchor, multiplier: 1),
            
            self.profileImageView.topAnchor.constraint(equalTo: self.rankImageView.topAnchor),
            self.profileImageView.widthAnchor.constraint(equalTo: self.profileImageView.heightAnchor),
            self.profileImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            self.profileImageView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.rankImageView.trailingAnchor, multiplier: 2),
            
            self.username.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 1),
            self.username.leadingAnchor.constraint(equalToSystemSpacingAfter: self.profileImageView.trailingAnchor, multiplier: 1),
            self.username.bottomAnchor.constraint(equalToSystemSpacingBelow: self.level.topAnchor, multiplier: 1),
            
            self.level.leadingAnchor.constraint(equalTo: self.username.leadingAnchor),
            self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.level.bottomAnchor, multiplier: 1),
            
            self.popScoreLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 2),
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.popScoreLabel.trailingAnchor, multiplier: 2),
            self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.popScoreLabel.bottomAnchor, multiplier: 2)
        ])
        
        self.popScoreLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.rankImageView.isHidden = false
        self.rankLabel.isHidden = true
    }
    
    internal func resetCell() {
        self.rankLabel.text = nil
        self.rankImageView.image = nil
        self.profileImageView.image = nil
        self.popScoreLabel.text = nil
        self.popScoreLabel.textColor = .white
        self.contentView.backgroundColor = nil
    }
    
    // MARK: - Public
    public func configure(with vm: UPlusUser, at row: Int) {
        self.rankLabel.text = "\(row + 1)"
        self.username.text = vm.userNickname
        self.level.text = "Lv.n"
        self.popScoreLabel.text = "\(vm.userTotalPoint ?? 0)P"
    }
    
    public func setAsCollectionInfoCell() {
        self.rankImageView.isHidden = true
        self.rankLabel.isHidden = true
    }
    
    public func switchRankImageToLabel() {
        self.rankImageView.isHidden = true
        self.rankLabel.isHidden = false
    }
    
    private func imageStringToImage(with urlString: String, completion: @escaping (Result<UIImage?, Error>) -> ()) {
        let url = URL(string: urlString)
        
    }
    
    enum ImageError: Error {
        case nukeImageLoadingError
    }
}
