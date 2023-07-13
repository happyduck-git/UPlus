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
import OSLog

enum CommentCellType {
    case best
    case normal
    case recomment
}

protocol PostCommentCollectionViewCellPorotocol: AnyObject {
    func commentDeleted()
    func showCommentDidTap(at indexPath: IndexPath)
    func editButtonDidTap(at indexPath: IndexPath)
}

final class PostCommentCollectionViewCell: UICollectionViewCell {
    
    private let logger = Logger()
    
    //MARK: - Dependency
    private var vm: CommentTableViewCellModel?
    
    private var binded: Bool = false
    
    // MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    // MARK: - Cell Status
    private var isEditMode: Bool = false
    private var isRecommentOpened: Bool = false
    
    //MARK: - Closure
    var commentEditViewCameraBtnDidTap: (() -> Void)?
    
    // MARK: - Delegate
    weak var delegate: PostCommentCollectionViewCellPorotocol?
    var indexPath: IndexPath?
    
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
        imageView.image = UIImage(systemName: SFSymbol.defaultProfile)
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
    
    private let commentDefaultView: CampaignCommentDefaultView = {
        let view = CampaignCommentDefaultView()
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let commentEditView: CampaignCommentEditView = {
        let view = CampaignCommentEditView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let likeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: SFSymbol.heart), for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let commentButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: SFSymbol.comment), for: .normal)
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
   
    private lazy var showCommentButton: UIButton = {
        let button = UIButton()
        button.setTitle(PostConstants.showComment, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setImage(UIImage(systemName: SFSymbol.arrowDown), for: .normal)
        button.semanticContentAttribute = .forceRightToLeft
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUI()
        setLayout()
        commentEditSaveButtonDidTap()
        contentView.backgroundColor = .systemGray
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Set UI & Layout
extension PostCommentCollectionViewCell {
    
    private func setUI() {
        contentView.addSubviews(
            bestLabel,
            profileImageView,
            nicknameLabel,
            editButton,
            deleteButton,
            commentDefaultView,
            commentEditView,
            likeButton,
            commentButton,
            createdAtLabel,
            showCommentButton
        )
    }
    
    private func setLayout() {
        let viewWidth = self.contentView.frame.width
        
        NSLayoutConstraint.activate([
            self.bestLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 1),
            self.bestLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 2),
            self.bestLabel.heightAnchor.constraint(equalToConstant: 15),
            
            self.profileImageView.topAnchor.constraint(equalToSystemSpacingBelow: self.bestLabel.bottomAnchor, multiplier: 1),
            self.profileImageView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 2),
            self.profileImageView.widthAnchor.constraint(equalToConstant: viewWidth / 16),
            self.profileImageView.heightAnchor.constraint(equalTo: self.profileImageView.widthAnchor),
            
            self.nicknameLabel.centerYAnchor.constraint(equalTo: self.profileImageView.centerYAnchor),
            self.nicknameLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.profileImageView.trailingAnchor, multiplier: 1),
            
            self.deleteButton.centerYAnchor.constraint(equalTo: self.nicknameLabel.centerYAnchor),
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.deleteButton.trailingAnchor, multiplier: 2),
            self.editButton.centerYAnchor.constraint(equalTo: self.nicknameLabel.centerYAnchor),
            self.deleteButton.leadingAnchor.constraint(equalToSystemSpacingAfter: self.editButton.trailingAnchor, multiplier: 1),
            
            self.commentDefaultView.topAnchor.constraint(equalToSystemSpacingBelow: self.profileImageView.bottomAnchor, multiplier: 1),
            self.commentDefaultView.leadingAnchor.constraint(equalTo: self.bestLabel.leadingAnchor),
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.commentDefaultView.trailingAnchor, multiplier: 2),

            self.commentEditView.topAnchor.constraint(equalToSystemSpacingBelow: self.profileImageView.bottomAnchor, multiplier: 1),
            self.commentEditView.leadingAnchor.constraint(equalTo: self.bestLabel.leadingAnchor),
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.commentEditView.trailingAnchor, multiplier: 2),
            
            self.likeButton.topAnchor.constraint(equalToSystemSpacingBelow: self.commentDefaultView.bottomAnchor, multiplier: 2),
            self.likeButton.leadingAnchor.constraint(equalTo: self.commentDefaultView.leadingAnchor),
            self.showCommentButton.bottomAnchor.constraint(equalToSystemSpacingBelow: self.likeButton.bottomAnchor, multiplier: 3),
            
            self.commentButton.topAnchor.constraint(equalTo: self.likeButton.topAnchor),
            self.commentButton.leadingAnchor.constraint(equalToSystemSpacingAfter: self.likeButton.trailingAnchor, multiplier: 1),
            self.commentButton.bottomAnchor.constraint(equalTo: self.likeButton.bottomAnchor),
            
            self.createdAtLabel.topAnchor.constraint(equalTo: self.likeButton.topAnchor),
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.createdAtLabel.trailingAnchor, multiplier: 2),
            self.createdAtLabel.bottomAnchor.constraint(equalTo: self.likeButton.bottomAnchor),
            
            self.showCommentButton.topAnchor.constraint(equalToSystemSpacingBelow: self.likeButton.bottomAnchor, multiplier: 1),
            self.showCommentButton.leadingAnchor.constraint(equalTo: self.profileImageView.leadingAnchor),
            self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.showCommentButton.bottomAnchor, multiplier: 2)
        ])
        self.bestLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
    
}

