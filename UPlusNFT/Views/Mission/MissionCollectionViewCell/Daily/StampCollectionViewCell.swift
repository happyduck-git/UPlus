//
//  StampCollectionViewCell.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/28.
//

import UIKit

final class StampCollectionViewCell: UICollectionViewCell {
    
    // MARK: - UI Elements
    private let pointLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .black
        return label
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
            self.contentView.layer.cornerRadius = self.contentView.frame.height / 2
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.contentView.backgroundColor = .white
    }
    
    func resetCell() {
        self.pointLabel.text = nil
    }
}

extension StampCollectionViewCell {
    func configure(with score: Int64) {
        self.pointLabel.text = String(describing: score) + MissionConstants.pointUnit
    }
}

extension StampCollectionViewCell {
    private func setUI() {
        self.contentView.addSubview(self.pointLabel)
    }
    
    private func setLayout() {
        self.pointLabel.frame = self.contentView.bounds
    }
}
