//
//  PostTableViewCell.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/06/26.
//

import UIKit
import Combine

protocol PostTableViewCellProtocol: AnyObject {
    func likeButtonDidTap(vm: PostTableViewCellModel)
}

final class PostTableViewCell: UITableViewCell {
    
    private var vm: PostTableViewCellModel?
    
    // MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    // MARK: - Delegate
    weak var delegate: PostTableViewCellProtocol?
    
    // MARK: - UI Elements
    private let title: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingMiddle
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let likeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let commentButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "text.bubble"), for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setUI()
        setLayout()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Set UI & Layout
extension PostTableViewCell {
    
    private func setUI() {
        contentView.addSubviews(
            title,
            likeButton,
            commentButton
        )
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.title.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 2),
            self.title.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 2),
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.title.trailingAnchor, multiplier: 2),
            
            self.likeButton.leadingAnchor.constraint(equalTo: self.title.leadingAnchor),
            self.likeButton.topAnchor.constraint(equalToSystemSpacingBelow: self.title.bottomAnchor, multiplier: 1),
            self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.likeButton.bottomAnchor, multiplier: 2),
            
            self.commentButton.topAnchor.constraint(equalTo: self.likeButton.topAnchor),
            self.commentButton.leadingAnchor.constraint(equalToSystemSpacingAfter: self.likeButton.trailingAnchor, multiplier: 1),
            self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.commentButton.bottomAnchor, multiplier: 2),
        ])
        self.title.setContentHuggingPriority(.defaultLow, for: .vertical)
    }
}

// MARK: - Configure and Bind Cell with View Model
extension PostTableViewCell {

    func configure(with vm: PostTableViewCellModel) {
        self.vm = vm
        
        self.title.text = vm.postTitle
        self.likeButton.setTitle(String(describing: vm.likeUserCount), for: .normal)
        self.commentButton.setTitle(String(describing: vm.commentCount), for: .normal)
        
        let likeImage: String = vm.isLiked ? "heart.fill" : "heart"
        self.likeButton.setImage(UIImage(systemName: likeImage), for: .normal)
    }
    
    private func bind() {
        likeButton.tapPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let `self` = self,
                    let cellVM = self.vm else { return }
//                self.delegate?.likeButtonDidTap(vm: cellVM)
                cellVM.isLiked = !cellVM.isLiked
                let likeImage: String = cellVM.isLiked ? "heart.fill" : "heart"
                let updateLikeCount: Int = cellVM.isLiked ? 1 : -1
                cellVM.likeUserCount += updateLikeCount
                
                self.delegate?.likeButtonDidTap(vm: cellVM)
                
                self.likeButton.setImage(UIImage(systemName: likeImage), for: .normal)
                self.likeButton.setTitle(String(cellVM.likeUserCount), for: .normal)
            }
            .store(in: &bindings)
    }
    
    func resetCell() {
        self.title.text = nil
        self.likeButton.setTitle(nil, for: .normal)
        self.commentButton.setTitle(nil, for: .normal)
        self.likeButton.setImage(nil, for: .normal)
    }
}

