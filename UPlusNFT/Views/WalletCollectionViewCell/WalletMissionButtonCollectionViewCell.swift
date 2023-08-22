//
//  WalletDetailMissionButtonCollectionViewCell.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/22.
//

import UIKit
import Combine

protocol WalletDetailMissionButtonCollectionViewCellDelegate: AnyObject {
    func goToWeeklyMissionDidTap()
}

final class WalletMissionButtonCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    // MARK: - Delegate
    weak var deleate: WalletDetailMissionButtonCollectionViewCellDelegate?
    
    // MARK: - UI Elements
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: ImageAsset.walletBuilding)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.text = WalletConstants.goToMissionInfo
        label.textColor = UPlusColor.gray06
        label.numberOfLines = 2
        label.textAlignment = .center
        label.font = .systemFont(ofSize: UPlusFont.body2)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let goToMissionButton: UIButton = {
        let button = UIButton()
        button.setTitle(WalletConstants.goToMission, for: .normal)
        button.setTitleColor(UPlusColor.gray08, for: .normal)
        button.backgroundColor = UPlusColor.mint03
        button.clipsToBounds = true
        button.layer.cornerRadius = 8.0
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setUI()
        self.setLayout()
        
        self.bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Bind
extension WalletMissionButtonCollectionViewCell {
    
    private func bind() {
        func bindViewToViewModel() {
            self.goToMissionButton.tapPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    guard let `self` = self else { return }

                    self.deleate?.goToWeeklyMissionDidTap()
                }
                .store(in: &bindings)
        }
        func bindViewModelToView() {
            
        }
        
        bindViewToViewModel()
        bindViewModelToView()
    }
    
}

// MARK: - Set UI & Layout
extension WalletMissionButtonCollectionViewCell {
    
    private func setUI() {
        self.contentView.addSubviews(self.imageView,
                                     self.infoLabel,
                                     self.goToMissionButton)
    }
    
    private func setLayout() {
        
        let imageWidth = 200.0
        
        NSLayoutConstraint.activate([
            self.imageView.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 5),
            self.imageView.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            self.imageView.widthAnchor.constraint(equalToConstant: imageWidth),
            self.imageView.heightAnchor.constraint(equalToConstant: imageWidth),
            
            self.infoLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.imageView.bottomAnchor, multiplier: 5),
            self.infoLabel.leadingAnchor.constraint(equalTo: self.imageView.leadingAnchor),
            self.infoLabel.trailingAnchor.constraint(equalTo: self.imageView.trailingAnchor),
            
            self.goToMissionButton.topAnchor.constraint(equalToSystemSpacingBelow: self.infoLabel.bottomAnchor, multiplier: 3),
            self.goToMissionButton.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 2),
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.goToMissionButton.trailingAnchor, multiplier: 2),
            self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.goToMissionButton.bottomAnchor, multiplier: 2)
        ])
    }
    
}
