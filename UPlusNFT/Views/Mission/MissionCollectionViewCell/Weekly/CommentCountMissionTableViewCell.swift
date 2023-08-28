//
//  CommentCountMissionTableViewCell.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/21.
//

import UIKit
import Nuke
import Combine

final class CommentCountMissionTableViewCell: UITableViewCell {

    // MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    // MARK: - UI Elements
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8.0
        imageView.backgroundColor = UPlusColor.gray04
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nicknameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UPlusColor.gray05
        label.font = .systemFont(ofSize: UPlusFont.body2, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let commentLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: UPlusFont.body2, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let likeStack: UIStackView = {
       let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8.0
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let likeButton: UIButton = {
        let button = UIButton()
        return button
    }()
    
    private let likeCount: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: UPlusFont.body2, weight: .regular)
        label.textColor = UPlusColor.gray05
        return label
    }()
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.setUI()
        self.setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Bind
extension CommentCountMissionTableViewCell {
    
    func bind(with vm: CommentCountMissionViewViewModel) {
        
        self.bindings.forEach { $0.cancel() }
        self.bindings.removeAll()
        
        func bindViewToViewModel() {
        
            self.likeButton.tapPublisher
                .receive(on: DispatchQueue.main)
                .sink {
                    vm.isLiked.toggle()
                    
                }
                .store(in: &bindings)
        }
        
        func bindViewModelToView() {
            vm.$isLiked
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    guard let `self` = self else { return }
                    
                    let likeImage: UIImage? = $0 ? UIImage(named: ImageAsset.heartFill) : UIImage(named: ImageAsset.heartEmpty)
                    
                    self.likeButton.setImage(likeImage, for: .normal)
                    
                }
                .store(in: &bindings)
        }
        
        bindViewToViewModel()
        bindViewModelToView()
    }
    
}

// MARK: - Configure
extension CommentCountMissionTableViewCell {
    
    func configure(image: String, nickname: String, comment: String, likes: Int) {
        self.nicknameLabel.text = nickname
        self.commentLabel.text = comment
        self.likeCount.text = String(describing: likes)
        
        // TODO: profile image?
        
    }
    
}

// MARK: - Set UI & Layout
extension CommentCountMissionTableViewCell {
    
    private func setUI() {
        self.contentView.addSubviews(self.profileImageView,
                                     self.nicknameLabel,
                                     self.commentLabel,
                                     self.likeStack)
        
        self.likeStack.addArrangedSubviews(self.likeButton,
                                           self.likeCount)
    }
    
    private func setLayout() {
        
        let imageWidth = 30.0
        
        NSLayoutConstraint.activate([
            self.profileImageView.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 1),
            self.profileImageView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 1),

            self.profileImageView.widthAnchor.constraint(equalToConstant: imageWidth),
            self.profileImageView.heightAnchor.constraint(equalToConstant: imageWidth),
            
            self.nicknameLabel.topAnchor.constraint(equalTo: self.profileImageView.topAnchor),
            self.nicknameLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.profileImageView.trailingAnchor, multiplier: 1),
            
            self.commentLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.nicknameLabel.bottomAnchor, multiplier: 1),
            self.commentLabel.leadingAnchor.constraint(equalTo: self.nicknameLabel.leadingAnchor),
            self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.commentLabel.bottomAnchor, multiplier: 1),
            
            self.likeStack.topAnchor.constraint(equalTo: self.nicknameLabel.topAnchor),
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.likeStack.trailingAnchor, multiplier: 2),
            
        ])
    }
    
}
