//
//  MissionCollectionViewHeader.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/18.
//

import UIKit

class MissionCollectionViewHeader: UICollectionReusableView {
    
    enum HeaderType {
        case normal
        case rightButton
    }
    
    private var type: HeaderType = .normal
    
    // MARK: - UI Elements
    private let sectionTitle: UILabel = {
        let label = UILabel()
        label.text = MissionConstants.dailyQuiz
        label.textColor = .black
        label.font = .systemFont(ofSize: UPlusFont.head3, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let detailButton: UIButton = {
       let button = UIButton()
        button.isHidden = true
        button.clipsToBounds = true
        button.setTitle(MissionConstants.details, for: .normal)
        button.backgroundColor = .white
        button.setTitleColor(.darkGray, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .systemGray6
        setUI()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Set UI & Layout
extension MissionCollectionViewHeader {
    private func setUI() {
        self.addSubviews(sectionTitle,
                         detailButton)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.sectionTitle.topAnchor.constraint(equalToSystemSpacingBelow: self.topAnchor, multiplier: 1),
            self.sectionTitle.leadingAnchor.constraint(equalToSystemSpacingAfter: self.leadingAnchor, multiplier: 3),
            self.bottomAnchor.constraint(equalToSystemSpacingBelow: self.sectionTitle.bottomAnchor, multiplier: 1),
            
            self.detailButton.centerYAnchor.constraint(equalTo: self.sectionTitle.centerYAnchor),
            self.trailingAnchor.constraint(equalToSystemSpacingAfter: self.detailButton.trailingAnchor, multiplier: 2)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.detailButton.layer.cornerRadius = self.detailButton.frame.height / 2
    }
}
