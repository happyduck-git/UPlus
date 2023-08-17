//
//  StampCollectionViewCell.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/28.
//

import UIKit

final class StampCollectionViewCell: UICollectionViewCell {
    
    // MARK: - UI Elements
    private let pointView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.backgroundColor = UPlusColor.mint03
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let markImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.clipsToBounds = true
        self.contentView.backgroundColor = UPlusColor.gray01
        self.contentView.layer.borderColor = UPlusColor.mint02.cgColor
        self.contentView.layer.borderWidth = 1.5
        
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
        self.pointView.isHidden = true
    }
    
    func resetCell() {
        self.markImageView.image = nil
    }
}

extension StampCollectionViewCell {
    
    func showGiftMark(at item: Int) {
        if (item + 1) % 5 == 0 {
            self.markImageView.image = UIImage(named: ImageAsset.stampGift)
        }
    }
    
    func showCheckMark(at item: Int) {
        self.pointView.isHidden = false
        var image: String = ""
        
        if (item + 1) % 5 == 0 {
            image = ImageAsset.stampPoint
        } else {
            image = ImageAsset.checkWhite
        }
        self.markImageView.image = UIImage(named: image)
    }
}

extension StampCollectionViewCell {
    private func setUI() {
        self.contentView.addSubviews(self.pointView,
                                    self.markImageView)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.pointView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.pointView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.pointView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.pointView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            
            self.markImageView.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 1),
            self.markImageView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 1),
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.markImageView.trailingAnchor, multiplier: 1),
            self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.markImageView.bottomAnchor, multiplier: 1)
        ])
    }
}
