//
//  UserMissionDataView.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/21.
//

import UIKit
import Combine

final class UserMissionDataView: PassThroughView {

    private var bindings = Set<AnyCancellable>()
    
    //MARK: - UI Elements
    private let infoButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: ImageAsset.infoGray), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let levelImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: ImageAsset.level1Title)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let pointLabel: UILabel = {
        let label = UILabel()
        label.text = " "
        label.font = .systemFont(ofSize: UPlusFont.caption1, weight: .bold)
        label.textColor = UPlusColor.deepGreen
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let levelDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = " "
        label.font = .systemFont(ofSize: UPlusFont.caption1)
        label.textColor = UPlusColor.lightGreen
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let levelProgressBar: UIProgressView = {
        let bar = UIProgressView()
        bar.clipsToBounds = true
        bar.progressViewStyle = .default
        bar.progressTintColor = UPlusColor.mint
        bar.trackTintColor = UPlusColor.gageBarBackgroudBlue
        bar.translatesAutoresizingMaskIntoConstraints = false
        return bar
    }()

    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
       
        self.setUI()
        self.setLayout()

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK: - Private
extension UserMissionDataView {
    private func setProgress(point: Int64, level: Int, maxPoint: Int) {
        let progress: Float = Float(point) / Float(maxPoint)
        self.levelProgressBar.setProgress(progress, animated: true)
    }
}

// MARK: - Configure & Bind
extension UserMissionDataView {
    func configure(vm: MyPageViewViewModel) {
        
        let point = vm.user.userTotalPoint ?? 0
        let level = Int(vm.userProfileViewModel?.level ?? 0)
        let max = UserLevel(rawValue: level)?.scoreRange.upperBound ?? 0
        
        self.pointLabel.text = String(describing: point)
        self.levelDescriptionLabel.text = String(format: MyPageConstants.pointLeftTillNextLevel, max - point)
        
        var levelImage: String = " "
        switch level {
        case 1:
            levelImage = ImageAsset.level1Title
        case 2:
            levelImage = ImageAsset.level2Title
        case 3:
            levelImage = ImageAsset.level3Title
        case 4:
            levelImage = ImageAsset.level4Title
        case 5:
            levelImage = ImageAsset.level5Title
        default:
            levelImage = ImageAsset.level1Title
        }
        
        self.levelImage.image = UIImage(named: levelImage)
        
        
        self.setProgress(point: point, level: level, maxPoint: Int(max))
        self.bind(with: vm)
    }
    
    private func bind(with vm: MyPageViewViewModel) {
        
        self.bindings.forEach { $0.cancel() }
        self.bindings.removeAll()
        
        vm.$newPoint
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let `self` = self else { return }
                if vm.memberShip.isVIP && vm.memberShip.isJustRegisterd {
                    self.pointLabel.text = String(describing: $0)
                }
            }
            .store(in: &bindings)
        
    }
}

extension UserMissionDataView {
    private func setUI() {
        self.addSubviews(self.infoButton,
                         self.levelImage,
                         self.pointLabel,
                         self.levelDescriptionLabel,
                         self.levelProgressBar)
    }
    
    private func setLayout() {
    
        NSLayoutConstraint.activate([
            self.levelImage.topAnchor.constraint(equalToSystemSpacingBelow: self.topAnchor, multiplier: 2),
            self.levelImage.leadingAnchor.constraint(equalToSystemSpacingAfter: self.leadingAnchor, multiplier: 2),
            self.bottomAnchor.constraint(equalToSystemSpacingBelow: self.levelImage.bottomAnchor, multiplier: 2),
            
            self.infoButton.topAnchor.constraint(equalTo: self.levelImage.topAnchor),
            self.trailingAnchor.constraint(equalToSystemSpacingAfter: self.infoButton.trailingAnchor, multiplier: 2),
            
            self.levelProgressBar.topAnchor.constraint(equalToSystemSpacingBelow: self.infoButton.bottomAnchor, multiplier: 2),
            self.levelProgressBar.leadingAnchor.constraint(equalToSystemSpacingAfter: self.levelImage.trailingAnchor, multiplier: 3),
            self.levelProgressBar.trailingAnchor.constraint(equalTo: self.infoButton.trailingAnchor),
            self.bottomAnchor.constraint(equalToSystemSpacingBelow: self.pointLabel.bottomAnchor, multiplier: 1),
            
            self.pointLabel.topAnchor.constraint(equalTo: self.levelProgressBar.bottomAnchor),
            self.pointLabel.leadingAnchor.constraint(equalTo: self.levelProgressBar.leadingAnchor),
            self.levelDescriptionLabel.topAnchor.constraint(equalTo: self.pointLabel.topAnchor),
            self.levelDescriptionLabel.trailingAnchor.constraint(equalTo: self.levelProgressBar.trailingAnchor)
        ])
        self.levelProgressBar.setContentHuggingPriority(.defaultLow, for: .vertical)
    }

}
