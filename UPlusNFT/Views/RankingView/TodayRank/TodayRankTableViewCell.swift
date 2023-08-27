//
//  TodayRankTableViewCell.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/23.
//

import UIKit

final class TodayRankTableViewCell: UITableViewCell {
    
    // MARK: - UI Elements
    private let highlightTagView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.backgroundColor = UPlusColor.mint03
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let rankImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isHidden = true
        imageView.backgroundColor = UPlusColor.grayBackground
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
    
    private let pointLabel: UILabel = {
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.highlightTagView.isHidden = true
        self.rankImageView.isHidden = true
        self.rankLabel.isHidden = false
    }
    
    internal func resetCell() {
        self.rankLabel.text = nil
        self.rankImageView.image = nil
        self.profileImageView.image = nil
        self.pointLabel.text = nil
        self.pointLabel.textColor = .white
        self.contentView.backgroundColor = nil
    }
    
}

//MARK: - Configure
extension TodayRankTableViewCell {
    
    func configureTop3(with vm: UPlusUser, at row: Int) {
        self.rankImageView.isHidden = false
        self.rankLabel.isHidden = true
        
        var rankImage: String = ""
        
        switch row {
        case 0:
            rankImage = ImageAsset.goldTrophy
        case 1:
            rankImage = ImageAsset.silverTrophy
        default:
            rankImage = ImageAsset.bronzeTrophy
        }
        
        self.rankImageView.image = UIImage(named: rankImage)
        self.username.text = vm.userNickname
        self.level.text = "Lv.n"
        self.pointLabel.text = "\(vm.userPointHistory?.first?.userPointCount ?? 0)P"
    }
    
    
    func configureOthers(with vm: UPlusUser, at row: Int) {
        self.rankLabel.isHidden = false
        self.rankImageView.isHidden = true
        
        self.rankLabel.text = "\(row + 3)"
        self.username.text = vm.userNickname
        self.level.text = "Lv.n"
        self.pointLabel.text = "\(vm.userPointHistory?.first?.userPointCount ?? 0)P"
    }
    
    func setUserTag() {
        self.highlightTagView.isHidden = false
    }
    
}

//MARK: - Set UI & Layout
extension TodayRankTableViewCell {
    
    private func setUI() {
        self.contentView.addSubviews(self.highlightTagView,
                                     self.rankImageView,
                                     self.rankLabel,
                                     self.profileImageView,
                                     self.username,
                                     self.level,
                                     self.pointLabel)
    }
    
    private func setLayout() {
        
        let height = contentView.frame.size.height
        
        NSLayoutConstraint.activate([
            self.highlightTagView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.highlightTagView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.highlightTagView.widthAnchor.constraint(equalToConstant: 8),
            self.highlightTagView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            
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
            
            self.level.topAnchor.constraint(equalTo: self.username.bottomAnchor),
            self.level.leadingAnchor.constraint(equalTo: self.username.leadingAnchor),
            self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.level.bottomAnchor, multiplier: 1),
            
            self.pointLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 2),
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.pointLabel.trailingAnchor, multiplier: 2),
            self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.pointLabel.bottomAnchor, multiplier: 2)
        ])
        self.level.setContentHuggingPriority(.defaultHigh, for: .vertical)
        self.pointLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }
    
}
