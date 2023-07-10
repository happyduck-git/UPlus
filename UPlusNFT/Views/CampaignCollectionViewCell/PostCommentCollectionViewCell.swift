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
    
    //MARK: - Dependency
    private var vm: CommentTableViewCellModel?
    
    private var binded: Bool = false
    
    // MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    private(set) var type: CommentCellType = .normal
    
    private var isEditMode: Bool = false
    
    //MARK: - Closure
    var editButtonDidTap: (() -> Void)?
    
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
    
    private let editTextField: UITextField = {
        let txtField = UITextField()
        txtField.isHidden = true
        txtField.borderStyle = .roundedRect
        txtField.translatesAutoresizingMaskIntoConstraints = false
        return txtField
    }()
    
    private let commentTexts: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .black
        label.lineBreakMode = .byTruncatingMiddle
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
        button.setImage(UIImage(systemName: SFSymbol.like), for: .normal) //heart.fill
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
    
    private let cameraButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: SFSymbol.camera), for: .normal)
        button.tintColor = .systemGray
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let editedImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .systemBlue
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton()
        button.isHidden = true
        button.setTitle("취소", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGray
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let confirmButton: UIButton = {
        let button = UIButton()
        button.isHidden = true
        button.setTitle("수정", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGray
        button.isUserInteractionEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
        setLayout()
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
            commentTexts,
            commentImage,
            editTextField,
            likeButton,
            commentButton,
            createdAtLabel,
            cancelButton,
            confirmButton
        )
    }
    
    private func setLayout() {
        let viewWidth = self.contentView.frame.width
        
        NSLayoutConstraint.activate([
            self.bestLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 1),
            self.bestLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 2),
            
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
            
            self.commentTexts.topAnchor.constraint(equalToSystemSpacingBelow: self.profileImageView.bottomAnchor, multiplier: 1),
            self.commentTexts.leadingAnchor.constraint(equalTo: self.bestLabel.leadingAnchor),
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.commentTexts.trailingAnchor, multiplier: 2),
            
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
    
    private func setEditTextFieldLayout() {
        NSLayoutConstraint.activate([
            self.editTextField.topAnchor.constraint(equalToSystemSpacingBelow: self.nicknameLabel.bottomAnchor, multiplier: 1),
            self.editTextField.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 2),
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.editTextField.trailingAnchor, multiplier: 2),
            self.cancelButton.topAnchor.constraint(equalToSystemSpacingBelow: self.editTextField.bottomAnchor, multiplier: 1),
            
            self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.confirmButton.bottomAnchor, multiplier: 2),
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.confirmButton.trailingAnchor, multiplier: 2),
            self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.cancelButton.bottomAnchor, multiplier: 2),
            self.confirmButton.leadingAnchor.constraint(equalToSystemSpacingAfter: self.cancelButton.trailingAnchor, multiplier: 1)
        ])
    }
}

//MARK: - Cell Configuration & View Model Binding
extension PostCommentCollectionViewCell {

    func configure(with cellVM: CommentTableViewCellModel) {
        self.vm = cellVM
        switch cellVM.type {
        case .best:
            self.bestLabel.isHidden = false
        case .normal:
            self.bestLabel.isHidden = true
        }
        
        self.currentUserConfiguration(with: cellVM)
        self.commentTexts.text = cellVM.comment
        self.likeButton.setTitle(String(describing: cellVM.likeUserCount ?? 0), for: .normal)
        self.commentButton.setTitle(String(describing: cellVM.recomments?.count ?? 0), for: .normal)
        self.createdAtLabel.text = String(describing: cellVM.createdAt.dateValue().monthDayTimeFormat)
        self.editTextField.text = cellVM.comment
        
        Task {
            guard let image = cellVM.imagePath,
                  let url = URL(string: image)
            else {
                self.commentImage.isHidden = true
                return
            }

            do {
                let photo = try await URL.urlToImage(url)
                self.commentImage.image = photo
            }
            catch {
                print("Error fetching comment image \(error)")
            }
            
        }
        
        if !self.binded {
            self.bind(with: cellVM)
            self.binded = true
        }
    }

