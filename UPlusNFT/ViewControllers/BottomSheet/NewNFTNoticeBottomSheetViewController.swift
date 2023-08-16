//
//  NewNFTNoticeBottomSheetViewController.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/16.
//

import UIKit
import Combine
import Nuke
import OSLog

final class NewNFTNoticeBottomSheetViewController: BottomSheetViewController {
    
    private let logger = Logger()
    
    // MARK: - Dependency
    private let vm: NewNFTNoticeBottomSheetViewViewModel
    
    // MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    // MARK: - UI Elements
    private let stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 5.0
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let missionTitle: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: UPlusFont.h2, weight: .bold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nftTitle: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: UPlusFont.h2, weight: .bold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nftImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let pathLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: UPlusFont.caption1, weight: .bold)
        label.textColor = UPlusColor.gray09
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let redeemButton: UIButton = {
        let button = UIButton()
        button.setTitle(MissionConstants.redeemNft, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Init
    init(vm: NewNFTNoticeBottomSheetViewViewModel) {
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
    
}

extension NewNFTNoticeBottomSheetViewController {
    private func bind() {
        func bindViewToViewModel() {
            
        }
        func bindViewModelToView() {
            self.vm.nft
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    guard let `self` = self,
                          let nft = $0
                    else { return }
                    
                    self.missionTitle.text = nft.nftType
                    self.nftTitle.text = String(describing: nft.nftTokenId)
                    self.pathLabel.text = nft.nftDetailType
                    guard let url = URL(string: nft.nftContentImageUrl) else {
                        self.logger.warning("Error converting to url.")
                        return
                    }
                    Task {
                        do {
                            self.nftImage.image = try await ImagePipeline.shared.image(for: url)
                        }
                        catch {
                            
                            self.logger.error("Error fetching image -- \(error).")
                        }
                    }
                    
                }
                .store(in: &bindings)
        }
        
        bindViewToViewModel()
        bindViewModelToView()
    }
}

extension NewNFTNoticeBottomSheetViewController {
    private func setUI() {
        self.stack.addArrangedSubviews(self.missionTitle,
                              self.nftTitle,
                              self.nftImage,
                              self.redeemButton)
        
        self.view.addSubviews(self.stack)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.stack.topAnchor.constraint(equalToSystemSpacingBelow: self.containerView.topAnchor, multiplier: 2),
            self.stack.leadingAnchor.constraint(equalToSystemSpacingAfter: self.containerView.leadingAnchor, multiplier: 3),
            self.containerView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.stack.trailingAnchor, multiplier: 3),
            self.containerView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.stack.bottomAnchor, multiplier: 5)
        ])
    }
}
