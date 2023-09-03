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

final class NewNFTNoticeBottomSheetViewController: HumpyBottomSheetViewController {
    
    private let logger = Logger()
    
    //MARK: - Delegate
    weak var delegate: NftBottomSheetDelegate?
    
    // MARK: - Dependency
    private let vm: NewNFTNoticeBottomSheetViewViewModel
    
    // MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    // MARK: - UI Elements
    private let missionCompleteLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .black
        label.textAlignment = .center
        label.font = .systemFont(ofSize: UPlusFont.h2, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Init
    init(vm: NewNFTNoticeBottomSheetViewViewModel) {
        self.vm = vm
        super.init(defaultHeight: 350)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
     
        self.confirmButton.setTitle(MissionConstants.redeemNft, for: .normal)
        
        self.setUI()
        self.setLayout()
        
        self.configure()
        self.bind()
    }
    
}

extension NewNFTNoticeBottomSheetViewController {
    
    private func configure() {
        let tokenId: Int64 = Int64(self.vm.tokenId) ?? 0
        var nftName: String = NftLevel.name(tokenId: tokenId)
        self.levelLabel.text = nftName
        self.missionCompleteLabel.text = MyPageConstants.missionCompleteMsg
        self.topImageView.image = UIImage(named: NftLevel.image(tokenId: tokenId))
        
    }
    
    private func bind() {
        
        func bindViewToViewModel() {
        
            self.confirmButton.tapPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    guard let `self` = self else { return }
                    
                    self.dismissView {
                        self.delegate?.redeemButtonDidTap()
                    }
                    
                }
                .store(in: &bindings)
            
        }
        
        func bindViewModelToView() {
            
        }
        
        bindViewToViewModel()
        bindViewModelToView()
    }
}

extension NewNFTNoticeBottomSheetViewController {
    private func setUI() {
        self.middleContainer.addSubviews(self.missionCompleteLabel)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.missionCompleteLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.middleContainer.topAnchor, multiplier: 2),
            self.missionCompleteLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.middleContainer.leadingAnchor, multiplier: 2),
            self.middleContainer.trailingAnchor.constraint(equalToSystemSpacingAfter: self.missionCompleteLabel.trailingAnchor, multiplier: 2),
            self.middleContainer.bottomAnchor.constraint(equalToSystemSpacingBelow: self.missionCompleteLabel.bottomAnchor, multiplier: 2)
        ])
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
