//
//  NewEventCollectionViewCell.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/08/31.
//

import UIKit

final class NewEventCollectionViewCell: UICollectionViewCell {
    private let button: UIButton = {
       let button = UIButton()
        
        return button
    }()
    
    private let imageView: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: ImageAsset.newEventBanner)
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUI()
        self.setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension NewEventCollectionViewCell {
    private func setUI() {
        self.contentView.addSubviews(self.button)
        self.button.addSubview(self.imageView)
    }
    
    private func setLayout() {
        self.button.frame = self.contentView.bounds
        self.imageView.frame = self.button.bounds
    }
}
