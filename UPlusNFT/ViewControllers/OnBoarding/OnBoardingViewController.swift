//
//  OnBoardingViewController.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/07/19.
//

import UIKit
import Combine
import FirebaseAuth
import OSLog

final class OnBoardingViewController: UIViewController {
    
    private let logger = Logger()
    
    // MARK: - Dependency
    private let firestoreManager = FirestoreManager.shared
    
    // MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    //MARK: - UI Elements
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: SFSymbol.heartFill)?.withTintColor(.black, renderingMode: .alwaysOriginal)
        imageView.backgroundColor = .systemGray3
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let informationView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray3
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var showMoreButton: UIButton = {
        let button = UIButton()
        button.setTitle(OnBoardingConstants.showMore, for: .normal)
        button.setImage(UIImage(systemName: SFSymbol.arrowRight)?.withTintColor(.darkGray, renderingMode: .alwaysOriginal), for: .normal)
        button.semanticContentAttribute = .forceRightToLeft
        button.setTitleColor(.darkGray, for: .normal)
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var startButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .black
        button.clipsToBounds = true
        button.setTitleColor(.white, for: .normal)
        button.setTitle(OnBoardingConstants.start, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.setUI()
        self.setLayout()
        self.setNavigationBar()
        
        self.bind()
    }
    
}

// MARK: - Bind
extension OnBoardingViewController {
 
    private func bind() {
        func bindViewToViewModel() {
            self.showMoreButton.tapPublisher
                .receive(on: DispatchQueue.main)
                .sink { _ in
                    self.showMoreDidTap()
                }
                .store(in: &bindings)
            
            self.startButton.tapPublisher
                .receive(on: DispatchQueue.main)
                .sink { _ in
                    self.startButtonDidTap()
                }
                .store(in: &bindings)
        }
        func bindViewModelToView() {
            
        }
        
        bindViewToViewModel()
        bindViewModelToView()
    }
    
}

//MARK: - Set UI & Layout
extension OnBoardingViewController {
    
    private func setUI() {
        self.view.addSubviews(logoImageView,
                              informationView,
                              showMoreButton,
                              startButton)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.logoImageView.topAnchor.constraint(equalToSystemSpacingBelow: self.view.safeAreaLayoutGuide.topAnchor, multiplier: 1),
            self.logoImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            
            self.informationView.topAnchor.constraint(equalToSystemSpacingBelow: self.logoImageView.bottomAnchor, multiplier: 1),
            self.informationView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.view.safeAreaLayoutGuide.leadingAnchor, multiplier: 2),
            self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: self.informationView.trailingAnchor, multiplier: 2),
            
            self.showMoreButton.topAnchor.constraint(equalToSystemSpacingBelow: self.informationView.bottomAnchor, multiplier: 3),
            self.showMoreButton.leadingAnchor.constraint(equalTo: self.informationView.leadingAnchor),
            self.showMoreButton.trailingAnchor.constraint(equalTo: self.informationView.trailingAnchor),
            
            self.startButton.topAnchor.constraint(equalToSystemSpacingBelow: self.showMoreButton.bottomAnchor, multiplier: 3),
            self.startButton.leadingAnchor.constraint(equalTo: self.informationView.leadingAnchor),
            self.startButton.trailingAnchor.constraint(equalTo: self.informationView.trailingAnchor),
            self.view.safeAreaLayoutGuide.bottomAnchor.constraint(equalToSystemSpacingBelow: self.startButton.bottomAnchor, multiplier: 2)
        ])
        self.informationView.setContentHuggingPriority(.defaultLow, for: .vertical)
    }
    
    private func setNavigationBar() {
        self.navigationItem.backButtonTitle = " "
    }
    
}

//MARK: - Private
extension OnBoardingViewController {
    
    private func showMoreDidTap() {
        print("Need to define action for `PoC 소개 더 보기` button.")
    }

    private func startButtonDidTap() {
        
        if let user = Auth.auth().currentUser {
            logger.info("User is logged in.")
            
            Task {
                await self.setBasicUserInfo(email: user.email ?? FirestoreConstants.noUserEmail)
                let userInfo = try UPlusUser.getCurrentUser()
                
                let loginVM = LoginViewViewModel()
                let loginVC = LoginViewController(vm: loginVM)
                
                let vm = MyPageViewViewModel(user: userInfo,
                                             isJustRegistered: false,
                                             isVip: userInfo.userHasVipNft,
                                             todayRank: UPlusServiceInfoConstant.totalMembers)
                let myPageVC = MyPageViewController(vm: vm)
  
                self.navigationController?.pushViewController(loginVC, animated: false)
                self.navigationController?.pushViewController(myPageVC, animated: true)
            }
            
        } else {
            logger.info("User is not logged in.")
            let loginVM = LoginViewViewModel()
            let loginVC = LoginViewController(vm: loginVM)
            self.show(loginVC, sender: self)
        }
    }
    
}

extension OnBoardingViewController {
    /// Save basic user login information.
    private func setBasicUserInfo(email: String) async {
        do {
            let _ = try await UPlusUser.saveCurrentUser(email: email)
        }
        catch {
            switch error {
            case FirestoreError.userNotFound:
                print("User not found -- \(error)")
            default:
                print("Error fetching user -- \(error)")
            }
        }
    }
    
}