//MARK: - Cell Configuration & View Model Binding
extension PostCommentCollectionViewCell {

    func configure(with cellVM: CommentTableViewCellModel) {
        self.commentEditView.cameraBtnDidTapHandler = commentEditViewCameraBtnDidTap
        
        bindings.forEach { $0.cancel() }
        bindings.removeAll()
        
        self.vm = cellVM
        switch cellVM.type {
        case .best:
            self.bestLabel.isHidden = false
            self.bestLabel.heightAnchor.constraint(equalToConstant: 0).isActive = false
            self.bestLabel.heightAnchor.constraint(equalToConstant: 15).isActive = true
        case .normal:
            self.bestLabel.isHidden = true
            self.bestLabel.heightAnchor.constraint(equalToConstant: 0).isActive = true
            self.bestLabel.heightAnchor.constraint(equalToConstant: 15).isActive = false
        case .recomment:
            self.bestLabel.isHidden = true
            self.bestLabel.heightAnchor.constraint(equalToConstant: 0).isActive = true
            self.bestLabel.heightAnchor.constraint(equalToConstant: 15).isActive = false
            self.likeButton.isHidden = true
            self.commentButton.isHidden = true
            self.showCommentButton.isHidden = true
        }
        
        self.currentUserConfiguration(with: cellVM)
        self.likeButton.setTitle(String(describing: cellVM.likeUserCount ?? 0), for: .normal)
        self.commentButton.setTitle(String(describing: cellVM.recomments?.count ?? 0), for: .normal)
        self.createdAtLabel.text = String(describing: cellVM.createdAt.dateValue().monthDayTimeFormat)
        self.commentDefaultView.configure(with: cellVM)
        
        let likeImage: String = cellVM.isLiked ? SFSymbol.heartFill : SFSymbol.heart
        self.likeButton.setImage(UIImage(systemName: likeImage), for: .normal)
        
        self.bind(with: cellVM)

    }

    private func bind(with vm: CommentTableViewCellModel) {
        func bindViewToViewModel() {
                
            editButton.tapPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    guard let `self` = self,
                          let cellVM = self.vm,
                          let indexPath = self.indexPath
                    else { return }
                    
                    self.delegate?.editButtonDidTap(at: indexPath)
                    self.convertToEditMode()
                    self.commentEditView.configure(with: cellVM)
                    self.layoutIfNeeded()
                    self.isEditMode = true
                }
                .store(in: &bindings)
            
            deleteButton.tapPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    guard let `self` = self,
                          let cellVM = self.vm else { return }
                    Task {
                        do {
                            try await cellVM.deleteComment(postId: cellVM.postId,
                                                           commentId: cellVM.id)
                            self.delegate?.commentDeleted()
                        }
                        catch {
                            self.logger.error("Error deleting a comment -- \(error.localizedDescription)")
                        }
                    }
                }
                .store(in: &bindings)
            
            commentEditView.editTextField.textPublisher
                .receive(on: DispatchQueue.main)
                .removeDuplicates()
                .debounce(for: 0.1, scheduler: RunLoop.main)
                .sink { [weak self] in
                    guard let `self` = self,
                          let cellVM = self.vm else { return }
                    if !$0.isEmpty
                        && $0.trimmingCharacters(in: .whitespacesAndNewlines) == cellVM.comment {
                        commentEditView.confirmButton.backgroundColor = .systemGray
                        commentEditView.confirmButton.isUserInteractionEnabled = false
                    } else {
                        commentEditView.confirmButton.backgroundColor = .black
                        commentEditView.confirmButton.isUserInteractionEnabled = true
                    }
                }
                .store(in: &bindings)
            
