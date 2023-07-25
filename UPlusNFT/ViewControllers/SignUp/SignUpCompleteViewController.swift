//
//  SignUpCompleteViewController.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/18.
//

import UIKit
import FirebaseAuth

class SignUpCompleteViewController: UIViewController {

    //MARK: - Dependency
    private let vm: SignUpViewViewModel
    
    //MARK: - UI Elements
    private let greetingsLabel: UILabel = {
       let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.font = .systemFont(ofSize: UPlusFont.head5, weight: .heavy)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
       let label = UILabel()
        label.textColor = .systemGray
        label.text = SignUpConstants.desctiptions
        label.font = .systemFont(ofSize: UPlusFont.subTitle2, weight: .heavy)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .systemGray2
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nftInfoLabel: UILabel = {
       let label = UILabel()
        label.textColor = .darkGray
        label.text = SignUpConstants.nftInfo
        label.font = .systemFont(ofSize: UPlusFont.subTitle2, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var welcomeGiftButton: UIButton = {
       let button = UIButton()
        button.backgroundColor = .black
        button.clipsToBounds = true
        button.setTitleColor(.white, for: .normal)
        button.setTitle(SignUpConstants.redeemGift, for: .normal)
        button.addTarget(self, action: #selector(welcomeDidTap), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    //MARK: - Init
    init(vm: SignUpViewViewModel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.setUI()
        self.setLayout()
        self.configure(with: vm)
        self.setNavigationItem()
    }

}

//MARK: - Private
extension SignUpCompleteViewController {
    @objc func welcomeDidTap() {
        self.dismiss(animated: true)
        
        let vc = MyPageViewController()
        self.navigationController?.modalPresentationStyle = .fullScreen
        self.show(vc, sender: self)
    }
}

//MARK: - Set UI & Layout
extension SignUpCompleteViewController {
    
    private func setUI() {
        self.view.addSubviews(self.greetingsLabel,
                              self.descriptionLabel,
                              self.nftImageView,
                              self.nftInfoLabel,
                              self.welcomeGiftButton)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.greetingsLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.view.safeAreaLayoutGuide.topAnchor, multiplier: 4),
            self.greetingsLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            
            self.descriptionLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.greetingsLabel.bottomAnchor, multiplier: 1),
            self.descriptionLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
          
            self.nftImageView.topAnchor.constraint(equalToSystemSpacingBelow: self.descriptionLabel.bottomAnchor, multiplier: 4),
            self.nftImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.nftImageView.heightAnchor.constraint(equalTo: self.greetingsLabel.widthAnchor),
            self.nftImageView.widthAnchor.constraint(equalTo: self.greetingsLabel.widthAnchor),
            
            self.nftInfoLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.nftImageView.bottomAnchor, multiplier: 4),
            self.nftInfoLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            
            self.welcomeGiftButton.leadingAnchor.constraint(equalToSystemSpacingAfter: self.view.safeAreaLayoutGuide.leadingAnchor, multiplier: 2),
            self.welcomeGiftButton.heightAnchor.constraint(equalToConstant: self.view.frame.height / 14),
            self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: self.welcomeGiftButton.trailingAnchor, multiplier: 2),
            self.view.safeAreaLayoutGuide.bottomAnchor.constraint(equalToSystemSpacingBelow: self.welcomeGiftButton.bottomAnchor, multiplier: 2)
        ])
        
    }
    
    private func setNavigationItem() {
        let rightButtonItem = UIBarButtonItem(image: UIImage(named: ImageAsset.xMark)?.withTintColor(.systemGray2, renderingMode: .alwaysOriginal), style: .done, target: self, action: #selector(welcomeDidTap))
        self.navigationItem.setRightBarButton(rightButtonItem, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.welcomeGiftButton.layer.cornerRadius = self.welcomeGiftButton.frame.height / 7
    }
}

//MARK: - Configure
extension SignUpCompleteViewController {
    private func configure(with vm: SignUpViewViewModel) {
        Task {
            do {
                let username = UserDefaults.standard.string(forKey: UserDefaultsConstants.username) ?? "username"
                self.greetingsLabel.text = username + SignUpConstants.greetings
                self.nftImageView.image = try await URL.urlToImage(URL(string:vm.welcomeNftImage))
            }
            catch {
                print("Error fetching welcome nft image -- \(error.localizedDescription)")
            }
        }
    }
}
