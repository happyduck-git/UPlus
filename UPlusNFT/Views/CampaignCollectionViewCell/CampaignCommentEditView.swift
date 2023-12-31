//
//  CampaignCommentEditView.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/10.
//

import UIKit
import Combine

final class CampaignCommentEditView: UIView {
    
    // MARK: - Closure
    var cameraBtnDidTapHandler: (() -> Void)?
    var editedCommentDidSavedHandler: (() -> Void)?
    
    // MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    // MARK: - UI Elements
    let editTextField: UITextField = {
        let txtField = UITextField()
        txtField.accessibilityIdentifier = "Comment Edit Txt Fld"
        txtField.borderStyle = .roundedRect
        txtField.translatesAutoresizingMaskIntoConstraints = false
        return txtField
    }()
    
    private let editImage: UIImageView = {
        let imageView = UIImageView()
        imageView.accessibilityIdentifier = "Comment Edit Edit Image"
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .systemGreen
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var cameraButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: SFSymbol.camera), for: .normal)
        button.tintColor = .systemGray
        button.addTarget(self, action: #selector(cameraBtnDidTap), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("취소", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.clipsToBounds = true
        button.layer.cornerRadius = 5
        button.backgroundColor = .systemGray
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let confirmButton: UIButton = {
        let button = UIButton()
        button.setTitle("수정", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.clipsToBounds = true
        button.layer.cornerRadius = 5
        button.backgroundColor = .systemGray
        button.isUserInteractionEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var textFiedlHeightConstraint: NSLayoutConstraint?
    var imageViewHeightConstraint: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setUI()
        self.setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        print("Edit View Height: \(self.frame.height)")
        textFiedlHeightConstraint?.constant = self.frame.height / 5
        imageViewHeightConstraint?.constant = self.frame.height / 1.5
    }
}

// MARK: - Set UI & Layout
extension CampaignCommentEditView {
    private func setUI() {
        self.addSubviews(editTextField,
                         editImage,
                         cameraButton,
                         cancelButton,
                         confirmButton)
    }
    
    private func setLayout() {
        
        NSLayoutConstraint.activate([
            editTextField.topAnchor.constraint(equalTo: self.topAnchor),
            editTextField.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            editTextField.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            editTextField.heightAnchor.constraint(equalToConstant: 30),
            
            editImage.topAnchor.constraint(equalToSystemSpacingBelow: editTextField.bottomAnchor, multiplier: 1),
            editImage.heightAnchor.constraint(equalToConstant: 250),
            editImage.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            editImage.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            confirmButton.topAnchor.constraint(equalToSystemSpacingBelow: editImage.bottomAnchor, multiplier: 1),
            confirmButton.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            confirmButton.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            cancelButton.topAnchor.constraint(equalTo: confirmButton.topAnchor),
            confirmButton.leadingAnchor.constraint(equalToSystemSpacingAfter: cancelButton.trailingAnchor, multiplier: 1),
            cancelButton.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            cameraButton.centerYAnchor.constraint(equalTo: confirmButton.centerYAnchor),
            cameraButton.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            cameraButton.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        textFiedlHeightConstraint = editTextField.heightAnchor.constraint(equalToConstant: self.frame.height / 5)
        imageViewHeightConstraint = editImage.heightAnchor.constraint(equalToConstant: self.frame.height / 1.5)
        textFiedlHeightConstraint?.isActive = true
        imageViewHeightConstraint?.isActive = true
    }
}

extension CampaignCommentEditView {
    @objc func cameraBtnDidTap() {
        self.cameraBtnDidTapHandler?()
    }
}

extension CampaignCommentEditView {
    func configure(with vm: CommentTableViewCellModel) {
        bindings.forEach { $0.cancel() }
        bindings.removeAll()
        
        editTextField.text = vm.comment
        Task {
            guard let image = vm.imagePath,
                  let url = URL(string: image)
            else {
                self.editImage.isHidden = true
                self.layoutIfNeeded()
                return
            }

            do {
                let photo = try await URL.urlToImage(url)
                self.editImage.image = photo
            }
            catch {
                print("Error fetching comment image \(error)")
            }
            
        }
        
        bind(with: vm)
    }
    
    private func bind(with vm: CommentTableViewCellModel) {
        
        func bindViewToViewModel() {
            
            editTextField.textPublisher
                .receive(on: RunLoop.current)
                .removeDuplicates()
                .sink {
                    vm.editedComment = $0
                }
                .store(in: &bindings)
            
            confirmButton.tapPublisher
                .receive(on: RunLoop.current)
                .sink { [weak self] _ in
                    guard let `self` = self else { return }
       
                    Task {
                        do {

                            try await vm.editComment(postId: vm.postId,
                                                     commentId: vm.id,
                                                     commentToEdit: vm.editedComment ?? vm.comment,
                                                     originalImagePath: vm.imagePath,
                                                     imageToEdit: vm.selectedImageToEdit)
                            /*
                            self.convertToNormalMode()
                            self.commentDefaultView.commentTexts.text = vm.editedComment ?? vm.comment
                             */
                            self.editedCommentDidSavedHandler?()
                        }
                        catch {
                            print("Error editing comment - \(error.localizedDescription)")
                        }
                    }
                    
                }
                .store(in: &bindings)
            
            
        }
        
        func bindViewModelToView() {
            vm.$selectedImageToEdit
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    guard let `self` = self else { return }
                    self.editImage.image = $0
                }
                .store(in: &bindings)
        }
        
        bindViewToViewModel()
        bindViewModelToView()
    }
}