            commentEditView.cancelButton.tapPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    guard let `self` = self else { return }
                    self.convertToNormalMode()
                    self.isEditMode = false
                }
                .store(in: &bindings)
            
            likeButton.tapPublisher
                .receive(on: RunLoop.current)
                .sink { [weak self] _ in
                    guard let `self` = self,
                          let cellVM = self.vm else { return }
                    cellVM.isLiked = !cellVM.isLiked
                }
                .store(in: &bindings)
            
            showCommentButton.tapPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    guard let `self` = self,
                          let indexPath = self.indexPath
                    else { return }
                    self.isRecommentOpened = !self.isRecommentOpened
                    let image = isRecommentOpened ? SFSymbol.arrowUp : SFSymbol.arrowDown
                    self.showCommentButton.setImage(UIImage(systemName: image), for: .normal)
                    
                    self.delegate?.showCommentDidTap(at: indexPath)
                }
                .store(in: &bindings)
            
        }
        
        func bindViewModelToView() {
            self.vm?.$user
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
                            self.profileImageView.image = UIImage(systemName: SFSymbol.defaultProfile)
                            print("Error converting profile image - \(error.localizedDescription)")
                        }
                    }
                }
                .store(in: &bindings)
            
            self.vm?.$isLiked
                .receive(on: DispatchQueue.main)
                .dropFirst()
                .removeDuplicates()
                .sink { [weak self] liked in
                    guard let `self` = self,
                          let cellVM = self.vm
                    else { return }
                    Task {
                        let image = liked ? SFSymbol.heartFill : SFSymbol.heart
                        let updatedCount = liked ? 1 : -1
                        let currentLikes = cellVM.likeUserCount ?? 0
                        cellVM.likeUserCount = currentLikes + updatedCount

                        self.likeButton.setImage(UIImage(systemName: image), for: .normal)
                        self.likeButton.setTitle("\(currentLikes + updatedCount)", for: .normal)
                        try await cellVM.likeComment(isLiked: liked)
                    }
                }
                .store(in: &bindings)
        }
        
        bindViewToViewModel()
        bindViewModelToView()
    }
    //MARK: - Change to Edit mode
    private func convertToEditMode() {
        editButton.isHidden = true
        deleteButton.isHidden = true
        commentDefaultView.isHidden = true
        showCommentButton.isHidden = true
        
        commentEditView.isHidden = false
        likeButton.topAnchor.constraint(equalTo: commentDefaultView.bottomAnchor).isActive = false
        likeButton.topAnchor.constraint(equalTo: commentEditView.bottomAnchor).isActive = true
        
        self.layoutIfNeeded()
    }
    
    private func convertToNormalMode() {
        editButton.isHidden = false
        deleteButton.isHidden = false
        commentDefaultView.isHidden = false
        showCommentButton.isHidden = false
        
        commentEditView.isHidden = true
    }
    
    func resetCell() {
        self.contentView.backgroundColor = .systemGray
        self.commentDefaultView.isHidden = false
        self.commentEditView.isHidden = true
        self.editButton.isHidden = true
        self.deleteButton.isHidden = true
        self.profileImageView.image = nil
        self.nicknameLabel.text = nil
        self.createdAtLabel.text = nil
        self.commentDefaultView.resetcontents()
        self.likeButton.setTitle(nil, for: .normal)
        self.likeButton.setImage(nil, for: .normal)
        self.likeButton.isHidden = false
        self.commentButton.isHidden = false
        self.showCommentButton.isHidden = false
        
//        self.bestLabel.heightAnchor.constraint(equalToConstant: 0).isActive = false
//        self.bestLabel.heightAnchor.constraint(equalToConstant: 15).isActive = true
        
    }
    
    func resetCellForEditMode() {
        self.contentView.backgroundColor = .systemGray
        convertToEditMode()
    }
    
}

extension PostCommentCollectionViewCell {
    private func commentEditSaveButtonDidTap() {
        self.commentEditView.editedCommentDidSavedHandler = { [weak self] in
            guard let `self` = self else { return }
            self.convertToNormalMode()
            self.commentDefaultView.commentTexts.text = self.vm?.editedComment ?? self.vm?.comment
        }
    }
}

//MARK: - Comment Edit Mode
extension PostCommentCollectionViewCell {
    // MARK: - Find Current User's Comment
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
