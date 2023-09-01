//
//  RoutineMissionProgressCollectionViewCell.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/02.
//

import UIKit
import Combine

final class RoutineMissionProgressCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    // MARK: - UI Elements
    
    private let missionImage: UIImageView = {
          let imageView = UIImageView()
           imageView.contentMode = .scaleAspectFit
           imageView.image = UIImage(named: ImageAssets.routineImage)
           imageView.translatesAutoresizingMaskIntoConstraints = false
           return imageView
       }()

    private let title: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: UPlusFont.h5, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subTitle: UILabel = {
        let label = UILabel()
        label.textColor = UPlusColor.gray06
        label.font = .systemFont(ofSize: UPlusFont.h5, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let pointContainerView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 10.0
        view.backgroundColor = UPlusColor.blue01
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let pointLabel: UILabel = {
        let label = UILabel()
        label.textColor = UPlusColor.blue03
        label.textAlignment = .center
        label.font = .systemFont(ofSize: UPlusFont.caption1, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let progressBar: UIProgressView = {
        let progressView = UIProgressView()
        progressView.trackTintColor = UPlusColor.grayBackground
        progressView.progressTintColor = UPlusColor.blue03
        progressView.translatesAutoresizingMaskIntoConstraints = false
        return progressView
    }()
    
    private let numberOfParticipation: UILabel = {
        let label = UILabel()
        label.textColor = UPlusColor.green
        label.textAlignment = .center
        label.font = .systemFont(ofSize: UPlusFont.caption1, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.backgroundColor = .white
        self.contentView.clipsToBounds = true
        self.contentView.layer.cornerRadius = 30
        
        self.setUI()
        self.setLayout()
        self.configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Bind with View Model
extension RoutineMissionProgressCollectionViewCell {
    
    private func configure() {
        self.title.text = MissionType.dailyExpGoodWorker.displayName
        self.subTitle.text = MissionType.dailyExpGoodWorker.description
    }
    
    func bind(with vm: MyPageViewViewModel) {
        
        self.bindings.forEach { $0.cancel() }
        self.bindings.removeAll()
        
        vm.mission.$routineParticipationCount
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let `self` = self else { return }
                
                self.numberOfParticipation.text = String(format: MyPageConstants.routineMissionProgress, $0)
                self.setProgress($0)
            }
            .store(in: &bindings)
        
        vm.mission.$routinePoint
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let `self` = self else { return }
                
                self.pointLabel.text = String(describing: $0) + MissionConstants.pointUnit
            }
            .store(in: &bindings)
    }
}

//MARK: - Private
extension RoutineMissionProgressCollectionViewCell {
    private func setProgress(_ progress: Int) {
        self.progressBar.setProgress(Float(progress) / Float(MyPageConstants.routinMissionLimit), animated: true)
    }
}

// MARK: - Set UI & Layout
extension RoutineMissionProgressCollectionViewCell {
    private func setUI() {
        self.contentView.addSubviews(self.missionImage,
                                     self.title,
                                     self.subTitle,
                                     self.pointContainerView,
                                     self.progressBar,
                                     self.numberOfParticipation)
        
        self.pointContainerView.addSubview(self.pointLabel)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.missionImage.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 2),
            self.missionImage.widthAnchor.constraint(equalToConstant: 30),
            self.missionImage.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 2),
            self.progressBar.topAnchor.constraint(equalToSystemSpacingBelow: self.missionImage.bottomAnchor, multiplier: 1),

            self.title.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 2),
            self.title.leadingAnchor.constraint(equalToSystemSpacingAfter: self.missionImage.trailingAnchor, multiplier: 2),
            
            self.subTitle.topAnchor.constraint(equalToSystemSpacingBelow: self.title.bottomAnchor, multiplier: 1),
            self.subTitle.leadingAnchor.constraint(equalTo: self.title.leadingAnchor),

            self.pointContainerView.topAnchor.constraint(equalTo: self.title.topAnchor),
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.pointContainerView.trailingAnchor, multiplier: 2),
            self.pointContainerView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.title.trailingAnchor, multiplier: 2),
            self.pointContainerView.heightAnchor.constraint(equalToConstant: 30),

            self.progressBar.leadingAnchor.constraint(equalTo: self.missionImage.leadingAnchor),
            self.progressBar.trailingAnchor.constraint(equalTo: self.pointContainerView.trailingAnchor),
            self.progressBar.topAnchor.constraint(equalToSystemSpacingBelow: self.subTitle.bottomAnchor, multiplier: 2),

            self.numberOfParticipation.topAnchor.constraint(equalToSystemSpacingBelow: self.progressBar.bottomAnchor, multiplier: 1),
            self.numberOfParticipation.trailingAnchor.constraint(equalTo: self.pointContainerView.trailingAnchor),
            self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.numberOfParticipation.bottomAnchor, multiplier: 2)
        ])
        
        NSLayoutConstraint.activate([
            self.pointLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.pointContainerView.topAnchor, multiplier: 1),
            self.pointLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.pointContainerView.leadingAnchor, multiplier: 1),
            self.pointContainerView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.pointLabel.trailingAnchor, multiplier: 1),
            self.pointContainerView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.pointLabel.bottomAnchor, multiplier: 1)
        ])
    }
}
