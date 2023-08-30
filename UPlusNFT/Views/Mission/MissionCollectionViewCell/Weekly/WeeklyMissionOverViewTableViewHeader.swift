//
//  WeeklyMissionOverViewTableViewHeader.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/03.
//

import UIKit
import Combine

final class WeeklyMissionOverViewTableViewHeader: UIView {
    
    // MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    // MARK: - UI Elements
    private let topContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UPlusColor.blue02
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let topLabel: UILabel = {
        let label = UILabel()
        
        let normalFont: UIFont = .systemFont(ofSize: UPlusFont.body2, weight: .regular)
        let boldFont: UIFont = .systemFont(ofSize: UPlusFont.body2, weight: .bold)
        
        let attributedString = NSMutableAttributedString(string: MissionConstants.weeklyTopTitle,
                                                         attributes: [
                                                            .foregroundColor: UPlusColor.blue05,
                                                            .font: normalFont
                                                         ])
        
        if let range = attributedString.string.range(of: MissionConstants.episodeCerti) {
            let nsRange = NSRange(range, in: attributedString.string)
            
            attributedString.addAttributes([
                .foregroundColor: UPlusColor.blue05,
                .font: boldFont
            ], range: nsRange)
        }
        
        label.attributedText = attributedString
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let episodeNumImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let episodeTitleImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let episodeSubtitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: UPlusFont.body2, weight: .regular)
        label.textColor = UPlusColor.gray03
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let themeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: UPlusFont.caption1, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let nftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.borderColor = UIColor.systemGray2.cgColor
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
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

// MARK: - Bind with View Model
extension WeeklyMissionOverViewTableViewHeader {
    func bind(with vm: WeeklyMissionOverViewViewModel) {
        self.bindings.forEach { $0.cancel() }
        self.bindings.removeAll()
        
        vm.numberOfCompeletion
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (week, count) in
                var image: String = "\(week)-\(count)"
                self?.nftImageView.image = UIImage(named: image)
            }
            .store(in: &bindings)
        
    }
}

// MARK: - Configure with View Model
extension WeeklyMissionOverViewTableViewHeader {
    func configure(with vm: WeeklyMissionOverViewViewModel) {
        
        var subTitle: UIImage?
        var title: UIImage?
        var nftImage: UIImage?
        var episodeSubtitleLabel: String?
        
        switch vm.week {
        case 1:
            subTitle = UIImage(named: WeeklyEpisode.week1.episodeSubTitle)
            title = UIImage(named: WeeklyEpisode.week1.episodeTitle)
            episodeSubtitleLabel = WeeklyEpisode.week1.episodeDescription
            nftImage = UIImage(named: WeeklyEpisode.week1.episodeEmptyPiece)
            
        case 2:
            subTitle = UIImage(named: WeeklyEpisode.week2.episodeSubTitle)
            title = UIImage(named: WeeklyEpisode.week2.episodeTitle)
            episodeSubtitleLabel = WeeklyEpisode.week2.episodeDescription
            nftImage = UIImage(named: WeeklyEpisode.week2.episodeEmptyPiece)
            
        default:
            subTitle = UIImage(named: WeeklyEpisode.week3.episodeSubTitle)
            title = UIImage(named: WeeklyEpisode.week3.episodeTitle)
            episodeSubtitleLabel = WeeklyEpisode.week3.episodeDescription
            nftImage = UIImage(named: WeeklyEpisode.week3.episodeEmptyPiece)
        }
        
        self.episodeNumImage.image = subTitle
        self.episodeTitleImage.image = title
        self.episodeSubtitleLabel.text = episodeSubtitleLabel
        self.nftImageView.image = nftImage
        
//        self.topLabel.text = String(format: <#T##String#>, vm.missionDays)
//        self.missionDaysLabel.text = vm.missionDays
    }
    
}

// MARK: - Set UI & Layout
extension WeeklyMissionOverViewTableViewHeader {
    private func setUI() {
        self.addSubviews(self.topContainerView,
                         self.episodeNumImage,
                         self.episodeTitleImage,
                         self.episodeSubtitleLabel,
                         self.themeLabel,
                         self.nftImageView)
        
        self.topContainerView.addSubview(self.topLabel)
    }
    
    private func setLayout() {

        NSLayoutConstraint.activate([
            self.topContainerView.topAnchor.constraint(equalTo: self.topAnchor),
            self.topContainerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.topContainerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.topContainerView.heightAnchor.constraint(equalToConstant: 60),
            
            self.topLabel.centerYAnchor.constraint(equalTo: self.topContainerView.centerYAnchor),
            self.topLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.topContainerView.leadingAnchor, multiplier: 1),
            self.topContainerView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.topLabel.trailingAnchor, multiplier: 1),
            
            self.episodeNumImage.topAnchor.constraint(equalToSystemSpacingBelow: self.topContainerView.bottomAnchor, multiplier: 3),
            self.episodeNumImage.leadingAnchor.constraint(equalToSystemSpacingAfter: self.leadingAnchor, multiplier: 2),
            self.trailingAnchor.constraint(equalToSystemSpacingAfter: self.episodeNumImage.trailingAnchor, multiplier: 2),
            
            self.episodeTitleImage.topAnchor.constraint(equalToSystemSpacingBelow: self.episodeNumImage.bottomAnchor, multiplier: 1),
            self.episodeTitleImage.heightAnchor.constraint(equalToConstant: 106),
            self.episodeTitleImage.leadingAnchor.constraint(equalToSystemSpacingAfter: self.leadingAnchor, multiplier: 2),
            self.trailingAnchor.constraint(equalToSystemSpacingAfter: self.episodeTitleImage.trailingAnchor, multiplier: 2),
            
            self.episodeSubtitleLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.episodeTitleImage.bottomAnchor, multiplier: 1),
            self.episodeSubtitleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.leadingAnchor, multiplier: 1),
            self.trailingAnchor.constraint(equalToSystemSpacingAfter: self.episodeSubtitleLabel.trailingAnchor, multiplier: 1),
            
            self.nftImageView.topAnchor.constraint(equalToSystemSpacingBelow: self.episodeSubtitleLabel.bottomAnchor, multiplier: 2),
            self.nftImageView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.leadingAnchor, multiplier: 2),
            self.trailingAnchor.constraint(equalToSystemSpacingAfter: self.nftImageView.trailingAnchor, multiplier: 2),
            self.bottomAnchor.constraint(equalToSystemSpacingBelow: self.nftImageView.bottomAnchor, multiplier: 1)
        ])
    }
}
