//
//  TextFieldCollectionViewCell.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/07/05.
//

import UIKit
import Combine
import PhotosUI

final class TextFieldCollectionViewCell: UICollectionViewCell {
    
    //MARK: - Dependency
    private var textFieldVM: TextFieldCollectionVeiwCellViewModel?
    
    //MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    //MARK: - Property
    var cameraButtonHandler: (() -> Void)?
   
    //MARK: - UI Element
    private let commentTextField: UITextField = {
        let txtField = UITextField()
        txtField.placeholder = PostConstants.inputComment
        txtField.borderStyle = .roundedRect
        txtField.translatesAutoresizingMaskIntoConstraints = false
        return txtField
    }()
    
    private let photoCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        layout.scrollDirection = .horizontal
      
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemGray5
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: UICollectionViewCell.identifier)
        collectionView.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: PhotoCollectionViewCell.identifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let cameraButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: SFSymbol.camera), for: .normal)
        button.tintColor = .systemGray
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let submitButton: UIButton = {
        let button = UIButton()
        button.setTitle(PostConstants.writeButton, for: .normal)
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUI()
        setLayout()
        setDelegate()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

//MARK: - Cell Configure & Bind View Model
extension TextFieldCollectionViewCell {
    
    func configure(with vm: TextFieldCollectionVeiwCellViewModel) {
        self.textFieldVM = vm
        self.bind(vm: vm)
    }
    
    func bind(vm: TextFieldCollectionVeiwCellViewModel) {
        func bindViewToViewModel() {
            self.commentTextField
                .textPublisher
                .removeDuplicates()
                .debounce(for: 0.3, scheduler: RunLoop.main)
                .assign(to: \.commentText, on: vm)
                .store(in: &bindings)
            
            self.cameraButton
                .tapPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    guard let `self` = self else { return }
                    if !vm.isButtonTapped {
                        self.cameraButtonHandler?()
                        vm.isButtonTapped = true
                    }
                }
                .store(in: &bindings)
            
            self.submitButton
                .tapPublisher
                .receive(on: RunLoop.current)
                .sink { _ in
                    vm.saveComment(postId: vm.postId)
                }
                .store(in: &bindings)
            
        }
        
        func bindViewModelToView() {
            vm.$commentText
                .receive(on: DispatchQueue.main)
                .sink { [weak self] text in
                    guard let `self` = self else { return }
                    if !text.isEmpty {
                        self.submitButton.backgroundColor = .black
                        self.submitButton.isUserInteractionEnabled = true
                    } else {
                        self.submitButton.backgroundColor = .systemGray
                        self.submitButton.isUserInteractionEnabled = false
                    }
                }
                .store(in: &bindings)
            
            vm.$selectedImage
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    guard let `self` = self else { return }
                    self.photoCollectionView.reloadData()
                }
                .store(in: &bindings)
        }
        
        bindViewToViewModel()
        bindViewModelToView()
    }
    
}

//MARK: - Set UI & Layout
extension TextFieldCollectionViewCell {
    
    private func setUI() {
        self.contentView.addSubviews(
            self.commentTextField,
            self.photoCollectionView,
            self.cameraButton,
            self.submitButton
        )
    }
    
    private func setLayout() {
        let cellHeight = self.contentView.frame.height
        let cellWidth = self.contentView.frame.width
        NSLayoutConstraint.activate([
            self.commentTextField.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 2),
            self.commentTextField.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 2),
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.commentTextField.trailingAnchor, multiplier: 2),
            self.commentTextField.heightAnchor.constraint(equalToConstant: cellHeight / 4),
            
            self.photoCollectionView.topAnchor.constraint(equalToSystemSpacingBelow: self.commentTextField.bottomAnchor, multiplier: 1),
            self.photoCollectionView.leadingAnchor.constraint(equalTo: self.commentTextField.leadingAnchor),
            self.photoCollectionView.trailingAnchor.constraint(equalTo: self.commentTextField.trailingAnchor),
            self.photoCollectionView.heightAnchor.constraint(equalToConstant: cellHeight / 3),
            
            self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.cameraButton.bottomAnchor, multiplier: 2),
            self.cameraButton.leadingAnchor.constraint(equalTo: self.commentTextField.leadingAnchor),
            self.cameraButton.widthAnchor.constraint(equalToConstant: cellWidth / 10),
            self.cameraButton.heightAnchor.constraint(equalTo: self.cameraButton.widthAnchor),
            
            self.submitButton.centerYAnchor.constraint(equalTo: self.cameraButton.centerYAnchor),
            self.submitButton.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor)
            
        ])
    }
    
    private func setDelegate() {
        self.photoCollectionView.delegate = self
        self.photoCollectionView.dataSource = self
    }
}

//MARK: - CollectionView Delegate & DataSource
extension TextFieldCollectionViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let vm = textFieldVM else { return 0 }
        return vm.numberOfItems()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.identifier, for: indexPath) as? PhotoCollectionViewCell,
            let vm = textFieldVM
        else {
            return UICollectionViewCell()
        }
        let image = vm.imageForItem()
        cell.configure(with: image)
        return cell
    }
}
