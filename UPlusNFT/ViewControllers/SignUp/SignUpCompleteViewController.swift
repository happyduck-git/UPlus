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
        label.font = .systemFont(ofSize: UPlusFont.head3, weight: .heavy)
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
        // Go to mission vc
        
        // NOTE: Temporary cell view model.
        let userEmail = Auth.auth().currentUser?.email ?? "username@gmail.com"
        let username = userEmail.components(separatedBy: "@").first ?? "N/A"
        let tempProfileImage = "https://i.seadn.io/gae/lW22aEwUE0IqGaYm5HRiMS8DwkDwsdjPpprEqYnBqo2s7gSR-JqcYOjU9LM6p32ujG_YAEd72aDyox-pdCVK10G-u1qZ3zAsn2r9?auto=format&dpr=1&w=200"
        
        let tempVM = MissionMainViewViewModel(profileImage: tempProfileImage,
                                              username: username,
                                              points: 10,
                                              maxPoints: 15,
                                              level: 1,
                                              numberOfMissions: 4,
                                              timeLeft: 12,
                                              quizTitle: "OX 퀴즈",
                                              quizDesc: "1분이면 끝! 데일리 퀴즈 풀기",
                                              quizPoint: 1,
                                              dailyMissionCellVMList: [
                                                DailyMissionCollectionViewCellViewModel(
                                                    missionTitle: "매일 6000보 걷기",
                                                    missionImage: "https://i.seadn.io/gae/0Qx_dJjClFLvuYFGzVUpvrOyjMuWVZjyUAU7FPNHUkg2XQzhgEBrV2kTDD-k8l0RoUiEh3lT93dGRHmb_MA57vQ0z2ZI7AY06qM9qTs?auto=format&dpr=1&w=200",
                                                    missionPoint: 1,
                                                    missionCount: 15
                                                ),
                                                DailyMissionCollectionViewCellViewModel(
                                                    missionTitle: "매일 6000보 걷기",
                                                    missionImage: "https://i.seadn.io/gae/PYzUnkLUGXrZp0GHQvNSx8-UWdeus_UxkypDeXRWmroFRL_4eWbxm7LqJvQIUSUdXxHqNRSRWkyc_sWjFrPqAxzsgzY2f6be4x1b9Q?auto=format&dpr=1&w=200",
                                                    missionPoint: 2,
                                                    missionCount: 6
                                                ),
                                                DailyMissionCollectionViewCellViewModel(
                                                    missionTitle: "매일 6000보 걷기",
                                                    missionImage: "https://i.seadn.io/gae/hxqKVEpDu1GmI8OIVpUeQFdvqWd6HKUREfEt58lBvCBEtJrTgsIRKOk2UFYVUK8jvwz8ir6sEGir862LntFXXb_shyUXSkkTCagzfA?auto=format&dpr=1&w=200",
                                                    missionPoint: 3,
                                                    missionCount: 10
                                                )
                                              ]
        )
        
        let vc = MissionMainViewController(vm: tempVM)
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
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .cancel)
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
