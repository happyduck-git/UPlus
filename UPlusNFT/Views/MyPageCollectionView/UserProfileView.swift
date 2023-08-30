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
    
    private let shadowView: PassThroughView = {
        let view = PassThroughView()
        view.backgroundColor = UPlusColor.gray09
        view.layer.shadowOpacity = 0.9
        view.layer.shadowRadius = 30.0
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.layer.shadowColor = UPlusColor.mint03.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let profileContainer: PassThroughView = {
       let view = PassThroughView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 20.0
        view.layer.borderWidth = 6.0
        view.layer.borderColor = UPlusColor.mint03.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let profileImage: GIFImageView = {
        let gifView = GIFImageView()
        gifView.image = UIImage(named: ImageAsset.profileDefault)
        gifView.translatesAutoresizingMaskIntoConstraints = false
        return gifView
    }()
    
    private let lottieButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: ImageAsset.starButton), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
        
    private let dailyRankView: DailyRankView = {
       let view = DailyRankView()
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let userMissionDataView: UserMissionDataView = {
        let view = UserMissionDataView()
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

    override func layoutSubviews() {
        super.layoutSubviews()
        
        DispatchQueue.main.async {
            self.dailyRankView.layer.cornerRadius = self.dailyRankView.frame.height / 2
        }
    }
    
}

extension UserProfileView {
 
    func configure(with vm: MyPageViewViewModel) {
        
        self.bind(with: vm)
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
                print("Nickname: \(vm.user.userNickname)")
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
        self.addSubviews(self.backgroundImage,
                         self.usernameLabel,
                         self.shadowView,
                         self.profileContainer)
        
        self.profileContainer.addSubviews(self.profileImage,
                                          self.lottieButton,
                                          self.dailyRankView,
                                          self.userMissionDataView)
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
            
            self.profileContainer.topAnchor.constraint(equalToSystemSpacingBelow: self.usernameLabel.bottomAnchor, multiplier: 2),
            self.profileContainer.leadingAnchor.constraint(equalToSystemSpacingAfter: self.leadingAnchor, multiplier: 5),
            self.trailingAnchor.constraint(equalToSystemSpacingAfter: self.profileContainer.trailingAnchor, multiplier: 5),
            self.bottomAnchor.constraint(equalToSystemSpacingBelow: self.profileContainer.bottomAnchor, multiplier: 4),
            
            self.shadowView.topAnchor.constraint(equalToSystemSpacingBelow: self.profileContainer.topAnchor, multiplier: 1),
            self.shadowView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.profileContainer.leadingAnchor, multiplier: 1),
            self.profileContainer.trailingAnchor.constraint(equalToSystemSpacingAfter: self.shadowView.trailingAnchor, multiplier: 1),
            self.profileContainer.bottomAnchor.constraint(equalToSystemSpacingBelow: self.shadowView.bottomAnchor, multiplier: 1),
            
            self.profileImage.topAnchor.constraint(equalTo: self.profileContainer.topAnchor),
            self.profileImage.leadingAnchor.constraint(equalTo: self.profileContainer.leadingAnchor),
            self.profileImage.trailingAnchor.constraint(equalTo: self.profileContainer.trailingAnchor),
            
            self.profileImage.heightAnchor.constraint(equalTo: self.profileImage.widthAnchor),

            self.profileImage.trailingAnchor.constraint(equalTo: self.lottieButton.trailingAnchor, constant: 2),
            self.lottieButton.bottomAnchor.constraint(equalToSystemSpacingBelow: self.profileImage.bottomAnchor, multiplier: 1),
        
            self.dailyRankView.topAnchor.constraint(equalToSystemSpacingBelow: self.profileImage.topAnchor, multiplier: 2),
            self.dailyRankView.heightAnchor.constraint(equalToConstant: 30),
            self.dailyRankView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.profileImage.leadingAnchor, multiplier: 2),
            
            self.userMissionDataView.topAnchor.constraint(equalTo: self.profileImage.bottomAnchor),
            self.userMissionDataView.leadingAnchor.constraint(equalTo: self.profileImage.leadingAnchor),
            self.userMissionDataView.trailingAnchor.constraint(equalTo: self.profileImage.trailingAnchor),
            self.userMissionDataView.bottomAnchor.constraint(equalTo: self.profileContainer.bottomAnchor)
            
        ])
        
    }
    
}

extension UserProfileView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        return hitView == self ? nil : hitView
    }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct UserProfileViewPreView: PreviewProvider{
    static var previews: some View {
        UIViewPreview {
            let view = UserProfileView(frame: .zero)
            return view
        }.previewLayout(.sizeThatFits)
    }
}
#endif
