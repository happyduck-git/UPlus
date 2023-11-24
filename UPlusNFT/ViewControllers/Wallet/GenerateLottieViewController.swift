//
//  GenerateLottieViewController.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/14.
//

import UIKit
import Combine

final class GenerateLottieViewController: UIViewController {
    // MARK: - Dependency
    private let vm: UPlusNft
    
    // MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    // MARK: -  UI Elements
    private let descriptionLabel: UILabel = {
       let label = UILabel()
        label.textColor = UPlusColor.gray04
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let sortButtonStack: UIStackView = {
       let stack = UIStackView()
        stack.spacing = 10.0
        stack.distribution = .fillEqually
        stack.axis = .horizontal
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let idCardButton: UIButton = {
       let button = UIButton()
        button.backgroundColor = UPlusColor.mint01
        button.setTitle(LottieConstants.idCard, for: .normal)
        button.clipsToBounds = true
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    private let gifButton: UIButton = {
       let button = UIButton()
        button.backgroundColor = UPlusColor.mint01
        button.setTitle(LottieConstants.gif, for: .normal)
        button.clipsToBounds = true
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    private let lottieView: UIImageView = {
       let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private let shareButtonStack: UIStackView = {
       let stack = UIStackView()
        stack.spacing = 10.0
        stack.distribution = .fillEqually
        stack.axis = .horizontal
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let downloadButton: UIButton = {
       let button = UIButton()
        button.backgroundColor = .black
        button.setTitle(LottieConstants.download, for: .normal)
        button.clipsToBounds = true
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    private let shareButton: UIButton = {
       let button = UIButton()
        button.backgroundColor = .black
        button.setTitle(LottieConstants.share, for: .normal)
        button.clipsToBounds = true
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        // Do any additional setup after loading the view.
    }
    
    // MARK: - Init
    init(vm: UPlusNft) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
        
        self.setUI()
        self.setLayout()
        self.configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Configure
extension GenerateLottieViewController {
    private func configure() {
        do {
            let user = try UPlusUser.getCurrentUser()
            self.descriptionLabel.text = String(format: LottieConstants.description, user.userNickname)
        }
        catch {
            print("Error getting current user from UserDefaults -- \(error)")
        }
    }
}

// MARK: - Set UI & Layout
extension GenerateLottieViewController {
    private func setUI() {
        
        self.sortButtonStack.addArrangedSubviews(self.idCardButton,
                                                 self.gifButton)
        self.shareButtonStack.addArrangedSubviews(self.downloadButton,
                                                 self.shareButton)
        
        self.view.addSubviews(self.descriptionLabel,
                              self.sortButtonStack,
                              self.lottieView,
                              self.shareButtonStack)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.descriptionLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.view.safeAreaLayoutGuide.topAnchor, multiplier: 2),
            self.descriptionLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.view.safeAreaLayoutGuide.leadingAnchor, multiplier: 2),
            self.view.trailingAnchor.constraint(equalToSystemSpacingAfter: self.descriptionLabel.trailingAnchor, multiplier: 2),
            
            self.sortButtonStack.topAnchor.constraint(equalToSystemSpacingBelow: self.descriptionLabel.bottomAnchor, multiplier: 2),
            self.sortButtonStack.leadingAnchor.constraint(equalTo: self.descriptionLabel.leadingAnchor),
            self.sortButtonStack.trailingAnchor.constraint(equalTo: self.descriptionLabel.trailingAnchor),
            
            self.lottieView.topAnchor.constraint(equalToSystemSpacingBelow: self.sortButtonStack.bottomAnchor, multiplier: 2),
            self.lottieView.leadingAnchor.constraint(equalTo: self.descriptionLabel.leadingAnchor),
            self.lottieView.trailingAnchor.constraint(equalTo: self.descriptionLabel.trailingAnchor),
            self.lottieView.heightAnchor.constraint(equalTo: self.lottieView.widthAnchor),
            
            self.shareButtonStack.topAnchor.constraint(equalToSystemSpacingBelow: self.lottieView.bottomAnchor, multiplier: 2),
            self.shareButtonStack.leadingAnchor.constraint(equalTo: self.descriptionLabel.leadingAnchor),
            self.shareButtonStack.trailingAnchor.constraint(equalTo: self.descriptionLabel.trailingAnchor),
            self.view.bottomAnchor.constraint(equalToSystemSpacingBelow: self.shareButtonStack.bottomAnchor, multiplier: 2)
        ])
    }
}
