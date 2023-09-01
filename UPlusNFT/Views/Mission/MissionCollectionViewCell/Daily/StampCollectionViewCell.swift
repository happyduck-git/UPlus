//
//  StampCollectionViewCell.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/28.
//

import UIKit

final class StampCollectionViewCell: UICollectionViewCell {
    
    // MARK: - UI Elements

    private let markImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: ImageAssets.stampPointEmpty)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.backgroundColor = .clear
//        self.contentView.clipsToBounds = true
//        self.contentView.backgroundColor = UPlusColor.gray01
//        self.contentView.layer.borderColor = UPlusColor.mint02.cgColor
//        self.contentView.layer.borderWidth = 1.5
        
        self.setUI()
        self.setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        DispatchQueue.main.async {
            self.contentView.layer.cornerRadius = self.contentView.frame.height / 2.0
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.contentView.backgroundColor = UPlusColor.gray01
    }
    
    func resetCell() {
        self.markImageView.image = nil
    }
}

extension StampCollectionViewCell {
    
    func markNotYetParticipated(at item: Int) {
        var image: UIImage?
        
        if (item + 1) % 5 == 0 {
            image = UIImage(named: ImageAssets.stampGiftEmpty)
            
        } else {
            image = UIImage(named: ImageAssets.stampPointEmpty)
        }
        
        self.markImageView.image = image
    }
    
    func checkAsParticipated(at item: Int) {
        var image: UIImage?
        
        if (item + 1) % 5 == 0 {
            image = UIImage(named: ImageAssets.stampGiftFill)
        } else {
            image = UIImage(named: ImageAssets.stampPointFill)
        }
        self.markImageView.image = image
    }
}

extension StampCollectionViewCell {
    private func setUI() {
        self.contentView.addSubviews(self.markImageView)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.markImageView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.markImageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.markImageView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.markImageView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
        ])
    }
}
