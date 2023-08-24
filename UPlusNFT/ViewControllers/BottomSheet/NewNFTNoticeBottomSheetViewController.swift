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

protocol NewNFTNoticeBottomSheetDelegate: AnyObject {
    func redeemButtonDidTap()
}

final class NewNFTNoticeBottomSheetViewController: BottomSheetViewController {
    
    private let logger = Logger()
    
    //MARK: - Delegate
    weak var delegate: NewNFTNoticeBottomSheetDelegate?
    
    // MARK: - Dependency
    private let vm: NewNFTNoticeBottomSheetViewViewModel
    
    // MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    // MARK: - UI Elements
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = MissionConstants.congrats
        label.textColor = .black
        label.textAlignment = .center
        label.font = .systemFont(ofSize: UPlusFont.h2, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nftTypeBackground: UIImageView = {
       let imageView = UIImageView()
        imageView.image = UIImage(named: ImageAsset.titleBackground)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nftTypeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: UPlusFont.body2, weight: .regular)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nftImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let missionType: UILabel = {
        let label = UILabel()
        label.textColor = UPlusColor.gray09
        label.textAlignment = .center
        label.font = .systemFont(ofSize: UPlusFont.h1, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let redeemButton: UIButton = {
        let button = UIButton()
        button.setTitle(MissionConstants.redeemNft, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.clipsToBounds = true
        button.layer.cornerRadius = 10.0
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Init
    init(vm: NewNFTNoticeBottomSheetViewViewModel) {
        self.vm = vm
        super.init()
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
        
            self.redeemButton.tapPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    guard let `self` = self else { return }
                    
                    self.dismissView()
                    self.delegate?.redeemButtonDidTap()
                }
                .store(in: &bindings)
            
        }
        
        func bindViewModelToView() {
            self.vm.nft
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    guard let `self` = self,
                          let nft = $0
                    else { return }
                    
                    self.nftTypeLabel.text = nft.nftType
                    self.missionType.text = nft.nftDetailType
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
        self.containerView.addSubviews(self.titleLabel,
                                       self.nftTypeBackground,
                                       self.nftTypeLabel,
                                       self.nftImage,
                                       self.missionType,
                                       self.redeemButton)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.titleLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.containerView.topAnchor, multiplier: 5),
            self.titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.containerView.leadingAnchor, multiplier: 2),
            self.containerView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.titleLabel.trailingAnchor, multiplier: 2),
            
            self.nftTypeBackground.topAnchor.constraint(equalToSystemSpacingBelow: self.titleLabel.bottomAnchor, multiplier: 5),
            self.nftTypeBackground.widthAnchor.constraint(equalToConstant: self.view.frame.width / 2),
            self.nftTypeBackground.heightAnchor.constraint(equalToConstant: 50.0),
            self.nftTypeBackground.centerXAnchor.constraint(equalTo: self.containerView.centerXAnchor),
 
            self.nftTypeLabel.leadingAnchor.constraint(equalTo: self.nftTypeBackground.leadingAnchor),
            self.nftTypeLabel.trailingAnchor.constraint(equalTo: self.nftTypeBackground.trailingAnchor),
            self.nftTypeLabel.centerYAnchor.constraint(equalTo: self.nftTypeBackground.centerYAnchor),
            
            self.nftImage.topAnchor.constraint(equalToSystemSpacingBelow: self.nftTypeBackground.bottomAnchor, multiplier: 3),
            self.nftImage.widthAnchor.constraint(equalTo: self.nftTypeBackground.widthAnchor),
            self.nftImage.heightAnchor.constraint(equalTo: self.nftImage.heightAnchor),
            self.nftImage.centerXAnchor.constraint(equalTo: self.containerView.centerXAnchor),
            
            self.missionType.topAnchor.constraint(equalToSystemSpacingBelow: self.nftImage.bottomAnchor, multiplier: 2),
            self.missionType.leadingAnchor.constraint(equalToSystemSpacingAfter: self.containerView.leadingAnchor, multiplier: 2),
            self.containerView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.missionType.trailingAnchor, multiplier: 2),
            
            self.redeemButton.topAnchor.constraint(equalToSystemSpacingBelow: self.missionType.bottomAnchor, multiplier: 3),
            self.redeemButton.leadingAnchor.constraint(equalToSystemSpacingAfter: self.containerView.leadingAnchor, multiplier: 2),
            self.containerView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.redeemButton.trailingAnchor, multiplier: 2),
            self.containerView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.redeemButton.bottomAnchor, multiplier: 5)
        ])
        
        self.redeemButton.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct NewNFTNoticeBottomSheetViewController_Preview: PreviewProvider {
    static var previews: some View {
        let vm = NewNFTNoticeBottomSheetViewViewModel(tokenId: "2000006")
        NewNFTNoticeBottomSheetViewController(vm: vm).toPreview()
    }
}
#endif
