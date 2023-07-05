//
//  DefaultCollectionViewCell.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/07/05.
//

import UIKit

final class DefaultCollectionViewCell: UICollectionViewCell {
    
    //MARK: - UI Elements
    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


//MARK: - Set UI & Layout
extension DefaultCollectionViewCell {
    private func setUI() {
        self.contentView.addSubview(label)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalToSystemSpacingBelow: contentView.topAnchor, multiplier: 1),
            label.leadingAnchor.constraint(equalToSystemSpacingAfter: contentView.leadingAnchor, multiplier: 1),
            contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: label.trailingAnchor, multiplier: 1),
            contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: label.bottomAnchor, multiplier: 1)
        ])
    }
}

//MARK: - Configure
extension DefaultCollectionViewCell {
    func configure(with text: String) {
        label.text = text
    }
}
