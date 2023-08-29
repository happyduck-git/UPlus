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
    private let vm: OnBoardingViewViewModel
    
    // MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    //MARK: - UI Elements
    private let loadingVC = LoadingViewController()
    
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
        imageView.image = UIImage(named: ImageAsset.onBoarding)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let infoBottomView: UIView = {
       let view = UIView()
        view.backgroundColor = UPlusColor.gray05
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let bottomContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UPlusColor.gray08
        view.alpha = 0.8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let startButton: UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.layer.cornerRadius = 8.0
        button.backgroundColor = UPlusColor.mint03
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: UPlusFont.body1, weight: .bold)
        button.setTitle(OnBoardingConstants.start, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Init
    init(vm: OnBoardingViewViewModel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUI()
        self.setLayout()
        
        self.bind()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let statusBarHeight = view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        let navHeight = self.navigationController?.navigationBar.frame.height ?? 0

        self.onBoardImageView.topAnchor.constraint(equalTo: self.canvasView.topAnchor, constant: -navHeight - statusBarHeight).isActive = true
    }
    
}

// MARK: - Bind
extension OnBoardingViewController2 {
    
    private func bind() {
        func bindViewToViewModel() {
            self.startButton.tapPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    guard let `self` = self else { return }
                    
                    if !self.vm.isTapped {
                        self.vm.isTapped.toggle()
                        self.addChildViewController(self.loadingVC)
                        self.startButtonDidTap()
                    }
                    
                }
                .store(in: &bindings)
        }
        
        func bindViewModelToView() {
            self.vm.$numberOfUsers
                .receive(on: DispatchQueue.main)
                .sink { [weak self] num in
                    guard let `self` = self else { return }
                    
                    self.infoLabel.attributedText = self.setAttributedText(numberOfUsers: num)
                }
                .store(in: &bindings)
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
                
                self.loadingVC.removeViewController()
                self.navigationController?.pushViewController(loginVC, animated: false)
                self.navigationController?.pushViewController(myPageVC, animated: true)
            }
            
        } else {
            UPlusLogger.logger.info("User is not logged in.")
            self.loadingVC.removeViewController()
            
            let loginVM = LoginViewViewModel()
            let loginVC = LoginViewController(vm: loginVM)
            self.show(loginVC, sender: self)
        }
    }
}

extension OnBoardingViewController2 {
    
    private func setUI() {
        self.view.addSubviews(self.scrollView,
                              self.bottomContainer,
                              self.infoLabel,
                              self.startButton)
        
        self.scrollView.addSubview(self.canvasView)
        self.canvasView.addSubviews(self.onBoardImageView,
                                    self.infoBottomView)
        
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
//            self.onBoardImageView.topAnchor.constraint(equalTo: self.canvasView.topAnchor),
            self.onBoardImageView.leadingAnchor.constraint(equalTo: self.canvasView.leadingAnchor),
            self.onBoardImageView.trailingAnchor.constraint(equalTo: self.canvasView.trailingAnchor),
            
            self.infoBottomView.topAnchor.constraint(equalTo: self.onBoardImageView.bottomAnchor),
            self.infoBottomView.heightAnchor.constraint(equalToConstant: 300),
            self.infoBottomView.leadingAnchor.constraint(equalTo: self.canvasView.leadingAnchor),
            self.infoBottomView.trailingAnchor.constraint(equalTo: self.canvasView.trailingAnchor),
            self.infoBottomView.bottomAnchor.constraint(equalTo: self.canvasView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            self.bottomContainer.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.bottomContainer.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.bottomContainer.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.bottomContainer.heightAnchor.constraint(equalToConstant: 150)
        ])
        
        NSLayoutConstraint.activate([
            self.infoLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.bottomContainer.topAnchor, multiplier: 1),
            self.infoLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.bottomContainer.leadingAnchor, multiplier: 2),
            self.bottomContainer.trailingAnchor.constraint(equalToSystemSpacingAfter: self.infoLabel.trailingAnchor, multiplier: 2),
            self.startButton.topAnchor.constraint(equalToSystemSpacingBelow: self.infoLabel.bottomAnchor, multiplier: 1),
            self.startButton.heightAnchor.constraint(equalToConstant: LoginConstants.buttonHeight),
            self.startButton.leadingAnchor.constraint(equalTo: self.infoLabel.leadingAnchor),
            self.startButton.trailingAnchor.constraint(equalTo: self.infoLabel.trailingAnchor),
            self.startButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

extension OnBoardingViewController2 {
    
    private func setAttributedText(numberOfUsers: Int) -> NSAttributedString {
        let allString = String(format: OnBoardingConstants.membersInfo, numberOfUsers)
        let rangedString = String(format: OnBoardingConstants.numOfMembers, numberOfUsers)
        
        let font: UIFont = .systemFont(ofSize: UPlusFont.body2, weight: .regular)
        
        let attributedString = NSMutableAttributedString(string: allString,
                                                         attributes: [
                                                            .foregroundColor: UPlusColor.gray01,
                                                            .font: font
                                                         ])
        
        if let range = attributedString.string.range(of: rangedString) {
            let nsRange = NSRange(range, in: attributedString.string)
            
            attributedString.addAttributes([
                .foregroundColor: UPlusColor.mint02
            ], range: nsRange)
        }
        
        return attributedString
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
