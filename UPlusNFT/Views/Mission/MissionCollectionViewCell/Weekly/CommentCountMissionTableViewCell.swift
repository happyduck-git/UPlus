//
//  CommentCountMissionTableViewCell.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/21.
//

import UIKit
import Nuke

final class CommentCountMissionTableViewCell: UITableViewCell {

    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8.0
        imageView.backgroundColor = UPlusColor.gray04
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nicknameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UPlusColor.gray05
        label.font = .systemFont(ofSize: UPlusFont.body2, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let commentLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: UPlusFont.body2, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.setUI()
        self.setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Configure
extension CommentCountMissionTableViewCell {
    
    func configure(image: String, nickname: String, comment: String) {
        self.nicknameLabel.text = nickname
        self.commentLabel.text = comment
        
        // TODO: profile image?
        
    }
    
}

// MARK: - Set UI & Layout
extension CommentCountMissionTableViewCell {
    
    private func setUI() {
        self.contentView.addSubviews(self.profileImageView,
                                     self.nicknameLabel,
                                     self.commentLabel)
    }
    
    private func setLayout() {
        
        let imageWidth = 30.0
        
        NSLayoutConstraint.activate([
            self.profileImageView.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 1),
            self.profileImageView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 1),

            self.profileImageView.widthAnchor.constraint(equalToConstant: imageWidth),
            self.profileImageView.heightAnchor.constraint(equalToConstant: imageWidth),
            
            self.nicknameLabel.topAnchor.constraint(equalTo: self.profileImageView.topAnchor),
            self.nicknameLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.profileImageView.trailingAnchor, multiplier: 1),
            
            self.commentLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.nicknameLabel.bottomAnchor, multiplier: 1),
            self.commentLabel.leadingAnchor.constraint(equalTo: self.nicknameLabel.leadingAnchor),
            self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.commentLabel.bottomAnchor, multiplier: 1)
        ])
    }
    
}
