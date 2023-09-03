//
//  NoRankCollectionViewCell.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/09/03.
//

import UIKit

final class NoRankTableViewCell: UITableViewCell {
    
    private let backgroundImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: ImageAssets.rankBackground)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
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

extension NoRankTableViewCell {
    private func setUI() {
        self.contentView.addSubviews(self.backgroundImage)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.backgroundImage.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.backgroundImage.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.backgroundImage.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.backgroundImage.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
        ])
    }
}
