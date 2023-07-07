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
    
    // MARK: - Combine
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
    
    private let editButton: UIButton = {
        let button = UIButton()
        button.isHidden = true
        button.setImage(UIImage(systemName: SFSymbol.edit), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let deleteButton: UIButton = {
        let button = UIButton()
        button.isHidden = true
        button.setImage(UIImage(systemName: SFSymbol.delete), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let editTextField: UITextField = {
        let txtField = UITextField()
        txtField.translatesAutoresizingMaskIntoConstraints = false
        return txtField
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
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: SFSymbol.camera)
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
            editButton,
            deleteButton,
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
            
            self.deleteButton.centerYAnchor.constraint(equalTo: self.nicknameLabel.centerYAnchor),
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.deleteButton.trailingAnchor, multiplier: 2),
            self.editButton.centerYAnchor.constraint(equalTo: self.nicknameLabel.centerYAnchor),
            self.deleteButton.leadingAnchor.constraint(equalToSystemSpacingAfter: self.editButton.trailingAnchor, multiplier: 1),
            
            self.commentTexts.topAnchor.constraint(equalToSystemSpacingBelow: self.profileImageView.bottomAnchor, multiplier: 1),
            self.commentTexts.leadingAnchor.constraint(equalTo: self.bestLabel.leadingAnchor),
            
            self.commentImage.topAnchor.constraint(equalTo: self.commentTexts.bottomAnchor),
            self.commentImage.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            self.commentImage.widthAnchor.constraint(equalToConstant: viewWidth / 5),
            
            self.likeButton.topAnchor.constraint(equalToSystemSpacingBelow: self.commentImage.bottomAnchor, multiplier: 1),
            self.likeButton.leadingAnchor.constraint(equalTo: self.commentImage.leadingAnchor),
            self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.likeButton.bottomAnchor, multiplier: 2),
            
            self.commentButton.leadingAnchor.constraint(equalToSystemSpacingAfter: self.likeButton.trailingAnchor, multiplier: 1),
            self.commentButton.bottomAnchor.constraint(equalTo: self.likeButton.bottomAnchor),
            
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.createdAtLabel.trailingAnchor, multiplier: 2),
            self.createdAtLabel.bottomAnchor.constraint(equalTo: self.likeButton.bottomAnchor)
        ])
        self.commentImage.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
    
    // MARK: - Internal
    func configure(with vm: CommentTableViewCellModel) {
        
        switch vm.type {
        case .best:
            self.bestLabel.isHidden = false
        case .normal:
            self.bestLabel.isHidden = true
        }
        
        self.currentUserConfiguration(with: vm)
        self.commentTexts.text = vm.comment
        self.likeButton.setTitle(String(describing: vm.likeUserCount ?? 0), for: .normal)
        self.commentButton.setTitle(String(describing: vm.recomments?.count ?? 0), for: .normal)
        self.createdAtLabel.text = String(describing: vm.createdAt.dateValue().monthDayTimeFormat)
        
        Task {
            guard let image = vm.imagePath,
                  let url = URL(string: image)
            else { return }

            do {
                let photo = try await URL.urlToImage(url)
                self.commentImage.image = photo
            }
            catch {
                print("Error fetching comment image \(error)")
            }
            
        }
        
        bind(with: vm)
    }

    private func bind(with vm: CommentTableViewCellModel) {
        func bindViewToViewModel() {
            editButton.tapPublisher
                .receive(on: DispatchQueue.main)
                .sink { _ in
                    self.commentTexts.isHidden = true
                }
                .store(in: &bindings)
            
            deleteButton.tapPublisher
                .receive(on: DispatchQueue.main)
                .sink { _ in
                    
                }
                .store(in: &bindings)
        }
        
        func bindViewModelToView() {
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
                            self.profileImageView.image = try await URL.urlToImage(url)
                        }
                        catch {
                            print("Error converting profile image - \(error.localizedDescription)")
                        }
                    }
                }
                .store(in: &bindings)
        }
        
        bindViewToViewModel()
        bindViewModelToView()
    }
    
    func resetCell() {
        self.contentView.backgroundColor = .white
        self.profileImageView.image = nil
        self.nicknameLabel.text = nil
        self.commentTexts.text = nil
        self.commentImage.image = nil
        self.createdAtLabel.text = nil
        self.editButton.isHidden = true
        self.deleteButton.isHidden = true
    }
    
    func changeCellType(to celltype: CommentCellType) {
        self.type = celltype
    }
}

// MARK: - Find Current User's Comment
extension PostCommentCollectionViewCell {
    private func currentUserConfiguration(with vm: CommentTableViewCellModel) {
        guard let currentUserId = UserDefaults.standard.string(forKey: UserDefaultsConstants.userId),
        vm.userId == currentUserId
        else {
            return
        }
        editButton.isHidden = false
        deleteButton.isHidden = false
    }
}
