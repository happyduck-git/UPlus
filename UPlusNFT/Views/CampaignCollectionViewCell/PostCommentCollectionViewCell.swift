//
//  PostCommentCollectionViewCell.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/07/04.
//

import UIKit
import Combine
import Nuke
import FirebaseStorage

final class PostCommentCollectionViewCell: UICollectionViewCell {
    
    private var bindings = Set<AnyCancellable>()

    private(set) var type: CommentCellType = .normal
    
    // MARK: - UI Elements
    private let bestLabel:  UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.text = "Best"
        label.textColor = .systemPink
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.circle.fill")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nicknameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .bold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let commentTexts: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let commentImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let likeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "heart"), for: .normal) //heart.fill
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
    
    private let createdAtLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
        setLayout()
        
        contentView.backgroundColor = .systemGray5
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Set UI & Layout
    private func setUI() {
        contentView.addSubviews(
            bestLabel,
            profileImageView,
            nicknameLabel,
            commentTexts,
            commentImage,
            likeButton,
            commentButton,
            createdAtLabel
        )
    }
    
    private func setLayout() {
        let viewWidth = self.contentView.frame.width
        
        NSLayoutConstraint.activate([
            self.bestLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 1),
            self.bestLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 2),
            
            self.profileImageView.topAnchor.constraint(equalToSystemSpacingBelow: self.bestLabel.bottomAnchor, multiplier: 1),
            self.profileImageView.leadingAnchor.constraint(equalTo: self.bestLabel.leadingAnchor),
            self.profileImageView.widthAnchor.constraint(equalToConstant: viewWidth / 16),
            self.profileImageView.heightAnchor.constraint(equalTo: self.profileImageView.widthAnchor),
            
            self.nicknameLabel.centerYAnchor.constraint(equalTo: self.profileImageView.centerYAnchor),
            self.nicknameLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.profileImageView.trailingAnchor, multiplier: 1),
            
            self.commentTexts.topAnchor.constraint(equalToSystemSpacingBelow: self.profileImageView.bottomAnchor, multiplier: 1),
            self.commentTexts.leadingAnchor.constraint(equalTo: self.bestLabel.leadingAnchor),
            
            self.commentImage.topAnchor.constraint(equalToSystemSpacingBelow: self.commentTexts.bottomAnchor, multiplier: 1),
            self.commentImage.leadingAnchor.constraint(equalTo: self.commentTexts.leadingAnchor),
            
            self.likeButton.leadingAnchor.constraint(equalTo: self.commentImage.leadingAnchor),
            self.likeButton.topAnchor.constraint(equalToSystemSpacingBelow: self.commentImage.bottomAnchor, multiplier: 1),
            self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.likeButton.bottomAnchor, multiplier: 2),
            
            self.commentButton.topAnchor.constraint(equalTo: self.likeButton.topAnchor),
            self.commentButton.leadingAnchor.constraint(equalToSystemSpacingAfter: self.likeButton.trailingAnchor, multiplier: 1),
            self.commentButton.bottomAnchor.constraint(equalTo: self.likeButton.bottomAnchor),
            
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.createdAtLabel.trailingAnchor, multiplier: 2),
            self.createdAtLabel.bottomAnchor.constraint(equalTo: self.likeButton.bottomAnchor)
        ])
        self.commentTexts.setContentHuggingPriority(.defaultLow, for: .vertical)
    }
    
    // MARK: - Internal
    func configure(with vm: CommentTableViewCellModel) {
        
        switch vm.type {
        case .best:
            self.bestLabel.isHidden = false
        case .normal:
            self.bestLabel.isHidden = true
        }
        
        self.commentTexts.text = vm.comment
        self.likeButton.setTitle(String(describing: vm.likeUserCount ?? 0), for: .normal)
        // TODO: Recomment 개수 필요
        self.commentButton.setTitle(String(describing: vm.recomments?.count ?? 0), for: .normal)
        self.createdAtLabel.text = String(describing: vm.createdAt.dateValue().monthDayTimeFormat)
        
        Task {
            guard let image = vm.imagePath,
                  let url = URL(string: image)
            else { return }
            
            self.commentImage.image = try await ImagePipeline.shared.image(for: url)
        }
        
        bind(with: vm)
    }
    
    func bind(with vm: CommentTableViewCellModel) {
        
        vm.$user
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                guard let `self` = self,
                      let user = user
                else { return }
                
                self.nicknameLabel.text = user.nickname
                
                Task {
                    do {
                        guard let imagePath = user.profileImagePath,
                              let url = URL(string: imagePath)
                        else { return }
                        self.profileImageView.image = try await self.urlToImage(url)
                    }
                    catch {
                        print("Error converting profile image - \(error.localizedDescription)")
                    }
                }
            }
            .store(in: &bindings)
        
    }
    
    private func urlToImage(_ url: URL) async throws -> UIImage? {
        var imgUrl: URL = url
        
        if !url.absoluteString.hasPrefix("http") {
            imgUrl = try await Storage.storage().reference(withPath: url.absoluteString).downloadURL()
        }
        return try await ImagePipeline.shared.image(for: imgUrl)
    }
    
    func resetCell() {
        self.contentView.backgroundColor = .white
        self.profileImageView.image = nil
        self.nicknameLabel.text = nil
        self.commentTexts.text = nil
        self.createdAtLabel.text = nil
    }
    
    func changeCellType(to celltype: CommentCellType) {
        self.type = celltype
    }
}
