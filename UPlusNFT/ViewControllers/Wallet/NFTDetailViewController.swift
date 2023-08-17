//
//  NFTDetailViewController.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/14.
//

import UIKit
import Combine
import Nuke

final class NFTDetailViewController: UIViewController {

    // MARK: - Dependency
    private let vm: UPlusNft
    
    // MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    // MARK: - UI Elements
    private let nftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nftType: UILabel = {
        let label = UILabel()
        label.textColor = UPlusColor.gray05
         label.textAlignment = .center
         label.translatesAutoresizingMaskIntoConstraints = false
         return label
     }()
    
    private let nftTitle: UILabel = {
       let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let traitLabel: UILabel = {
       let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let levelLabel: UILabel = {
        let label = UILabel()
         label.textColor = .black
         label.textAlignment = .center
         label.translatesAutoresizingMaskIntoConstraints = false
         return label
    }()
    
    private let ownerLabel: UILabel = {
        let label = UILabel()
         label.textColor = .black
         label.textAlignment = .center
         label.translatesAutoresizingMaskIntoConstraints = false
         return label
    }()
    
    private let goToVideoGeneratorButton: UIButton = {
       let button = UIButton()
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.setTitle(WalletConstants.videoGenerateTitle, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Init
    init(vm: UPlusNft) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white
        self.setUI()
        self.setLayout()
        self.bind()
        self.configure()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationItem.title = "NFT 자랑하기"
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
    }
    
    private func configure() {
        Task {
            do {
                if let url = URL(string: vm.nftContentImageUrl) {
                    self.nftImageView.image = try await ImagePipeline.shared.image(for: url)
                }
                
                let user = try UPlusUser.getCurrentUser()
                self.ownerLabel.text = WalletConstants.owner + " " + user.userNickname
            }
            catch {
                print("Error fetching nft image -- \(error)")
            }
            
            self.nftTitle.text = vm.nftDetailType
            self.nftType.text = vm.nftType
            let level = NftLevel.level(tokenId: vm.nftTokenId)
            if Range(0...5).contains(level) {
                self.levelLabel.text = MissionConstants.levelPrefix + String(describing: level)
            }
        }
    }
}

extension NFTDetailViewController {
    private func goToVideoGeneratorButtonDidTap() {
        let vc = GenerateLottieViewController(vm: self.vm)
        
        // TODO: Show
        self.show(vc, sender: self)
    }
}

extension NFTDetailViewController {
    private func setUI() {
        self.view.addSubviews(self.nftImageView,
                              self.nftType,
                              self.nftTitle,
                              self.traitLabel,
                              self.levelLabel,
                              self.ownerLabel,
                              self.goToVideoGeneratorButton)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.nftImageView.topAnchor.constraint(equalToSystemSpacingBelow: self.view.safeAreaLayoutGuide.topAnchor, multiplier: 2),
            self.nftImageView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.view.safeAreaLayoutGuide.leadingAnchor, multiplier: 5),
            self.view.trailingAnchor.constraint(equalToSystemSpacingAfter: self.nftImageView.trailingAnchor, multiplier: 5),
            self.nftImageView.heightAnchor.constraint(equalTo: self.nftImageView.widthAnchor),
            
            self.nftType.topAnchor.constraint(equalToSystemSpacingBelow: self.nftImageView.bottomAnchor, multiplier: 3),
            self.nftType.leadingAnchor.constraint(equalToSystemSpacingAfter: self.view.leadingAnchor, multiplier: 2),
            self.nftTitle.topAnchor.constraint(equalToSystemSpacingBelow: self.nftType.bottomAnchor, multiplier: 1),
            self.nftTitle.leadingAnchor.constraint(equalTo: self.nftType.leadingAnchor),
            
            self.traitLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.nftTitle.bottomAnchor, multiplier: 3),
            self.traitLabel.leadingAnchor.constraint(equalTo: self.nftType.leadingAnchor),
            
            self.levelLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.traitLabel.bottomAnchor, multiplier: 2),
            self.levelLabel.leadingAnchor.constraint(equalTo: self.traitLabel.leadingAnchor),
            
            self.ownerLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.levelLabel.bottomAnchor, multiplier: 2),
            self.ownerLabel.leadingAnchor.constraint(equalTo: self.traitLabel.leadingAnchor),
            
            self.goToVideoGeneratorButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.view.bottomAnchor.constraint(equalToSystemSpacingBelow: self.goToVideoGeneratorButton.bottomAnchor, multiplier: 2)
            
        ])
    }
}
