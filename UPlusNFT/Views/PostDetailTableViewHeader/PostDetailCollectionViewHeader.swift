//
//  PostDetailCollectionViewHeader.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/04.
//

import UIKit
import Combine
import Nuke
import FirebaseStorage

final class PostDetailCollectionViewHeader: UICollectionReusableView {
    
    private var bindings = Set<AnyCancellable>()
    
    //MARK: - Property
    private let postIdLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray
        label.limitTextLength(maxLength: 5)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let postUrlLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let postTypeView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.backgroundColor = UIColor.init(hex: 0xF79DD1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let postTypeLabel: UILabel = {
        let label = UILabel()
        label.text = PostType.article.rawValue
        label.font = .systemFont(ofSize: 13, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let postTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        label.font = .systemFont(ofSize: 17, weight: .heavy)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let horizontalLineView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let postContentTextView: UITextView = {
        let textView = UITextView()
        textView.textColor = .black
        textView.backgroundColor = .white
        textView.isUserInteractionEnabled = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private let postImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .systemGray6
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.circle")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nicknameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
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
    
    private let createdAtLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .systemGray6
        setUI()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Internal
    func configure(with vm: PostDetailViewViewModel) {
        self.postIdLabel.text = String(vm.postId.prefix(5))
        self.postUrlLabel.text = String(vm.postUrl.prefix(20))
        self.postTypeLabel.text = vm.postType.displayName
        self.postTitleLabel.text = vm.postTitle
        self.postContentTextView.text = vm.postContent
        self.nicknameLabel.text = String(vm.userId.prefix(5))
        self.likeButton.setTitle(String(describing: vm.likeUserCount), for: .normal)
        self.createdAtLabel.text = String(describing: vm.createdTime.monthDayTimeFormat)
    
        Task {
            let firstImage = vm.imageList?.first ?? ""
            let url = URL(string: firstImage)
            self.postImageView.image = try await URL.urlToImage(url)
        }
        
        bind(with: vm)
    }

    //MARK: - Private

    private func setUI() {
        self.addSubviews(
            postIdLabel,
            postUrlLabel,
            postTypeView,
            postTitleLabel,
            horizontalLineView,
            postContentTextView,
            postImageView,
            profileImageView,
            nicknameLabel,
            likeButton,
            createdAtLabel
        )
        postTypeView.addSubview(postTypeLabel)
    }
    
    private func setLayout() {
        let height = self.frame.height
        NSLayoutConstraint.activate([
            self.postIdLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.topAnchor, multiplier: 1),
            self.postIdLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.leadingAnchor, multiplier: 3),
            self.postUrlLabel.topAnchor.constraint(equalTo: self.postIdLabel.topAnchor),
            self.trailingAnchor.constraint(equalToSystemSpacingAfter: self.postUrlLabel.trailingAnchor, multiplier: 3),
            
            self.postTypeView.topAnchor.constraint(equalToSystemSpacingBelow: self.postIdLabel.bottomAnchor, multiplier: 2),
            self.postTypeView.leadingAnchor.constraint(equalTo: self.postIdLabel.leadingAnchor),
            
            self.postTypeLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.postTypeView.topAnchor, multiplier: 1),
            self.postTypeLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.postTypeView.leadingAnchor, multiplier: 1),
            self.postTypeView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.postTypeLabel.trailingAnchor, multiplier: 1),
            self.postTypeView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.postTypeLabel.bottomAnchor, multiplier: 1),
            
            self.postTitleLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.postTypeView.bottomAnchor, multiplier: 1),
            self.postTitleLabel.leadingAnchor.constraint(equalTo: self.postIdLabel.leadingAnchor),
            self.trailingAnchor.constraint(equalToSystemSpacingAfter: self.postTitleLabel.trailingAnchor, multiplier: 2),
            
            self.horizontalLineView.topAnchor.constraint(equalToSystemSpacingBelow: self.postTitleLabel.bottomAnchor, multiplier: 1),
            self.horizontalLineView.heightAnchor.constraint(equalToConstant: 2),
            self.horizontalLineView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.leadingAnchor, multiplier: 3),
            self.trailingAnchor.constraint(equalToSystemSpacingAfter: self.horizontalLineView.trailingAnchor, multiplier: 3),
            
            self.postContentTextView.topAnchor.constraint(equalToSystemSpacingBelow: self.horizontalLineView.bottomAnchor, multiplier: 1),
            self.postContentTextView.leadingAnchor.constraint(equalTo: self.horizontalLineView.leadingAnchor),
            self.postContentTextView.trailingAnchor.constraint(equalTo: self.horizontalLineView.trailingAnchor),
            
            self.postImageView.topAnchor.constraint(equalToSystemSpacingBelow: self.postContentTextView.bottomAnchor, multiplier: 1),
            self.postImageView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.leadingAnchor, multiplier: 3),
            self.trailingAnchor.constraint(equalToSystemSpacingAfter: self.postImageView.trailingAnchor, multiplier: 3),
            self.postImageView.heightAnchor.constraint(equalToConstant: height / 3),
            
            self.nicknameLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.postImageView.bottomAnchor, multiplier: 2),

            self.self.bottomAnchor.constraint(equalToSystemSpacingBelow: self.profileImageView.bottomAnchor, multiplier: 1),
            self.profileImageView.leadingAnchor.constraint(equalTo: self.postIdLabel.leadingAnchor),
            self.profileImageView.heightAnchor.constraint(equalToConstant: height / 16),
            self.profileImageView.widthAnchor.constraint(equalTo: self.profileImageView.heightAnchor),
            
            self.nicknameLabel.bottomAnchor.constraint(equalTo: self.profileImageView.bottomAnchor),
            self.nicknameLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.profileImageView.trailingAnchor, multiplier: 1),
            
            self.createdAtLabel.centerYAnchor.constraint(equalTo: self.likeButton.centerYAnchor),
            self.createdAtLabel.trailingAnchor.constraint(equalTo: self.horizontalLineView.trailingAnchor),
            self.createdAtLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.likeButton.trailingAnchor, multiplier: 1),
            self.likeButton.bottomAnchor.constraint(equalTo: self.profileImageView.bottomAnchor),
        ])
    }
    
    private func bind(with vm: PostDetailViewViewModel) {
        vm.$user
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                guard let `self` = self else { return }
                Task {
                    do {
                        guard let url = URL(string: user?.profileImagePath ?? FirestoreConstants.defaultUserProfile) else {
                            return
                        }
                        self.profileImageView.image = try await URL.urlToImage(url)
                    }
                    catch {
                        print("Error converting profile image -- \(error.localizedDescription)")
                    }
                }
               
            }
            .store(in: &bindings)
    }
  
}
