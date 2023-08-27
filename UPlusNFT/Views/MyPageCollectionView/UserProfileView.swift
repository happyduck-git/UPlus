//
//  UserProfileView.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/31.
//

import UIKit
import Nuke
import Combine
import Gifu

final class UserProfileView: PassThroughView {
    
    //MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    // MARK: - UI Elements
    private let backgroundImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: ImageAsset.backgroundStar)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = " "
        label.numberOfLines = 2
        label.textColor = .white
        label.font = .systemFont(ofSize: UPlusFont.h2, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let profileImage: GIFImageView = {
        let gifView = GIFImageView()
        gifView.clipsToBounds = true
        gifView.layer.borderWidth = 3.0
        gifView.layer.borderColor = UIColor.white.cgColor
        gifView.backgroundColor = UPlusColor.grayBackground
        gifView.translatesAutoresizingMaskIntoConstraints = false
        return gifView
    }()
    
    private let dailyRankView: DailyRankView = {
       let view = DailyRankView()
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let userMissionDataView: UserMissionDataView = {
        let view = UserMissionDataView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UPlusColor.gray09
        
        self.clipsToBounds = true
        self.layer.cornerRadius = 30
        self.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        
        self.setUI()
        self.setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension UserProfileView {
 
    func configure(with vm: MyPageViewViewModel) {
        
        self.bind(with: vm)
        self.profileImage.layer.cornerRadius = self.profileImage.frame.height / 3
    }
    
    
    private func bind(with vm: MyPageViewViewModel) {
        self.bindings.forEach { $0.cancel() }
        self.bindings.removeAll()
 
        vm.$userProfileViewModel
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let `self` = self,
                      let image = result?.profileImage else { return }
                
                let url = URL(string: image)!
                self.profileImage.animate(withGIFURL: url)
                self.profileImage.prepareForAnimation(withGIFURL: url)
                
                self.usernameLabel.text = String(format: MyPageConstants.usernameSuffix, vm.user.userNickname)
                self.userMissionDataView.configure(vm: vm)
            }
            .store(in: &bindings)
 
        vm.$rank
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let `self` = self else { return }
                self.dailyRankView.configure(rank: $0)
            }
            .store(in: &bindings)
 
    }

}

extension UserProfileView {

    private func setUI() {
        self.addSubviews(backgroundImage,
                         profileImage,
                         usernameLabel,
                         dailyRankView,
                         userMissionDataView)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.backgroundImage.topAnchor.constraint(equalTo: self.topAnchor),
            self.backgroundImage.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.backgroundImage.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.backgroundImage.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
        
        NSLayoutConstraint.activate([
            
            self.usernameLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.topAnchor, multiplier: 2),
            self.usernameLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.leadingAnchor, multiplier: 4),
            self.trailingAnchor.constraint(equalToSystemSpacingAfter: self.usernameLabel.trailingAnchor, multiplier: 4),
            
            self.profileImage.topAnchor.constraint(equalToSystemSpacingBelow: self.usernameLabel.bottomAnchor, multiplier: 3),
            self.profileImage.leadingAnchor.constraint(equalToSystemSpacingAfter: self.leadingAnchor, multiplier: 8),
            self.trailingAnchor.constraint(equalToSystemSpacingAfter: self.profileImage.trailingAnchor, multiplier: 8),
            self.profileImage.heightAnchor.constraint(equalTo: self.profileImage.widthAnchor),

            self.dailyRankView.topAnchor.constraint(equalTo: self.profileImage.topAnchor),
            self.dailyRankView.heightAnchor.constraint(equalToConstant: 30),
            self.trailingAnchor.constraint(equalToSystemSpacingAfter: self.dailyRankView.trailingAnchor, multiplier: 2),
            
            self.userMissionDataView.topAnchor.constraint(equalToSystemSpacingBelow: self.profileImage.bottomAnchor, multiplier: 2),
            self.userMissionDataView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.leadingAnchor, multiplier: 2),
            self.trailingAnchor.constraint(equalToSystemSpacingAfter: self.userMissionDataView.trailingAnchor, multiplier: 2),
            self.bottomAnchor.constraint(equalToSystemSpacingBelow: self.userMissionDataView.bottomAnchor, multiplier: 4)
        ])
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        DispatchQueue.main.async {
            self.profileImage.layer.cornerRadius = self.profileImage.frame.height / 3
            self.dailyRankView.layer.cornerRadius = self.dailyRankView.frame.height / 2
        }
    }
}

extension UserProfileView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        return hitView == self ? nil : hitView
    }
}
