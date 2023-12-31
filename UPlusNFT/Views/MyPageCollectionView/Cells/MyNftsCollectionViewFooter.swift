//
//  MyPageCollectionViewFooter.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/07/22.
//

import UIKit
import Combine

protocol MyNftsCollectionViewFooterDelegate: AnyObject {
    func rewardsButtomDidTap()
}

final class MyNftsCollectionViewFooter: UICollectionViewCell {
    
    // MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    // MARK: - Delegate
    weak var delegate: MyNftsCollectionViewFooterDelegate?
    
    // MARK: - UI Elements
    private let button: UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
//        button.setImage(UIImage(named: "arrow-head-right"), for: .normal)
//        button.semanticContentAttribute = .forceRightToLeft
        button.backgroundColor = .systemGray5
        button.setTitleColor(.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let buttonTitleLabel: UILabel = {
       let label = UILabel()
        label.text = MyPageConstants.ownedRewards
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.backgroundColor = .white
        self.setUI()
        self.bind()

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension MyNftsCollectionViewFooter {
    
    func configure(with vm: MyPageViewViewModel) {
        self.button.setTitle(String(describing: vm.user.userRewards?.count ?? 0) + WalletConstants.rewardsUnit, for: .normal)
    }

    private func bind() {
        
        self.bindings.forEach { $0.cancel() }
        self.bindings.removeAll()
        
        self.button.tapPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let `self` = self else { return }
                self.delegate?.rewardsButtomDidTap()
            }
            .store(in: &bindings)
    }
    
}

extension MyNftsCollectionViewFooter {
    private func setUI() {
        self.contentView.addSubview(self.button)
        self.button.addSubviews(buttonTitleLabel)
        
        NSLayoutConstraint.activate([
            
            self.button.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 2),
            self.button.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 3),
            self.button.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.button.bottomAnchor, multiplier: 2),
            
            self.buttonTitleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.button.leadingAnchor, multiplier: 1),
            self.button.titleLabel!.trailingAnchor.constraint(equalToSystemSpacingAfter: self.buttonTitleLabel.trailingAnchor, multiplier: 1),
            self.buttonTitleLabel.topAnchor.constraint(equalTo: self.button.titleLabel!.topAnchor),
            self.buttonTitleLabel.bottomAnchor.constraint(equalTo: self.button.titleLabel!.bottomAnchor)
        ])
        
        self.button.layer.cornerRadius = 5
    }
}
