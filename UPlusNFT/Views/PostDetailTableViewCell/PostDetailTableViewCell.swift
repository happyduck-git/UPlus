//
//  PostDetailTableViewCell.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/07/02.
//

import UIKit

final class PostDetailTableViewCell: UITableViewCell {
    
    enum PostType: String {
        case article = "일반 게시물"
        case multipleChoice = "객관식"
        case bestComment = "베스트 댓글"
    }
    
    private let postIdLabel: UILabel = {
        let label = UILabel()
        label.text = "123194"
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let postUrlLabel: UILabel = {
        let label = UILabel()
        label.text = "http://platfarm.net/post/92"
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let postTypeLabel: UILabel = {
        let label = UILabel()
        label.text = PostType.article.rawValue
        label.textColor = .white
        label.backgroundColor = .systemPink
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let postTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "게시글 타이틀입니다."
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
        imageView.image = UIImage(systemName: "person.circle.fill")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nicknameLabel: UILabel = {
        let label = UILabel()
        label.text = "nickname"
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let likeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.setTitle("99", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let createdAtLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = "2023/07/01"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = .white
        setUI()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Internal
    func configure(with vm: PostDetailViewViewModel) {
        self.postContentTextView.text = "게시글 본문: " + vm.postContent
    }
    
    //MARK: - Private
    private func setUI() {
        contentView.addSubviews(
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
        let viewHeight = contentView.frame.height
        let viewWidth = contentView.frame.width
        print("Viewheight: \(viewHeight)")
        NSLayoutConstraint.activate([
            self.postIdLabel.topAnchor.constraint(equalToSystemSpacingBelow: contentView.topAnchor, multiplier: 1),
            self.postIdLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: contentView.leadingAnchor, multiplier: 3),
            self.postUrlLabel.topAnchor.constraint(equalTo: self.postIdLabel.topAnchor),
            contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.postUrlLabel.trailingAnchor, multiplier: 3),
            
            self.postTypeLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.postIdLabel.bottomAnchor, multiplier: 2),
            self.postTypeLabel.leadingAnchor.constraint(equalTo: self.postIdLabel.leadingAnchor),
            
            self.postTitleLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.postTypeLabel.bottomAnchor, multiplier: 1),
            self.postTitleLabel.leadingAnchor.constraint(equalTo: self.postIdLabel.leadingAnchor),
            
            self.horizontalLineView.topAnchor.constraint(equalToSystemSpacingBelow: self.postTitleLabel.bottomAnchor, multiplier: 1),
            self.horizontalLineView.heightAnchor.constraint(equalToConstant: 2),
            self.horizontalLineView.leadingAnchor.constraint(equalToSystemSpacingAfter: contentView.leadingAnchor, multiplier: 3),
            contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.horizontalLineView.trailingAnchor, multiplier: 3),
            
            self.postContentTextView.topAnchor.constraint(equalToSystemSpacingBelow: self.horizontalLineView.bottomAnchor, multiplier: 1),
            self.postContentTextView.leadingAnchor.constraint(equalTo: self.horizontalLineView.leadingAnchor),
            self.postContentTextView.trailingAnchor.constraint(equalTo: self.horizontalLineView.trailingAnchor),
            self.postContentTextView.heightAnchor.constraint(equalToConstant: viewHeight * 2),
            
            self.postImageView.topAnchor.constraint(equalToSystemSpacingBelow: self.postContentTextView.bottomAnchor, multiplier: 2),
            self.postImageView.leadingAnchor.constraint(equalToSystemSpacingAfter: contentView.leadingAnchor, multiplier: 3),
            contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.postImageView.trailingAnchor, multiplier: 3),
            self.postImageView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.profileImageView.topAnchor, multiplier: -2),
            
            self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.profileImageView.bottomAnchor, multiplier: 1),
            self.profileImageView.leadingAnchor.constraint(equalTo: self.postIdLabel.leadingAnchor),
            self.profileImageView.heightAnchor.constraint(equalToConstant: viewWidth / 16),
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
        
//        postContentTextView.setContentHuggingPriority(.defaultLow, for: .vertical)
    }
}
