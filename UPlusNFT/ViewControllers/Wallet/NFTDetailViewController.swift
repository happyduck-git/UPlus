//
//  NFTDetailViewController.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/14.
//

import UIKit
import Combine
import Nuke
import Gifu

final class NFTDetailViewController: UIViewController {
    
    enum NftType {
        case nft
        case gift
    }
    
    // MARK: - Dependency
    private let vm: UPlusNft
    private let type: NftType
    
    // MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    // MARK: - UI Elements
    
    private let nftContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UPlusColor.gray06
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let nftImageView: GIFImageView = {
        let gifView = GIFImageView()
        gifView.clipsToBounds = true
        gifView.layer.cornerRadius = 10.0
        gifView.translatesAutoresizingMaskIntoConstraints = false
        return gifView
    }()
    
    private let nftInfoContainer: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let nftType: InsetLabelView = {
        let view = InsetLabelView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let nftTitle: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.font = .systemFont(ofSize: UPlusFont.h1, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let storyTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UPlusColor.gray05
        label.text = "성장 스토리"
        label.font = .systemFont(ofSize: UPlusFont.body1, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let storyLabel: UILabel = {
        let label = UILabel()
        label.textColor = UPlusColor.gray09
        label.numberOfLines = 0
        label.text = "밤낮으로 일하던 서태호는 결국 CEO가 되었다. 미래형 초호화 사옥을 짓는다..."
        label.font = .systemFont(ofSize: UPlusFont.body2, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let traitContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let traitLabel: UILabel = {
        let label = UILabel()
        label.text = WalletConstants.traits
        label.textColor = .black
        label.textAlignment = .center
        label.font = .systemFont(ofSize: UPlusFont.h5, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let titleStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10.0
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let levelTitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = UPlusColor.gray05
        label.text = WalletConstants.level
        label.font = .systemFont(ofSize: UPlusFont.body1, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let ownerTitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = UPlusColor.gray05
        label.text = WalletConstants.owner
        label.font = .systemFont(ofSize: UPlusFont.body1, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10.0
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let levelLabel: UILabel = {
        let label = UILabel()
        label.textColor = UPlusColor.gray09
        label.font = .systemFont(ofSize: UPlusFont.body1, weight: .bold)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let ownerLabel: UILabel = {
        let label = UILabel()
        label.textColor = UPlusColor.gray09
        label.font = .systemFont(ofSize: UPlusFont.body1, weight: .bold)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let goToVideoGeneratorButton: UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.setImage(UIImage(named: ImageAsset.sparkle), for: .normal)
        button.setTitle(WalletConstants.videoGenerateTitle, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let sendGiftButton: UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.layer.cornerRadius = 10.0
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.setTitle(GiftConstants.sendGift, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Init
    init(vm: UPlusNft, type: NftType) {
        self.vm = vm
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UPlusColor.grayBackground
        
        self.setUI()
        self.setBaseLayout()
        
        switch type {
        case .nft:
            self.setNftTypeLayout()
        case .gift:
            self.setRaffleTypeLayout()
        }
        
        self.bind()
        self.configure()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationItem.title = "NFT 자랑하기"
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.goToVideoGeneratorButton.layer.cornerRadius = self.goToVideoGeneratorButton.frame.height / 2
    }
    
}

extension NFTDetailViewController {
    
    private func bind() {
        self.goToVideoGeneratorButton.tapPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let `self` = self else { return }
                self.goToVideoGeneratorButtonDidTap()
            }
            .store(in: &bindings)
        
        self.sendGiftButton.tapPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let `self` = self else { return }
                
                let vm = GiftViewControllerViewViewModel(nft: self.vm)
                let vc = GiftViewController(vm: vm)
                
                self.show(vc, sender: self)
            }
            .store(in: &bindings)
    }
    
    private func configure() {
        Task {
            do {
                if let url = URL(string: vm.nftContentImageUrl) {
                    self.nftImageView.animate(withGIFURL: url)
                    self.nftImageView.prepareForAnimation(withGIFURL: url)
                }
                
                let user = try UPlusUser.getCurrentUser()
                self.ownerLabel.text = WalletConstants.owner + " " + user.userNickname
            }
            catch {
                print("Error fetching nft image -- \(error)")
            }
            
            self.nftTitle.text = vm.nftName ?? vm.nftType
            self.nftType.setNameTitle(text: vm.nftType)
            let level = NftLevel.level(tokenId: vm.nftTokenId)
            if Range(0...5).contains(level) {
                self.levelLabel.text = MissionConstants.levelPrefix + String(describing: level)
            }
            self.storyLabel.text = vm.nftDescription ?? nil
        }
    }
}

extension NFTDetailViewController {
    private func goToVideoGeneratorButtonDidTap() {
        let vc = GenerateLottieViewController(vm: self.vm)
        self.show(vc, sender: self)
    }
}

extension NFTDetailViewController {
    private func setUI() {
        self.view.addSubviews(self.nftContainer,
                              self.nftImageView,
                              self.nftInfoContainer,
                              self.traitContainer)
        
        self.nftInfoContainer.addSubviews(self.nftType,
                                          self.nftTitle,
                                          self.storyTitleLabel,
                                          self.storyLabel)
        
        self.traitContainer.addSubviews(self.traitLabel,
                                        self.titleStack,
                                        self.contentStack,
                                        self.goToVideoGeneratorButton,
                                        self.sendGiftButton)
        
        self.titleStack.addArrangedSubviews(self.levelTitleLabel,
                                            self.ownerTitleLabel)
        
        self.contentStack.addArrangedSubviews(self.levelLabel,
                                              self.ownerLabel)
        
    }
    
    private func setBaseLayout() {
        NSLayoutConstraint.activate([
            self.nftContainer.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.nftContainer.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            self.nftContainer.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            self.nftContainer.bottomAnchor.constraint(equalTo: self.nftInfoContainer.topAnchor),
            
            self.nftImageView.topAnchor.constraint(equalToSystemSpacingBelow: self.view.safeAreaLayoutGuide.topAnchor, multiplier: 3),
            self.nftImageView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.view.safeAreaLayoutGuide.leadingAnchor, multiplier: 8),
            self.view.trailingAnchor.constraint(equalToSystemSpacingAfter: self.nftImageView.trailingAnchor, multiplier: 8),
            self.nftImageView.heightAnchor.constraint(equalTo: self.nftImageView.widthAnchor),
            
            self.nftInfoContainer.topAnchor.constraint(equalToSystemSpacingBelow: self.nftImageView.bottomAnchor, multiplier: 3),
            self.nftInfoContainer.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            self.nftInfoContainer.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            
            self.traitContainer.topAnchor.constraint(equalToSystemSpacingBelow: self.nftInfoContainer.bottomAnchor, multiplier: 1),
            self.traitContainer.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            self.traitContainer.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            self.traitContainer.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            self.nftType.topAnchor.constraint(equalToSystemSpacingBelow: self.nftInfoContainer.topAnchor, multiplier: 2),
            self.nftType.leadingAnchor.constraint(equalToSystemSpacingAfter: self.nftInfoContainer.leadingAnchor, multiplier: 2),
            self.nftType.heightAnchor.constraint(equalToConstant: 30),
            
            self.nftTitle.topAnchor.constraint(equalToSystemSpacingBelow: self.nftType.bottomAnchor, multiplier: 1),
            self.nftTitle.leadingAnchor.constraint(equalTo: self.nftType.leadingAnchor),
            
            self.storyTitleLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.nftTitle.bottomAnchor, multiplier: 3),
            self.storyTitleLabel.leadingAnchor.constraint(equalTo: self.nftType.leadingAnchor),
            
            self.storyLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.storyTitleLabel.bottomAnchor, multiplier: 1),
            self.storyLabel.leadingAnchor.constraint(equalTo: self.nftType.leadingAnchor),
            self.nftInfoContainer.trailingAnchor.constraint(equalToSystemSpacingAfter: self.storyLabel.trailingAnchor, multiplier: 2),
            self.nftInfoContainer.bottomAnchor.constraint(equalToSystemSpacingBelow: self.storyLabel.bottomAnchor, multiplier: 2)
        ])
        
        NSLayoutConstraint.activate([
            self.traitLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.traitContainer.topAnchor, multiplier: 2),
            self.traitLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.traitContainer.leadingAnchor, multiplier: 2),
            self.titleStack.topAnchor.constraint(equalToSystemSpacingBelow: self.traitLabel.bottomAnchor, multiplier: 1),
            self.titleStack.leadingAnchor.constraint(equalTo: self.traitLabel.leadingAnchor),
            self.contentStack.topAnchor.constraint(equalTo: self.titleStack.topAnchor),
            self.traitContainer.trailingAnchor.constraint(equalToSystemSpacingAfter: self.contentStack.trailingAnchor, multiplier: 2),
            self.contentStack.bottomAnchor.constraint(equalTo: self.titleStack.bottomAnchor),
            
            
        ])
        nftInfoContainer.setContentHuggingPriority(.defaultHigh, for: .vertical)
        traitLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        titleStack.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
    
    private func setNftTypeLayout() {
        self.sendGiftButton.isHidden = true
        
        NSLayoutConstraint.activate([
            self.nftInfoContainer.heightAnchor.constraint(equalToConstant: self.view.frame.height / 4),
            
            self.goToVideoGeneratorButton.topAnchor.constraint(equalToSystemSpacingBelow: self.titleStack.bottomAnchor, multiplier: 4),
            self.goToVideoGeneratorButton.leadingAnchor.constraint(equalToSystemSpacingAfter: self.traitContainer.leadingAnchor, multiplier: 6),
            self.traitContainer.trailingAnchor.constraint(equalToSystemSpacingAfter: self.goToVideoGeneratorButton.trailingAnchor, multiplier: 6),
            self.traitContainer.bottomAnchor.constraint(equalToSystemSpacingBelow: self.goToVideoGeneratorButton.bottomAnchor, multiplier: 3)
        ])
    }
    
    private func setRaffleTypeLayout() {
        self.storyTitleLabel.isHidden = true
        self.storyLabel.isHidden = true
        self.goToVideoGeneratorButton.isHidden = true
        
        NSLayoutConstraint.activate([
            self.nftInfoContainer.heightAnchor.constraint(equalToConstant: self.view.frame.height / 5),
            
            self.sendGiftButton.topAnchor.constraint(equalToSystemSpacingBelow: self.titleStack.bottomAnchor, multiplier: 6),
            self.sendGiftButton.leadingAnchor.constraint(equalToSystemSpacingAfter: self.traitContainer.leadingAnchor, multiplier: 2),
            self.traitContainer.trailingAnchor.constraint(equalToSystemSpacingAfter: self.sendGiftButton.trailingAnchor, multiplier: 2),
            self.traitContainer.bottomAnchor.constraint(equalToSystemSpacingBelow: self.sendGiftButton.bottomAnchor, multiplier: 3)
        ])
    }
}
