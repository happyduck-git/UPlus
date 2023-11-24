//
//  WeeklyAnswerQuizMissionCollectionViewCell.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/28.
//

import UIKit

final class WeeklyAnswerQuizMissionCollectionViewCell: UICollectionViewCell {
    
    private let label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 80, weight: .bold)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.1
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.backgroundColor = .white
        
        self.setUI()
        self.setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension WeeklyAnswerQuizMissionCollectionViewCell {
    
    func configure(with text: Character) {
        label.text = String(text)
    }
    
}

extension WeeklyAnswerQuizMissionCollectionViewCell {
    
    private func setUI() {
        self.contentView.addSubview(label)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.label.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.label.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.label.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.label.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
        ])
    }
    
}
