//
//  OnBoardingViewController2.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/23.
//

import UIKit
import Combine
import FirebaseAuth
import OSLog

final class OnBoardingViewController2: UIViewController {

    // MARK: - Dependency
    private let firestoreManager = FirestoreManager.shared
    
    // MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    //MARK: - UI Elements
    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.isScrollEnabled = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let canvasView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let onBoardImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "on-boarding")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let startButton: UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.layer.cornerRadius = 8.0
        button.backgroundColor = UPlusColor.mint03
        button.setTitleColor(.black, for: .normal)
        button.setTitle(OnBoardingConstants.start, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setUI()
        self.setLayout()
     
        self.bind()
    }

}

// MARK: - Bind
extension OnBoardingViewController2 {
 
    private func bind() {
        func bindViewToViewModel() {
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

extension OnBoardingViewController2 {
    private func startButtonDidTap() {
        
        if let user = Auth.auth().currentUser {
            UPlusLogger.logger.info("User is logged in.")
            
            Task {
                await self.setBasicUserInfo(email: user.email ?? FirestoreConstants.noUserEmail)
                let userInfo = try UPlusUser.getCurrentUser()
                
                let loginVM = LoginViewViewModel()
                let loginVC = LoginViewController(vm: loginVM)
                
                let vm = MyPageViewViewModel(user: userInfo,
                                             memberShip: (false, userInfo.userHasVipNft))
                let myPageVC = MyPageViewController(vm: vm)
  
                self.navigationController?.pushViewController(loginVC, animated: false)
                self.navigationController?.pushViewController(myPageVC, animated: true)
            }
            
        } else {
            UPlusLogger.logger.info("User is not logged in.")
            let loginVM = LoginViewViewModel()
            let loginVC = LoginViewController(vm: loginVM)
            self.show(loginVC, sender: self)
        }
    }
}

extension OnBoardingViewController2 {
    
    private func setUI() {
        self.view.addSubviews(self.scrollView,
                             self.startButton)
        self.scrollView.addSubview(self.canvasView)
        self.canvasView.addSubviews(self.onBoardImageView)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.scrollView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
           
            self.canvasView.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor),
            self.canvasView.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor),
            self.canvasView.topAnchor.constraint(equalTo: self.scrollView.topAnchor),
            self.canvasView.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor),
            self.canvasView.widthAnchor.constraint(equalTo: self.scrollView.widthAnchor),
            
        ])

        NSLayoutConstraint.activate([
            self.onBoardImageView.topAnchor.constraint(equalTo: self.canvasView.topAnchor),
            self.onBoardImageView.leadingAnchor.constraint(equalTo: self.canvasView.leadingAnchor),
            self.onBoardImageView.bottomAnchor.constraint(equalTo: self.canvasView.bottomAnchor),
        ])
        
        NSLayoutConstraint.activate([
            self.startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            self.startButton.leadingAnchor.constraint(equalToSystemSpacingAfter: self.view.leadingAnchor, multiplier: 3),
            self.view.trailingAnchor.constraint(equalToSystemSpacingAfter: self.startButton.trailingAnchor, multiplier: 3),
            self.startButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}

extension OnBoardingViewController2 {
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
