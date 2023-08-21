//
//  SignUpCompleteViewController.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/18.
//

import UIKit
import FirebaseAuth
import Combine
import Nuke

protocol SignUpCompleteViewControllerDelegate: AnyObject {
    func welcomeButtonDidTap()
}

final class SignUpCompleteViewController: UIViewController {

    //MARK: - Dependency
    private let vm: SignUpCompleteViewViewModel
    
    //MARK: - Delegate
    weak var delegate: SignUpCompleteViewControllerDelegate?
    
    // MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    //MARK: - UI Elements
    private let greetingsLabel: UILabel = {
       let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.font = .systemFont(ofSize: UPlusFont.h2, weight: .heavy)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let nftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .systemGray2
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nftInfoLabel: UILabel = {
       let label = UILabel()
        label.textColor = .darkGray
        label.text = SignUpConstants.nftInfo
        label.font = .systemFont(ofSize: UPlusFont.body2, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var startButton: UIButton = {
       let button = UIButton()
        button.backgroundColor = UPlusColor.mint03
        button.clipsToBounds = true
        button.setTitleColor(.white, for: .normal)
        button.setTitle(SignUpConstants.redeemGift, for: .normal)
        button.addTarget(self, action: #selector(welcomeDidTap), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    //MARK: - Init
    init(vm: SignUpCompleteViewViewModel) {
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
        self.setNavigationItem()
        
        self.bind()
    }

}

//MARK: - Private
extension SignUpCompleteViewController {
    @objc func cancelBtnDidTap() {
        self.navigationController?.popViewController(animated: true)
        
        do {
            let user = try UPlusUser.getCurrentUser()

            let vm = MyPageViewViewModel(user: user,
                                         memberShip: (true, user.userHasVipNft))
            let vc = MyPageViewController(vm: vm)
            
            self.navigationController?.modalPresentationStyle = .fullScreen
            self.show(vc, sender: self)
            
        }
        catch {
            print("Error fetching current user -- \(error)")
        }
        
    }
    
    @objc func welcomeDidTap() {
        guard let vcs = self.navigationController?.viewControllers else { return }
        
        for vc in vcs where vc is LoginViewController {
            self.navigationController?.popToViewController(vc, animated: false)
        }
        
        self.delegate?.welcomeButtonDidTap()
    }
}

//MARK: - Set UI & Layout
extension SignUpCompleteViewController {
    
    private func setUI() {
        self.view.addSubviews(self.greetingsLabel,
                              self.nftImageView,
                              self.nftInfoLabel,
                              self.startButton)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.greetingsLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.view.safeAreaLayoutGuide.topAnchor, multiplier: 4),
            self.greetingsLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
 
            self.nftImageView.topAnchor.constraint(equalToSystemSpacingBelow: self.greetingsLabel.bottomAnchor, multiplier: 3),
            self.nftImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.nftImageView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            self.nftImageView.heightAnchor.constraint(equalToConstant: 200),
            self.nftImageView.widthAnchor.constraint(equalToConstant: 200),
            
            self.nftInfoLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.nftImageView.bottomAnchor, multiplier: 4),
            self.nftInfoLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            
            self.startButton.topAnchor.constraint(equalToSystemSpacingBelow: self.nftInfoLabel.bottomAnchor, multiplier: 2),
            self.startButton.leadingAnchor.constraint(equalToSystemSpacingAfter: self.view.safeAreaLayoutGuide.leadingAnchor, multiplier: 2),
            self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: self.startButton.trailingAnchor, multiplier: 2),
            self.view.safeAreaLayoutGuide.bottomAnchor.constraint(equalToSystemSpacingBelow: self.startButton.bottomAnchor, multiplier: 2)
        ])
        self.startButton.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
    
    private func setNavigationItem() {
        let rightButtonItem = UIBarButtonItem(image: UIImage(named: ImageAsset.xMarkBlack)?.withTintColor(.systemGray2, renderingMode: .alwaysOriginal), style: .done, target: self, action: #selector(welcomeDidTap))
        self.navigationItem.setRightBarButton(rightButtonItem, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.startButton.layer.cornerRadius = self.startButton.frame.height / 7
    }
}

//MARK: - Configure & Bind
extension SignUpCompleteViewController {
    
    private func bind() {
        func bindViewToViewModel() {
            
        }
        func bindViewModelToView() {
            
            self.vm.$nickname
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    guard let `self` = self,
                          let nickname = $0 else { return }
                    self.greetingsLabel.text = nickname + SignUpConstants.greetings
                }
                .store(in: &bindings)
            
            self.vm.$welcomeNftImage
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    guard let `self` = self,
                          let image = $0,
                          let url = URL(string: image) else { return }
                    Task {
                        self.nftImageView.image = try await ImagePipeline.shared.image(for: url)
                    }
                }
                .store(in: &bindings)
        }
        
        bindViewToViewModel()
        bindViewModelToView()
    }

}
