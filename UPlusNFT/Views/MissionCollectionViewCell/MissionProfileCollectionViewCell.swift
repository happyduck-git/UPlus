//
//  MissionProfileCollectionViewCell.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/18.
//

import UIKit
import Nuke

protocol MissionCollectionViewHeaderProtocol: AnyObject {
    func levelUpButtonDidTap()
}

final class MissionProfileCollectionViewCell: UICollectionViewCell {
    
    //MARK: - Delegate
    weak var delegate: MissionCollectionViewHeaderProtocol?
    
    //MARK: - Property
    private let profileImage: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: UPlusFont.head1, weight: .heavy)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let pointLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: UPlusFont.head3, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let verticalBar: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let levelLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: UPlusFont.head3, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let infoButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: SFSymbol.info)?.withTintColor(.darkGray, renderingMode: .alwaysOriginal), for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let levelBadge: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: UPlusFont.subTitle3)
        label.backgroundColor = UPlusColor.pointGagePink
        label.clipsToBounds = true
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let progressLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: UPlusFont.subTitle3)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let progressBar: UIProgressView = {
        let bar = UIProgressView()
        bar.progress = 0.0
        bar.clipsToBounds = true
        bar.progressViewStyle = .default
        bar.progressTintColor = UPlusColor.pointGagePink
        bar.trackTintColor = .systemGray
        bar.translatesAutoresizingMaskIntoConstraints = false
        return bar
    }()
    
    private let levelUpButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.black, for: .normal)
        button.setTitle(MissionConstants.levelUp, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUI()
        setLayout()
        setButtonConfig()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Configure
extension MissionProfileCollectionViewCell {
    func configure(with vm: MissionMainViewViewModel) {
        Task {
            do {
                let url = URL(string: vm.profileImage)
                self.profileImage.image = try await URL.urlToImage(url)
                self.usernameLabel.text = vm.username
                self.pointLabel.text = String(describing: vm.points) + "pt"
                self.levelLabel.text = "Level " + String(describing: vm.level)
                self.levelBadge.text = MissionConstants.levelPrefix + String(describing: vm.level)
                self.progressLabel.text = String(describing: vm.points) + "/" + String(describing: vm.maxPoints)
            }
            catch {
                print("Error fetching profileImage -- \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Set UI & Layout
extension MissionProfileCollectionViewCell {
    
    private func setUI() {
        self.addSubviews(
            profileImage,
            usernameLabel,
            pointLabel,
            verticalBar,
            levelLabel,
            infoButton,
            progressBar,
            levelBadge,
            levelUpButton
        )
        
        self.progressBar.addSubview(progressLabel)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.profileImage.topAnchor.constraint(equalToSystemSpacingBelow: self.topAnchor, multiplier: 3),
            self.profileImage.leadingAnchor.constraint(equalToSystemSpacingAfter: self.leadingAnchor, multiplier: 5),
            self.trailingAnchor.constraint(equalToSystemSpacingAfter: self.profileImage.trailingAnchor, multiplier: 5),
            self.profileImage.heightAnchor.constraint(equalTo: self.profileImage.widthAnchor),
            
            self.usernameLabel.topAnchor.constraint(equalToSystemSpacingBelow: profileImage.bottomAnchor, multiplier: 2),
            self.usernameLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.leadingAnchor, multiplier: 3),
            self.trailingAnchor.constraint(equalToSystemSpacingAfter: self.usernameLabel.trailingAnchor, multiplier: 1),

            self.pointLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.usernameLabel.bottomAnchor, multiplier: 1),
            self.pointLabel.leadingAnchor.constraint(equalTo: self.usernameLabel.leadingAnchor),
            self.verticalBar.topAnchor.constraint(equalToSystemSpacingBelow: self.usernameLabel.bottomAnchor, multiplier: 1),
            self.verticalBar.widthAnchor.constraint(equalToConstant: 1),
            self.verticalBar.leadingAnchor.constraint(equalToSystemSpacingAfter: self.pointLabel.trailingAnchor, multiplier: 1),
            self.verticalBar.heightAnchor.constraint(equalTo: self.pointLabel.heightAnchor),
            
            self.levelLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.usernameLabel.bottomAnchor, multiplier: 1),
            self.levelLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.verticalBar.trailingAnchor, multiplier: 1),
            self.infoButton.topAnchor.constraint(equalToSystemSpacingBelow: self.usernameLabel.bottomAnchor, multiplier: 1),
            self.infoButton.leadingAnchor.constraint(equalToSystemSpacingAfter: self.levelLabel.trailingAnchor, multiplier: 1),
            
            self.levelBadge.topAnchor.constraint(equalToSystemSpacingBelow: self.pointLabel.bottomAnchor, multiplier: 2),
            self.levelBadge.leadingAnchor.constraint(equalTo: self.usernameLabel.leadingAnchor),
            self.levelBadge.heightAnchor.constraint(equalToConstant: 40),
            self.bottomAnchor.constraint(equalToSystemSpacingBelow: self.levelBadge.bottomAnchor, multiplier: 2),
            
            self.progressBar.topAnchor.constraint(equalToSystemSpacingBelow: self.levelBadge.topAnchor, multiplier: 1),
            self.progressBar.leadingAnchor.constraint(equalTo: self.levelBadge.centerXAnchor),
            self.levelBadge.bottomAnchor.constraint(equalToSystemSpacingBelow: self.progressBar.bottomAnchor, multiplier: 1),
            
            self.levelUpButton.leadingAnchor.constraint(equalToSystemSpacingAfter: self.progressBar.trailingAnchor, multiplier: 3),
            self.levelUpButton.centerYAnchor.constraint(equalTo: self.progressBar.centerYAnchor),
            self.trailingAnchor.constraint(equalToSystemSpacingAfter: self.levelUpButton.trailingAnchor, multiplier: 3),
            
        ])
        
        // Set layouts of point progress label.
        NSLayoutConstraint.activate([
            self.progressLabel.centerYAnchor.constraint(equalTo: self.progressBar.centerYAnchor),
            self.progressBar.trailingAnchor.constraint(equalToSystemSpacingAfter: self.progressLabel.trailingAnchor, multiplier: 1)
        ])
        
        self.levelBadge.setContentHuggingPriority(.defaultLow, for: .vertical)
        self.progressBar.setContentHuggingPriority(.defaultLow, for: .vertical)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Set profile image view corner radius.
        self.profileImage.layer.cornerRadius = self.profileImage.frame.height / 10
        
        // Set progress bar corner radius.
        self.levelBadge.widthAnchor.constraint(equalTo: self.levelBadge.heightAnchor).isActive = true
        
        self.levelBadge.layer.cornerRadius = self.levelBadge.frame.height / 2
        self.progressBar.layer.cornerRadius = self.progressBar.frame.height / 2
        self.progressBar.layer.sublayers?[1].cornerRadius = self.progressBar.frame.height / 2
        self.progressBar.subviews[1].clipsToBounds = true
        
        /* Checking progress animation */
        self.progressBar.setProgress(0.9, animated: true)
    }
    
    private func setButtonConfig() {
        
        if #available(iOS 15.0, *) {
            let title = AttributedString(MissionConstants.levelUp, attributes: AttributeContainer([.font: UIFont.systemFont(ofSize: UPlusFont.subTitle3, weight: .bold)]))
                
            var config = UIButton.Configuration.filled()
            config.baseBackgroundColor = .systemGray3
            config.contentInsets = NSDirectionalEdgeInsets(top: 3, leading: 4, bottom: 3, trailing: 4)
            config.attributedTitle = title
            levelUpButton.configuration = config
            
        } else {
            levelUpButton.titleEdgeInsets = UIEdgeInsets(top: 3, left: 4, bottom: 3, right: 4)
            levelUpButton.backgroundColor = .systemGray3
            levelUpButton.titleLabel?.font = .systemFont(ofSize: UPlusFont.subTitle3,  weight: .bold)
        }
        
    }
}
