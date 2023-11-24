//
//  RecommentTextInputCollectionViewCell.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/11.
//

import UIKit
import Combine
import FirebaseFirestore

final class RecommentTextInputCollectionViewCell: UICollectionViewCell {
    
    private let firestoreManager = FirestoreManager.shared
    
    // MARK: - Dependency
    private var vm: CommentTableViewCellModel?
    
    // MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    private var isBound: Bool = false
    
    // MARK: - UI Elements
    private let recommentTextField: UITextField = {
        let txtField = UITextField()
        txtField.placeholder = PostConstants.inputComment
        txtField.borderStyle = .roundedRect
        txtField.translatesAutoresizingMaskIntoConstraints = false
        return txtField
    }()
    
    private let submitButton: UIButton = {
        let button = UIButton()
        button.setTitle(PostConstants.writeButton, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGray
        button.isUserInteractionEnabled = false
        button.clipsToBounds = true
        button.layer.cornerRadius = 5
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUI()
        setLayout()
       
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Configuration & Binding
extension RecommentTextInputCollectionViewCell {
    
    func configure(with vm: CommentTableViewCellModel) {
        bindings.forEach { $0.cancel() }
        bindings.removeAll()
        
        self.vm = vm
        self.bind(with: vm)
    }
    
    private func bind(with vm: CommentTableViewCellModel) {
        recommentTextField.textPublisher
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] in
                guard let `self` = self else { return }
                let color: UIColor = $0.isEmpty ? .systemGray : .black
                let userInteraction: Bool = $0.isEmpty ? false : true
                
                self.submitButton.isUserInteractionEnabled = userInteraction
                self.submitButton.backgroundColor = color
            }
            .store(in: &bindings)
        
        submitButton.tapPublisher
            .receive(on: DispatchQueue.main)
            .sink {[weak self] _ in
                guard let `self` = self,
                      let text = recommentTextField.text,
                      let userId = UserDefaults.standard.string(forKey: UserDefaultsConstants.userId)
                else { return }
             // TODO: Add save comment function of firestoreManager.
                Task {
                    do {
                        let recomment = Recomment(recommentAuthorUid: userId,
                                                  recommentContentText: text,
                                                  recommentCreatedTime: Timestamp(),
                                                  recommentId: UUID().uuidString)
                        try self.firestoreManager.saveRecomment(postId: vm.postId,
                                                                      commentId: vm.id,
                                                                      recomment: recomment)
                    }
                    catch {
                        print("Error saving recomment -- \(error.localizedDescription)")
                    }
                }
 
            }
            .store(in: &bindings)
    }
}

// MARK: - Set UI & Layout
extension RecommentTextInputCollectionViewCell {
    private func setUI() {
        self.addSubviews(recommentTextField,
                         submitButton)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            recommentTextField.topAnchor.constraint(equalToSystemSpacingBelow: self.topAnchor, multiplier: 1),
            recommentTextField.leadingAnchor.constraint(equalToSystemSpacingAfter: self.leadingAnchor, multiplier: 1),
            self.trailingAnchor.constraint(equalToSystemSpacingAfter: self.recommentTextField.trailingAnchor, multiplier: 1),

            submitButton.topAnchor.constraint(equalToSystemSpacingBelow: self.recommentTextField.bottomAnchor, multiplier: 1),
            submitButton.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.bottomAnchor.constraint(equalToSystemSpacingBelow: self.submitButton.bottomAnchor, multiplier: 1)
        ])
    }
}
