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
    private let backgroundImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: ImageAsset.backgroundStar)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let greetingsLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = .systemFont(ofSize: UPlusFont.h1, weight: .bold)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: ImageAsset.initialNft)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nftRefelctionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: ImageAsset.reflectionNft)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nftInfoLabel: UILabel = {
        let label = UILabel()
       
        let font: UIFont = .systemFont(ofSize: UPlusFont.body2, weight: .regular)
        
        let attributedString = NSMutableAttributedString(string: SignUpConstants.startDescription,
                                                         attributes: [
            .foregroundColor: UPlusColor.gray02,
            .font: font
        ])
        
        if let range = attributedString.string.range(of: SignUpConstants.worldClass) {
            let nsRange = NSRange(range, in: attributedString.string)
            
            attributedString.addAttributes([
                .foregroundColor: UPlusColor.mint03
            ], range: nsRange)
        }
        
        label.attributedText = attributedString
        
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var startButton: UIButton = {
       let button = UIButton()
        button.backgroundColor = UPlusColor.mint03
        button.clipsToBounds = true
        button.setTitleColor(UPlusColor.gray08, for: .normal)
        button.setTitle(SignUpConstants.startMembership, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: UPlusFont.body1, weight: .bold)
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
        
        self.view.backgroundColor = UPlusColor.gray09
        self.setUI()
        self.setLayout()
        self.setNavigationItem()
        
        self.bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.hidesBackButton = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.startButton.layer.cornerRadius = self.startButton.frame.height / 7
        self.setLayer()
    }
}

//MARK: - Private
extension SignUpCompleteViewController {

    func welcomeDidTap() {
        guard let vcs = self.navigationController?.viewControllers else { return }
        
        for vc in vcs where vc is LoginViewController {
            self.navigationController?.popToViewController(vc, animated: false)
        }
        
        self.delegate?.welcomeButtonDidTap()
    }
}

//MARK: - Configure & Bind
extension SignUpCompleteViewController {
    
    private func bind() {
        func bindViewToViewModel() {
            self.startButton.tapPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    guard let `self` = self else { return }
                    
                    self.welcomeDidTap()
                }
                .store(in: &bindings)
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
            
            /*
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
            */
        }
        
        bindViewToViewModel()
        bindViewModelToView()
    }

}

//MARK: - Set UI & Layout
extension SignUpCompleteViewController {
    
    private func setLayer() {
        let gradient = UIImage.gradientImage(bounds: CGRect(x: 0, y: 0, width: self.greetingsLabel.frame.width, height: self.greetingsLabel.frame.height), colors: [.white, UPlusColor.mint03])
        print("Width: \(self.greetingsLabel.frame.width)")
        greetingsLabel.textColor = UIColor(patternImage: gradient)
    }
    
    private func setUI() {
        self.view.addSubviews(self.backgroundImage,
                              self.greetingsLabel,
                              self.nftImageView,
                              self.nftRefelctionImageView,
                              self.nftInfoLabel,
                              self.startButton)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.backgroundImage.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.backgroundImage.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            self.backgroundImage.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            self.backgroundImage.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            
            self.greetingsLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.view.safeAreaLayoutGuide.topAnchor, multiplier: 4),
            self.greetingsLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
 
            self.nftImageView.topAnchor.constraint(equalToSystemSpacingBelow: self.greetingsLabel.bottomAnchor, multiplier: 3),
            self.nftImageView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.view.leadingAnchor, multiplier: 5),
            self.view.trailingAnchor.constraint(equalToSystemSpacingAfter: self.nftImageView.trailingAnchor, multiplier: 5),
            self.nftImageView.heightAnchor.constraint(equalTo: self.nftImageView.widthAnchor),
//            self.nftImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
//            self.nftImageView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
//            self.nftImageView.heightAnchor.constraint(equalToConstant: 200),
//            self.nftImageView.widthAnchor.constraint(equalToConstant: 200),
            
            self.nftRefelctionImageView.topAnchor.constraint(equalTo: self.nftImageView.bottomAnchor),
            self.nftRefelctionImageView.leadingAnchor.constraint(equalTo: self.nftImageView.leadingAnchor),
            self.nftRefelctionImageView.trailingAnchor.constraint(equalTo: self.nftImageView.trailingAnchor),
            self.nftRefelctionImageView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),

            self.nftInfoLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            
            self.startButton.topAnchor.constraint(equalToSystemSpacingBelow: self.nftInfoLabel.bottomAnchor, multiplier: 3),
            self.startButton.leadingAnchor.constraint(equalToSystemSpacingAfter: self.view.safeAreaLayoutGuide.leadingAnchor, multiplier: 2),
            self.startButton.heightAnchor.constraint(equalToConstant: LoginConstants.buttonHeight),
            self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: self.startButton.trailingAnchor, multiplier: 2),
            self.view.safeAreaLayoutGuide.bottomAnchor.constraint(equalToSystemSpacingBelow: self.startButton.bottomAnchor, multiplier: 3)
        ])
        self.backgroundImage.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
    
    private func setNavigationItem() {
        self.navigationController?.navigationItem.hidesBackButton = true
    }
    
}
