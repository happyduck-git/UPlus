//
//  RankBottomFlatSheetView.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/24.
//

import UIKit
import Combine
import Nuke

final class RankBottomFlatSheetView: PassThroughView {

    // MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    // MARK: - UI Elements
    private let bottomSheetView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        
//        view.layer.shadowColor = UIColor.darkGray.cgColor
//        view.layer.shadowOpacity = 0.3
//        view.layer.shadowOffset = CGSize(width: 0.0, height: -5)
//        view.clipsToBounds = false
        
        view.clipsToBounds = true
        view.layer.cornerRadius = 20
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        view.layer.borderColor = UPlusColor.gray02.cgColor
        view.layer.borderWidth = 2.0
        
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let rankLabel: UILabel = {
        let label = UILabel()
        label.textColor = UPlusColor.gray05
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: UPlusFont.body1, weight: .bold)
        return label
    }()
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.backgroundColor = UPlusColor.grayBackground
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let username: UILabel = {
        let label = UILabel()
        label.textColor = UPlusColor.mint05
        label.font = .systemFont(ofSize: UPlusFont.body1, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let level: UILabel = {
        let label = UILabel()
        label.textColor = UPlusColor.mint04
        label.font = .systemFont(ofSize: UPlusFont.caption1, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let pointImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: ImageAssets.point)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let pointLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UPlusColor.gray05
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .clear
        
        self.setUI()
        self.setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func layoutSubviews() {
        super.layoutSubviews()

        self.setBottomBorder()
        DispatchQueue.main.async {
            self.profileImageView.layer.cornerRadius = self.profileImageView.frame.height / 2
        }
        
    }
    
}

// MARK: - Bind
extension RankBottomFlatSheetView {
    func bind(with vm: RankingViewViewModel, at item: Int) {
        
        
        
        if item == 0 {
            vm.$currentUserTodayRank
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    guard let `self` = self else { return }
                    
                    self.rankLabel.text = String(describing: vm.userTodayRank)
                    self.pointLabel.text = String(describing: $0?.userPointHistory?.first?.userPointCount ?? 0)
                    
                    Task {
                        do {
                            let user = try UPlusUser.getCurrentUser()
                            
                            self.username.text = user.userNickname
                            self.level.text = String(format: "Lv.%d",UserDefaults.standard.integer(forKey: UserDefaultsConstants.level))
                            
                            let highest = UPlusUser.getTheHighestAvatarNft(of: user)
                            guard let document = highest else { return }
                            
                            let doc = try await document.getDocument()
                            let imageUrl = doc[FirestoreConstants.nftContentImageUrl] as? String ?? ""
                        
                            guard let url = URL(string: imageUrl) else { return }
                            self.profileImageView.image = try await ImagePipeline.shared.image(for: url)
                        }
                        catch {
                            UPlusLogger.logger.error("Error getting imagurl from nft document -- \(String(describing: error))")
                        }
                    }
                    
                    
                    
                }
                .store(in: &bindings)
        } else {
            vm.$currentUserTotalRank
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    guard let `self` = self else { return }
                    self.pointLabel.text = String(describing: $0?.userTotalPoint ?? 0)
                }
                .store(in: &bindings)
        }
        
    }
}

// MARK: - Set UI & Layout
extension RankBottomFlatSheetView {
    private func setUI() {
        self.addSubviews(self.bottomSheetView)
        self.bottomSheetView.addSubviews(self.rankLabel,
                                         self.profileImageView,
                                         self.username,
                                         self.level,
                                         self.pointImage,
                                         self.pointLabel)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.bottomSheetView.topAnchor.constraint(equalToSystemSpacingBelow: self.topAnchor, multiplier: 80),
            self.bottomSheetView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.bottomSheetView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.bottomSheetView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            self.rankLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.bottomSheetView.topAnchor, multiplier: 2),
            self.rankLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.bottomSheetView.leadingAnchor, multiplier: 3),
            self.bottomSheetView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.rankLabel.bottomAnchor, multiplier: 2),
            
            self.profileImageView.topAnchor.constraint(equalTo: self.rankLabel.topAnchor),
            self.profileImageView.widthAnchor.constraint(equalTo: self.profileImageView.heightAnchor),
            self.profileImageView.centerYAnchor.constraint(equalTo: self.rankLabel.centerYAnchor),
            self.profileImageView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.rankLabel.trailingAnchor, multiplier: 2),
            
            self.username.topAnchor.constraint(equalToSystemSpacingBelow: self.bottomSheetView.topAnchor, multiplier: 1),
            self.username.leadingAnchor.constraint(equalToSystemSpacingAfter: self.profileImageView.trailingAnchor, multiplier: 1),
            
            self.level.topAnchor.constraint(equalTo: self.username.bottomAnchor),
            self.level.leadingAnchor.constraint(equalTo: self.username.leadingAnchor),
            self.bottomSheetView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.level.bottomAnchor, multiplier: 1),
            
            self.pointImage.topAnchor.constraint(equalTo: self.pointLabel.topAnchor),
            self.pointImage.leadingAnchor.constraint(equalToSystemSpacingAfter: self.username.trailingAnchor, multiplier: 2),
            self.pointImage.bottomAnchor.constraint(equalTo: self.pointLabel.bottomAnchor),
            self.pointImage.widthAnchor.constraint(equalTo: self.pointImage.heightAnchor),
            
            self.pointLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.bottomSheetView.topAnchor, multiplier: 2),
            self.bottomSheetView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.pointLabel.trailingAnchor, multiplier: 3),
            self.bottomSheetView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.pointLabel.bottomAnchor, multiplier: 2)
        ])
    }
    
    private func setBottomBorder() {
        let bottomLayer = CALayer()
        bottomLayer.backgroundColor = UIColor.white.cgColor
        bottomLayer.frame = CGRect(x: 0, y: self.bottomSheetView.frame.minY, width: self.frame.width, height: 2)
        self.bottomSheetView.layer.addSublayer(bottomLayer)
    }
}