    private func bind(with vm: CommentTableViewCellModel) {
        func bindViewToViewModel() {
            
            editButton.tapPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    guard let `self` = self,
                          let cellVM = self.vm else { return }
                    
                    self.convertToEditMode()
                    self.editButtonDidTap?()

                    self.editTextField.text = cellVM.comment
                    self.isEditMode = true
                }
                .store(in: &bindings)
            
            deleteButton.tapPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    guard let `self` = self else { return }
                    
                }
                .store(in: &bindings)
            
            editTextField.textPublisher
                .receive(on: DispatchQueue.main)
                .removeDuplicates()
                .debounce(for: 0.1, scheduler: RunLoop.main)
                .sink { [weak self] in
                    guard let `self` = self,
                          let cellVM = self.vm else { return }
                    if !$0.isEmpty
                        && $0.trimmingCharacters(in: .whitespacesAndNewlines) == cellVM.comment {
                        self.confirmButton.backgroundColor = .systemGray
                        self.confirmButton.isUserInteractionEnabled = false
                    } else {
                        self.confirmButton.backgroundColor = .black
                        self.confirmButton.isUserInteractionEnabled = true
                    }
                }
                .store(in: &bindings)
            
            cancelButton.tapPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    guard let `self` = self else { return }
                    self.convertToNormalMode()
                    self.isEditMode = false
                }
                .store(in: &bindings)
            
            confirmButton.tapPublisher
                .receive(on: RunLoop.current)
                .sink { [weak self] _ in
                    guard let `self` = self,
                          let cellVM = self.vm else { return }
                    
                    Task {
                        do {
                            try await cellVM.editComment(postId: cellVM.postId,
                                           commentId: cellVM.id,
                                           comment: self.editTextField.text!)
                            self.convertToNormalMode()
                            self.commentTexts.text = cellVM.editedComment ?? cellVM.comment
                        }
                        catch {
                            print("Error editing comment - \(error.localizedDescription)")
                        }
                    }
                    
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
                            self.profileImageView.image = UIImage(systemName: SFSymbol.defaultProfile)
                            print("Error converting profile image - \(error.localizedDescription)")
                        }
                    }
                }
                .store(in: &bindings)
        }
        
        bindViewToViewModel()
        bindViewModelToView()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        convertToNormalMode()
    }
    
    func resetCell() {
        self.contentView.backgroundColor = .systemGray
        self.profileImageView.image = nil
        self.nicknameLabel.text = nil
        self.commentTexts.text = nil
        self.commentImage.image = nil
        self.createdAtLabel.text = nil
        self.editTextField.text = nil
    }
    
    func resetCellForEditMode() {
        self.contentView.backgroundColor = .systemGray
        convertToEditMode()
    }
    
    func changeCellType(to celltype: CommentCellType) {
        self.type = celltype
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
    
    //MARK: - Change to Edit mode
    private func convertToEditMode() {
        editButton.isHidden = true
        deleteButton.isHidden = true
        commentTexts.isHidden = true
        likeButton.isHidden = true
        commentButton.isHidden = true
        commentImage.isHidden = true
        createdAtLabel.isHidden = true
        
        editTextField.isHidden = false
        cancelButton.isHidden = false
        confirmButton.isHidden = false
        
        setEditTextFieldLayout()
    }
    
    private func convertToNormalMode() {
        editButton.isHidden = false
        deleteButton.isHidden = false
        commentTexts.isHidden = false
        likeButton.isHidden = false
        commentButton.isHidden = false
        commentImage.isHidden = false
        createdAtLabel.isHidden = false
        
        editTextField.isHidden = true
        cancelButton.isHidden = true
        confirmButton.isHidden = true
    }
}


