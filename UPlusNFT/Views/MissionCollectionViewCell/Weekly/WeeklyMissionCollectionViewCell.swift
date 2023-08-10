//
//  WeeklyMissionCollectionViewCell.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/31.
//

import UIKit

final class WeeklyMissionCollectionViewCell: UICollectionViewCell {
    
    enum WeeklyCellType {
        case open
        case close
    }
    
    private let titleStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .leading
        stack.distribution = .fillProportionally
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let missionTitle: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: UPlusFont.head6, weight: .bold)
        return label
    }()
    
    private let missionDescription: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: UPlusFont.subTitle2, weight: .medium)
        return label
    }()
  
    private let openDateLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.numberOfLines = 2
        label.textAlignment = .center
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.backgroundColor = .white
        self.contentView.clipsToBounds = true
        self.contentView.layer.cornerRadius = 30
        self.setUI()
        self.setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.openDateLabel.isHidden = true
    }
    
    func resetCell() {
        self.missionTitle.text = nil
        self.missionDescription.text = nil
    }
}

// MARK: - Configure with View Model
extension WeeklyMissionCollectionViewCell {
    func configure(type: WeeklyCellType,
                   title: String,
                   period: String,
                   point: Int64,
                   openDate: String? = nil) {
        switch type {
        case .open:
            self.missionTitle.text = title
            self.missionDescription.text = "참여기간: " + period
            // TODO: Point 원형 뱃지 텍스트에 포인트 추가
            self.openDateLabel.isHidden = true
        case .close:
            self.addOpenDateLabel()
            
//            self.missionTitle.text = title
//            self.missionDescription.text = "참여기간: " + period
            self.openDateLabel.text = "🔒\n" + (openDate ?? "08.28") + "에 오픈" 
        }
    }
}

// MARK: - Set UI & Layout
extension WeeklyMissionCollectionViewCell {
    private func setUI() {
        self.contentView.addSubviews(self.titleStack)
        self.titleStack.addArrangedSubviews(self.missionTitle,
                                            self.missionDescription)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.titleStack.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 2),
            self.titleStack.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 2),
            self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.titleStack.bottomAnchor, multiplier: 2),
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.titleStack.trailingAnchor, multiplier: 2)
        ])
        
        self.missionDescription.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }

    private func addOpenDateLabel() {
        self.openDateLabel.isHidden = false
        self.contentView.addSubview(openDateLabel)
        NSLayoutConstraint.activate([
            self.openDateLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.openDateLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.openDateLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.openDateLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
        ])
    }
}
