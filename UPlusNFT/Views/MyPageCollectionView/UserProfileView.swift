//
//  UserProfileView.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/31.
//

import UIKit
import Nuke
import Combine

final class UserProfileView: PassThroughView {
    
    //MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    // MARK: - UI Elements
    let gradientLayer = CAGradientLayer()
    
    private let profileImage: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 3.0
        imageView.backgroundColor = UPlusColor.pointCirclePink.withAlphaComponent(0.5)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = " "
        label.textColor = .black
        label.font = .systemFont(ofSize: UPlusFont.main, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
        
        self.clipsToBounds = true
        self.layer.cornerRadius = 30
        self.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
       
        self.layer.addSublayer(gradientLayer)
        
        self.setUI()
        self.setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        self.setGradientLayer()
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
        
        vm.$todayRank2
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let `self` = self else { return }
//                self.userMissionDataView.rankingButton.setTitle(String(describing: $0) + "위", for: .normal)
            }
            .store(in: &bindings)
        
        vm.$missionViewModel
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let `self` = self,
                      let image = result?.profileImage else { return }
                Task {
                    do {
                        let url = URL(string: image)!
                        self.profileImage.image = try await ImagePipeline.shared.image(for: url)
                        
                    }
                    catch {
                        print("Error converting profile image -- \(error)")
                    }
                }
                self.usernameLabel.text = vm.user.userNickname
                self.userMissionDataView.configure(vm: vm)
            }
            .store(in: &bindings)
 
    }

}

extension UserProfileView {
    
    private func setGradientLayer() {
        gradientLayer.frame = self.bounds
        gradientLayer.colors = [UPlusColor.gradientMediumBlue.cgColor, UPlusColor.gradientLightBlue.cgColor]
    }
    
    private func setUI() {
        self.addSubviews(profileImage,
                         usernameLabel,
                         dailyRankView,
                         userMissionDataView)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.profileImage.topAnchor.constraint(equalToSystemSpacingBelow: self.topAnchor, multiplier: 3),
            self.profileImage.leadingAnchor.constraint(equalToSystemSpacingAfter: self.leadingAnchor, multiplier: 8),
            self.trailingAnchor.constraint(equalToSystemSpacingAfter: self.profileImage.trailingAnchor, multiplier: 8),
            self.profileImage.heightAnchor.constraint(equalTo: self.profileImage.widthAnchor),

            self.usernameLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.profileImage.bottomAnchor, multiplier: 4),
            self.usernameLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.leadingAnchor, multiplier: 2),
           
            self.dailyRankView.topAnchor.constraint(equalTo: self.usernameLabel.topAnchor),
            self.dailyRankView.bottomAnchor.constraint(equalTo: self.usernameLabel.bottomAnchor),
            self.trailingAnchor.constraint(equalToSystemSpacingAfter: self.dailyRankView.trailingAnchor, multiplier: 2),
            
            self.userMissionDataView.topAnchor.constraint(equalToSystemSpacingBelow: self.usernameLabel.bottomAnchor, multiplier: 2),
            self.userMissionDataView.leadingAnchor.constraint(equalTo: self.usernameLabel.leadingAnchor),
            self.userMissionDataView.trailingAnchor.constraint(equalTo: self.dailyRankView.trailingAnchor),
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
