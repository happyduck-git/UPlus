//
//  LevelDividerCollectionViewCell.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/08/21.
//

import UIKit

final class LevelDividerCollectionViewCell: UICollectionViewCell {
    
    private let divider: UIView = {
        let view = UIView()
        view.backgroundColor = UPlusColor.gray04
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let levelLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: UPlusFont.body2, weight: .bold)
        label.textColor = UPlusColor.gray04
        label.backgroundColor = UPlusColor.grayBackground
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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

extension LevelDividerCollectionViewCell {
    
    func configure(level: Int) {
        self.levelLabel.text = String(format: MyPageConstants.eventLevel, level)
    }
    
}

//MARK: - Set UI & Layout
extension LevelDividerCollectionViewCell {
    
    private func setUI() {
        self.contentView.addSubviews(self.divider,
                                     self.levelLabel)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.divider.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            self.divider.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 2),
            self.divider.heightAnchor.constraint(equalToConstant: 2),
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.divider.trailingAnchor, multiplier: 2),
            
            self.levelLabel.centerYAnchor.constraint(equalTo: self.divider.centerYAnchor),
            self.levelLabel.centerXAnchor.constraint(equalTo: self.divider.centerXAnchor),
            self.levelLabel.widthAnchor.constraint(equalToConstant: 150)
        ])
    }
    
}
