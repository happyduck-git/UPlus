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

protocol PostDetailCollectionViewHeaderProtocol: AnyObject {
    func likeButtonDidTap(vm: PostDetailViewViewModel)
}

final class PostDetailCollectionViewHeader: UICollectionReusableView {
    
    //MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    //MARK: - Delegate
    weak var delegate: PostDetailCollectionViewHeaderProtocol?
    
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
        imageView.accessibilityIdentifier = "Post Image View"
        imageView.backgroundColor = .systemGray3
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let placeholderView: UIView = {
       let view = UIView()
        view.backgroundColor = .red
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
    
    //MARK: - Constraints
    var contentImageHeight: NSLayoutConstraint?
    
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

}

//MARK: - Configure and bind CollectionViewHeader with View Model.
extension PostDetailCollectionViewHeader {
    func configure(with vm: PostDetailViewViewModel) {
        bindings.forEach { $0.cancel() }
        bindings.removeAll()
 
        self.postIdLabel.text = String(vm.postId.prefix(5))
        self.postUrlLabel.text = String(vm.postUrl.prefix(20))
        self.postTypeLabel.text = vm.postType.displayName
        self.postTitleLabel.text = vm.postTitle
        self.postContentTextView.text = vm.postContent
        self.nicknameLabel.text = String(vm.userId.prefix(5))
        self.likeButton.setTitle(String(describing: vm.likeUserCount), for: .normal)
        self.createdAtLabel.text = String(describing: vm.createdTime.monthDayTimeFormat)
        
        let likeImage: String = vm.isLiked ? "heart.fill" : "heart"
        self.likeButton.setImage(UIImage(systemName: likeImage), for: .normal)
        
        Task {
            if let firstImage = vm.imageList?.first {
                let url = URL(string: firstImage)
                self.postImageView.isHidden = false
                self.placeholderView.isHidden = true
                self.postImageView.image = try await URL.urlToImage(url)
            } else {
                self.postImageView.isHidden = true
                self.placeholderView.isHidden = false
            }
            
        }
        
        bind(with: vm)
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
        
        likeButton.tapPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let `self` = self else { return }
                
                vm.isLiked = !vm.isLiked
                let likeImage: String = vm.isLiked ? SFSymbol.heartFill : SFSymbol.heart
                let updateLikeCount: Int = vm.isLiked ? 1 : -1
                vm.likeUserCount += updateLikeCount
 
                self.likeButton.setImage(UIImage(systemName: likeImage), for: .normal)
                self.likeButton.setTitle(String(vm.likeUserCount), for: .normal)
                
                self.delegate?.likeButtonDidTap(vm: vm)
            }
            .store(in: &bindings)
        
    }
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        print("Header height after layout: \(self.frame.height)")
    }
}

//MARK: - Set UI & Set Layout
extension PostDetailCollectionViewHeader {

    private func setUI() {
        self.addSubviews(
            postIdLabel,
            postUrlLabel,
            postTypeView,
            postTitleLabel,
            horizontalLineView,
            postContentTextView,
            placeholderView,
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
        print("Header height: \(height)")
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
            self.postContentTextView.heightAnchor.constraint(equalToConstant: 80),
            
            self.postImageView.topAnchor.constraint(equalToSystemSpacingBelow: self.postContentTextView.bottomAnchor, multiplier: 1),
            self.postImageView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.leadingAnchor, multiplier: 3),
            self.trailingAnchor.constraint(equalToSystemSpacingAfter: self.postImageView.trailingAnchor, multiplier: 3),
            self.postImageView.heightAnchor.constraint(equalToConstant: 200),
            
            self.placeholderView.topAnchor.constraint(equalToSystemSpacingBelow: self.postContentTextView.bottomAnchor, multiplier: 1),
            self.placeholderView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.leadingAnchor, multiplier: 3),
            self.trailingAnchor.constraint(equalToSystemSpacingAfter: self.placeholderView.trailingAnchor, multiplier: 3),
            self.placeholderView.heightAnchor.constraint(equalToConstant: 0),
            
            self.nicknameLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.postImageView.bottomAnchor, multiplier: 2),

            self.bottomAnchor.constraint(equalToSystemSpacingBelow: self.profileImageView.bottomAnchor, multiplier: 1),
            self.profileImageView.leadingAnchor.constraint(equalTo: self.postIdLabel.leadingAnchor),
            self.profileImageView.heightAnchor.constraint(equalToConstant: 15),
            self.profileImageView.widthAnchor.constraint(equalTo: self.profileImageView.heightAnchor),
            
            self.nicknameLabel.topAnchor.constraint(equalTo: self.profileImageView.topAnchor),
            self.nicknameLabel.bottomAnchor.constraint(equalTo: self.profileImageView.bottomAnchor),
            self.nicknameLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.profileImageView.trailingAnchor, multiplier: 1),
            
            self.createdAtLabel.centerYAnchor.constraint(equalTo: self.likeButton.centerYAnchor),
            self.createdAtLabel.trailingAnchor.constraint(equalTo: self.horizontalLineView.trailingAnchor),
            self.createdAtLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.likeButton.trailingAnchor, multiplier: 1),
            self.likeButton.bottomAnchor.constraint(equalTo: self.profileImageView.bottomAnchor),
        ])

    }

}
