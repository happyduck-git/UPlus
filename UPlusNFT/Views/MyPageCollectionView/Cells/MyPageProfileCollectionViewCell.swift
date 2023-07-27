//
//  MyPageProfileCollectionView.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/21.
//

import UIKit
import Nuke
import Combine

final class MyPageProfileCollectionViewCell: UICollectionViewCell {
    
    //MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    // MARK: - UI Elements
    private let profileImage: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 3.0
        imageView.backgroundColor = UPlusColor.pointCirclePink.withAlphaComponent(0.5)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let shareNftButton: UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.setImage(UIImage(systemName: "sparkles")?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        button.setTitle("NFT 자랑하기", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: UPlusFont.head6, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UPlusColor.deepBlue
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "username"
        label.textColor = .black
        label.font = .systemFont(ofSize: UPlusFont.main, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let levelLabel: UILabel = {
        let label = UILabel()
        label.text = "Lv.1"
        label.textColor = UPlusColor.pointGagePink
        label.font = .systemFont(ofSize: UPlusFont.head6, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let infoButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: SFSymbol.infoFill)?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let userMissionDataView: UserMissionDataView = {
        let view = UserMissionDataView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.clipsToBounds = true
        self.contentView.layer.cornerRadius = 30
        self.contentView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        
        self.setGradientLayer()
        self.setUI()
        self.setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension MyPageProfileCollectionViewCell {
 
    func configure(with vm: MyPageViewViewModel) {
        
        self.bind(with: vm)
        
        Task {
            do {
                let imageString = vm.user.userNfts?.first?.documentID
                ?? ImageAsset.dummyNftImageUrl
                let url = URL(string: imageString)! // TODO: Optional 처리.
                self.profileImage.image = try await ImagePipeline.shared.image(for: url)
                self.usernameLabel.text = vm.user.userNickname
                self.userMissionDataView.configure(vm: vm)
                
                self.profileImage.layer.cornerRadius = self.profileImage.frame.height / 3
            }
            catch {
                print("Error fetching profileImage -- \(error)")
            }
        }
        
    }
    
    
    private func bind(with vm: MyPageViewViewModel) {
        self.bindings.forEach { $0.cancel() }
        self.bindings.removeAll()
        
        vm.$todayRank2
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let `self` = self else { return }
                self.userMissionDataView.rankingButton.setTitle(String(describing: $0) + "위", for: .normal)
            }
            .store(in: &bindings)
    }

}

extension MyPageProfileCollectionViewCell {
    
    private func setGradientLayer() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.contentView.bounds
        gradientLayer.colors = [UPlusColor.gradientMediumBlue.cgColor, UPlusColor.gradientLightBlue.cgColor]
        self.contentView.layer.addSublayer(gradientLayer)
        
        let gradientLayer2 = CAGradientLayer()
        gradientLayer2.frame = self.shareNftButton.bounds
        gradientLayer2.colors = [UPlusColor.mint.cgColor, UPlusColor.deepBlue.cgColor]
        self.shareNftButton.layer.addSublayer(gradientLayer2)
        
    }
    
    private func setUI() {
        self.contentView.addSubviews(profileImage,
                                     shareNftButton,
                                     usernameLabel,
                                     levelLabel,
                                     infoButton,
                                     userMissionDataView)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.profileImage.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 3),
            self.profileImage.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 8),
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.profileImage.trailingAnchor, multiplier: 8),
            self.profileImage.heightAnchor.constraint(equalTo: self.profileImage.widthAnchor),
            
            self.shareNftButton.topAnchor.constraint(equalToSystemSpacingBelow: self.profileImage.bottomAnchor, multiplier: 2),
            self.shareNftButton.leadingAnchor.constraint(equalToSystemSpacingAfter: self.profileImage.leadingAnchor, multiplier: 7),
            self.shareNftButton.heightAnchor.constraint(equalToConstant: self.contentView.frame.height / 15),
            self.profileImage.trailingAnchor.constraint(equalToSystemSpacingAfter: self.shareNftButton.trailingAnchor, multiplier: 7),
            
            self.usernameLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.shareNftButton.bottomAnchor, multiplier: 2),
            self.usernameLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 2),
            self.levelLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.usernameLabel.trailingAnchor, multiplier: 1),
            self.levelLabel.bottomAnchor.constraint(equalTo: self.usernameLabel.bottomAnchor),
            
            self.infoButton.centerYAnchor.constraint(equalTo: self.usernameLabel.centerYAnchor),
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.infoButton.trailingAnchor, multiplier: 2),
            
            self.userMissionDataView.topAnchor.constraint(equalToSystemSpacingBelow: self.usernameLabel.bottomAnchor, multiplier: 2),
            self.userMissionDataView.leadingAnchor.constraint(equalTo: self.usernameLabel.leadingAnchor),
            self.userMissionDataView.trailingAnchor.constraint(equalTo: self.infoButton.trailingAnchor),
            self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.userMissionDataView.bottomAnchor, multiplier: 4)
        ])
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        DispatchQueue.main.async {
            self.profileImage.layer.cornerRadius = self.profileImage.frame.height / 3
            self.shareNftButton.layer.cornerRadius = self.shareNftButton.frame.height / 3
        }
    }
}
