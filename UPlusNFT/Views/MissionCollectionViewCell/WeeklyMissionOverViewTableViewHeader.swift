//
//  WeeklyMissionOverViewTableViewHeader.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/03.
//

import UIKit

final class WeeklyMissionOverViewTableViewHeader: UIView {
    
    // MARK: - UI Elements
    private let themeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: UPlusFont.subTitle3, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UPlusColor.lightGreen2
        label.font = .systemFont(ofSize: UPlusFont.head5, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let divider: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let nftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: ImageAsset.skeletonNft)
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 3.0
        imageView.layer.borderColor = UIColor.systemGray2.cgColor
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let descriptionLabel: UILabel = {
       let label = UILabel()
        label.numberOfLines = 2
        label.textColor = .black
        label.textAlignment = .center
        label.font = .systemFont(ofSize: UPlusFont.subTitle2, weight: .semibold)
        label.text = "미션을 완료하여\nNFT를 받아보세요"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let missionDaysLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
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

// MARK: - Configure with View Model
extension WeeklyMissionOverViewTableViewHeader {
    func configure(with vm: WeeklyMissionOverViewViewModel) {
        self.themeLabel.text = "테마 " + String(describing: vm.numberOfWeek)
        self.titleLabel.text = vm.title
        self.missionDaysLabel.text = vm.missionDays
    }
}

// MARK: - Set UI & Layout
extension WeeklyMissionOverViewTableViewHeader {
    private func setUI() {
        self.addSubviews(self.themeLabel,
                         self.titleLabel,
                         self.divider,
                         self.nftImageView,
                         self.descriptionLabel,
                         self.missionDaysLabel)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.themeLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.topAnchor, multiplier: 2),
            self.themeLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.titleLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.themeLabel.bottomAnchor, multiplier: 1),
            self.titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            
            self.divider.topAnchor.constraint(equalToSystemSpacingBelow: self.titleLabel.bottomAnchor, multiplier: 2),
            self.divider.heightAnchor.constraint(equalToConstant: 1),
            self.divider.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.divider.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            self.nftImageView.topAnchor.constraint(equalToSystemSpacingBelow: self.divider.bottomAnchor, multiplier: 2),
            self.nftImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            
            self.descriptionLabel.centerXAnchor.constraint(equalTo: self.nftImageView.centerXAnchor),
            self.descriptionLabel.centerYAnchor.constraint(equalTo: self.nftImageView.centerYAnchor),
            self.descriptionLabel.leadingAnchor.constraint(equalTo: self.nftImageView.leadingAnchor),
            self.descriptionLabel.trailingAnchor.constraint(equalTo: self.nftImageView.trailingAnchor),
            
            self.missionDaysLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.nftImageView.bottomAnchor, multiplier: 1),
            self.missionDaysLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.bottomAnchor.constraint(equalToSystemSpacingBelow: self.bottomAnchor, multiplier: 2)
        ])
    }
}
