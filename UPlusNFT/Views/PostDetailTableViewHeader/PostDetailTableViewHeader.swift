//
//  PostDetailTableViewHeader.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/07/03.
//

import UIKit
import Combine
import Nuke

final class PostDetailTableViewHeader: UIView {
    
    private var bindings = Set<AnyCancellable>()
    
    //MARK: - Property
    private let postIdLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.limitTextLength(maxLength: 5)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let postUrlLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let postTypeLabel: UILabel = {
        let label = UILabel()
        label.text = PostType.article.rawValue
        label.textColor = .white
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.backgroundColor = UIColor.init(hex: 0xF79DD1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let postTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.backgroundColor = .white
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
        imageView.image = UIImage(systemName: "camera")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nicknameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
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
        self.backgroundColor = .white
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
        
        bind(with: vm)
    }

    //MARK: - Private

    private func setUI() {
        self.addSubviews(
            postIdLabel,
            postUrlLabel,
            postTypeLabel,
            postTitleLabel,
            horizontalLineView,
            postContentTextView,
            postImageView,
            profileImageView,
            nicknameLabel,
            likeButton,
            createdAtLabel
        )
    }
    
    private func setLayout() {
        let height = self.frame.height
        NSLayoutConstraint.activate([
            self.postIdLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.topAnchor, multiplier: 1),
            self.postIdLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.leadingAnchor, multiplier: 3),
            self.postUrlLabel.topAnchor.constraint(equalTo: self.postIdLabel.topAnchor),
            self.trailingAnchor.constraint(equalToSystemSpacingAfter: self.postUrlLabel.trailingAnchor, multiplier: 3),
            
            self.postTypeLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.postIdLabel.bottomAnchor, multiplier: 2),
            self.postTypeLabel.leadingAnchor.constraint(equalTo: self.postIdLabel.leadingAnchor),
            
            self.postTitleLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.postTypeLabel.bottomAnchor, multiplier: 1),
            self.postTitleLabel.leadingAnchor.constraint(equalTo: self.postIdLabel.leadingAnchor),
            
            self.horizontalLineView.topAnchor.constraint(equalToSystemSpacingBelow: self.postTitleLabel.bottomAnchor, multiplier: 1),
            self.horizontalLineView.heightAnchor.constraint(equalToConstant: 2),
            self.horizontalLineView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.leadingAnchor, multiplier: 3),
            self.trailingAnchor.constraint(equalToSystemSpacingAfter: self.horizontalLineView.trailingAnchor, multiplier: 3),
            
            self.postContentTextView.topAnchor.constraint(equalToSystemSpacingBelow: self.horizontalLineView.bottomAnchor, multiplier: 1),
            self.postContentTextView.leadingAnchor.constraint(equalTo: self.horizontalLineView.leadingAnchor),
            self.postContentTextView.trailingAnchor.constraint(equalTo: self.horizontalLineView.trailingAnchor),
            self.postContentTextView.heightAnchor.constraint(equalToConstant: height * 2),
            
            self.postImageView.topAnchor.constraint(equalToSystemSpacingBelow: self.postContentTextView.bottomAnchor, multiplier: 2),
            self.postImageView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.leadingAnchor, multiplier: 3),
            self.trailingAnchor.constraint(equalToSystemSpacingAfter: self.postImageView.trailingAnchor, multiplier: 3),
            self.nicknameLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.postImageView.bottomAnchor, multiplier: 2),
            
            self.self.bottomAnchor.constraint(equalToSystemSpacingBelow: self.profileImageView.bottomAnchor, multiplier: 1),
            self.profileImageView.leadingAnchor.constraint(equalTo: self.postIdLabel.leadingAnchor),
            self.profileImageView.heightAnchor.constraint(equalToConstant: height / 16),
            self.profileImageView.widthAnchor.constraint(equalTo: self.profileImageView.heightAnchor),
            
            self.nicknameLabel.bottomAnchor.constraint(equalTo: self.profileImageView.bottomAnchor),
            self.nicknameLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.profileImageView.trailingAnchor, multiplier: 1),
            
            self.createdAtLabel.bottomAnchor.constraint(equalTo: self.profileImageView.bottomAnchor),
            self.createdAtLabel.trailingAnchor.constraint(equalTo: self.horizontalLineView.trailingAnchor),
            self.createdAtLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.likeButton.trailingAnchor, multiplier: 1),
            self.likeButton.bottomAnchor.constraint(equalTo: self.profileImageView.bottomAnchor),
        ])
        
        postIdLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        postUrlLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        postTypeLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        postTitleLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        
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
                        self.profileImageView.image = try await ImagePipeline.shared.image(for: url)
                    }
                    catch {
                        print("Error converting profile image -- \(error.localizedDescription)")
                    }
                }
               
            }
            .store(in: &bindings)
    }
    
    
}
