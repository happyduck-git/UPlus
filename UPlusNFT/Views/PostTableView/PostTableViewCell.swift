//
//  PostTableViewCell.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/06/26.
//

import UIKit

final class PostTableViewCell: UITableViewCell {
    
    // MARK: - UI Elements
    
    private let title: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let likeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "heart"), for: .normal) //heart.fill
        button.setTitleColor(.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let commentButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "text.bubble"), for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setUI()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Set UI & Layout
    private func setUI() {
        contentView.addSubviews(
            title,
            likeButton,
            commentButton
        )
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.title.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 2),
            self.title.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 2),
            
            self.likeButton.leadingAnchor.constraint(equalTo: self.title.leadingAnchor),
            self.likeButton.topAnchor.constraint(equalToSystemSpacingBelow: self.title.bottomAnchor, multiplier: 1),
            self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.likeButton.bottomAnchor, multiplier: 2),
            
            self.commentButton.topAnchor.constraint(equalTo: self.likeButton.topAnchor),
            self.commentButton.leadingAnchor.constraint(equalToSystemSpacingAfter: self.likeButton.trailingAnchor, multiplier: 1),
            self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.commentButton.bottomAnchor, multiplier: 2),
        ])
        self.title.setContentHuggingPriority(.defaultLow, for: .vertical)
    }
    
    // MARK: - Internal
    func configure(with vm: PostTableViewCellModel) {
        self.title.text = vm.postTitle
        self.likeButton.setTitle(String(describing: vm.likeUserCount), for: .normal)
        self.commentButton.setTitle(String(describing: vm.commentCount), for: .normal)
    }
    
}
