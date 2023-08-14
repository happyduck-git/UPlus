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
        button.setImage(UIImage(systemName: SFSymbol.infoFill)?.withTintColor(.systemGray, renderingMode: .alwaysOriginal), for: .normal)
        button.setTitle("레벨 등급 안내", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: UPlusFont.subTitle3, weight: .regular)
        button.setTitleColor(.systemGray, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let levelLabel: UILabel = {
        let label = UILabel()
        label.text = " "
        label.textColor = UPlusColor.gradientDeepBlue
        label.font = .systemFont(ofSize: UPlusFont.head4, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let pointImage: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: ImageAsset.point)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let pointLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: UPlusFont.subTitle3, weight: .bold)
        label.textColor = UPlusColor.deepGreen
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let levelDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "다음 레벨 업까지 120P"
        label.font = .systemFont(ofSize: UPlusFont.subTitle3)
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
        
        self.backgroundColor = UPlusColor.lightBlue.withAlphaComponent(0.5)
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 5.0
        self.setUI()
        self.setLayout()

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.levelProgressBar.setProgress(0.7, animated: true)
        
    }
    
}

extension UserMissionDataView {
    func configure(vm: MyPageViewViewModel) {
        
        self.pointLabel.text = String(describing: vm.user.userTotalPoint ?? 0)
        self.levelLabel.text = MissionConstants.levelPrefix + String(describing: vm.userProfileViewModel?.level ?? 0)
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
        self.addSubviews(infoButton,
                         levelLabel,
                         pointImage,
                         pointLabel,
                         levelDescriptionLabel,
                         levelProgressBar)
    }
    
    private func setLayout() {
    
        NSLayoutConstraint.activate([
            self.levelLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.topAnchor, multiplier: 2),
            self.levelLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.leadingAnchor, multiplier: 2),
            
            self.infoButton.topAnchor.constraint(equalTo: self.levelLabel.topAnchor),
            self.trailingAnchor.constraint(equalToSystemSpacingAfter: self.infoButton.trailingAnchor, multiplier: 2),
            
            self.pointImage.topAnchor.constraint(equalToSystemSpacingBelow: self.levelLabel.bottomAnchor, multiplier: 1),
            self.pointImage.leadingAnchor.constraint(equalTo: self.levelLabel.leadingAnchor),
            self.pointLabel.topAnchor.constraint(equalTo: self.pointImage.topAnchor),
            self.pointLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.pointImage.trailingAnchor, multiplier: 1),
            self.levelDescriptionLabel.topAnchor.constraint(equalTo: self.pointImage.topAnchor),
            self.levelDescriptionLabel.trailingAnchor.constraint(equalTo: self.infoButton.trailingAnchor),
            
            self.levelProgressBar.topAnchor.constraint(equalToSystemSpacingBelow: self.levelDescriptionLabel.bottomAnchor, multiplier: 1),
            self.levelProgressBar.leadingAnchor.constraint(equalTo: self.levelLabel.leadingAnchor),
            self.levelProgressBar.trailingAnchor.constraint(equalTo: self.infoButton.trailingAnchor),
            self.bottomAnchor.constraint(equalToSystemSpacingBelow: self.levelProgressBar.bottomAnchor, multiplier: 2)
        ])
        self.levelProgressBar.setContentHuggingPriority(.defaultLow, for: .vertical)
    }

}
