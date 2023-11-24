//
//  MyNftsCollectionViewCell.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/21.
//

import UIKit
import Nuke

final class MyNftsCollectionViewCell: UICollectionViewCell {
    
    private let nftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UPlusColor.pointCirclePink
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let goToMissionButton: UIButton = {
        let button = UIButton()
        button.setTitle(MyPageConstants.goToMission, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UPlusColor.pointGagePink
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.backgroundColor = .systemBlue
        self.contentView.clipsToBounds = true
        self.setUI()
        self.setLayout()
        
        self.contentView.backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension MyNftsCollectionViewCell {
    func configure(with vm: MyPageViewViewModel, at item: Int) {
        Task {
            do {
                guard let url = URL(string: String(describing: vm.user.userNfts?[item].documentID) ) else { return }
                self.nftImageView.image = try await ImagePipeline.shared.image(for: url)
            }
            catch {
              print("Error fetching nft image at Item#\(item) -- \(error)")
            }
        }
    }
}


extension MyNftsCollectionViewCell {
    private func setUI() {
        self.contentView.addSubviews(nftImageView,
                                     goToMissionButton)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.nftImageView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.nftImageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.nftImageView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.nftImageView.heightAnchor.constraint(equalToConstant: self.contentView.frame.height * (3/4)),
            
            self.goToMissionButton.topAnchor.constraint(equalToSystemSpacingBelow: self.nftImageView.bottomAnchor, multiplier: 2),
            self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.goToMissionButton.bottomAnchor, multiplier: 2),
            self.goToMissionButton.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 2),
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.goToMissionButton.trailingAnchor, multiplier: 2)
        ])
        self.goToMissionButton.layer.cornerRadius = 8
    }

}
