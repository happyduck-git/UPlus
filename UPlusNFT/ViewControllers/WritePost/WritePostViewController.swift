//
//  WritePostViewController.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/06/29.
//

import UIKit
import PhotosUI
import FirebaseAuth
import FirebaseStorage
import Nuke
import Combine

final class WritePostViewController: UIViewController {
    
    enum `Type` {
        case newPost
        case editPost
    }

    private var type: Type
    private var vm: WritePostViewViewModel
    private let firestoreRepository = FirestoreManager.shared
    private var bindings = Set<AnyCancellable>()
    
    private let pickedImage: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .systemGray4
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
       let label = UILabel()
        label.text = WritePostConstants.title
        label.textColor = .black
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let titleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = WritePostConstants.titlePlaceholder
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .systemGray6
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let contentLabel: UILabel = {
       let label = UILabel()
        label.text = WritePostConstants.content
        label.textColor = .black
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let contentTextView: UITextView = {
        let textView = UITextView()
        textView.text = WritePostConstants.contentPlaceholder
        textView.textColor = .systemGray
        textView.clipsToBounds = true
        textView.layer.cornerRadius = 5
        textView.backgroundColor = .systemGray6
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private lazy var submitButton: UIButton = {
        let button = UIButton()
        button.setTitle(WritePostConstants.submitButtonTitle, for: .normal)
        button.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
        //TODO: Inactivate when picture location is not valid.
        button.backgroundColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let photoPicker: PHPickerViewController = {
        var configuration = PHPickerConfiguration()
        configuration.filter = .any(of: [.images, .livePhotos])
        configuration.selectionLimit = 0
        let picker = PHPickerViewController(configuration: configuration)
        return picker
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
    
    // MARK: - Init
    init(type: Type, vm: WritePostViewViewModel) {
        self.type = type
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "글 작성하기"
        
        setUI()
        setLayout()
        setNavItem()
        setDelegate()
        configure()
        bind()
        
        hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Set UI & Layout
    private func setUI() {
        view.addSubviews(
            titleLabel,
            titleTextField,
            contentLabel,
            contentTextView,
            photoCollectionView,
            submitButton
        )
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
//            pickedImage.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 3),
//            pickedImage.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 2),
//            view.trailingAnchor.constraint(equalToSystemSpacingAfter: pickedImage.trailingAnchor, multiplier: 2),
            
            titleLabel.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 3),
            titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 3),
            
            titleTextField.topAnchor.constraint(equalToSystemSpacingBelow: titleLabel.bottomAnchor, multiplier: 2),
            titleTextField.heightAnchor.constraint(equalToConstant: 50),
            titleTextField.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            view.trailingAnchor.constraint(equalToSystemSpacingAfter: titleTextField.trailingAnchor, multiplier: 3),
            
            contentLabel.topAnchor.constraint(equalToSystemSpacingBelow: titleTextField.bottomAnchor, multiplier: 2),
            contentLabel.leadingAnchor.constraint(equalTo: titleTextField.leadingAnchor),
            contentTextView.topAnchor.constraint(equalToSystemSpacingBelow: contentLabel.bottomAnchor, multiplier: 2),
            contentTextView.leadingAnchor.constraint(equalTo: titleTextField.leadingAnchor),
            contentTextView.trailingAnchor.constraint(equalTo: titleTextField.trailingAnchor),
            contentTextView.heightAnchor.constraint(equalToConstant: 200),
            
            photoCollectionView.topAnchor.constraint(equalToSystemSpacingBelow: contentTextView.bottomAnchor, multiplier: 2),
            photoCollectionView.heightAnchor.constraint(equalToConstant: 80),
            photoCollectionView.leadingAnchor.constraint(equalTo: titleTextField.leadingAnchor),
            photoCollectionView.trailingAnchor.constraint(equalTo: titleTextField.trailingAnchor),
            
            submitButton.topAnchor.constraint(equalToSystemSpacingBelow: photoCollectionView.bottomAnchor, multiplier: 2),
            submitButton.leadingAnchor.constraint(equalTo: titleTextField.leadingAnchor),
            submitButton.trailingAnchor.constraint(equalTo: titleTextField.trailingAnchor)
        ])
    }
    
    private func setNavItem() {
        let libraryButton = UIBarButtonItem(
            image: UIImage(systemName: SFSymbol.photoLibrary),
            style: .done,
            target: self,
            action: #selector(openPhotoLibrary)
        )
        let photoButton = UIBarButtonItem(
            image: UIImage(systemName: SFSymbol.cameraViewFinder),
            style: .done,
            target: self,
            action: #selector(openCamera)
        )
        navigationItem.setRightBarButtonItems([libraryButton, photoButton], animated: true)
    }
    
    private func setDelegate() {
        photoPicker.delegate = self
        contentTextView.delegate = self
        photoCollectionView.delegate = self
        photoCollectionView.dataSource = self
    }
    
    private func configure() {
        let imageUrl = vm.imageUrl
        let titleText = vm.titleText
        let postText = vm.postText
        
        guard let urlString = imageUrl,
              let url = URL(string: urlString)
        else { return }
        
        Task {
            let image = try await ImagePipeline.shared.image(for: url)
            self.pickedImage.image = image
        }
        
        titleTextField.text = titleText
        contentTextView.text = postText
    }
    
    // MARK: - Private
    @objc private func keyboardWillShow(_ notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        self.view.frame.origin.y = self.titleTextField.frame.height + self.contentTextView.frame.height - keyboardSize.height
    }
    
    @objc private func keyboardWillHide(_ notification: NSNotification) {
        self.view.frame.origin.y = 0
    }
    
    @objc private func openPhotoLibrary() {
        self.present(photoPicker, animated: true, completion: nil)
    }
    
    @objc private func openCamera() {
        
    }
    
    private func bind() {
        
        func bindViewToViewModel() {
            
            self.titleTextField
                .textPublisher
                .removeDuplicates()
                .debounce(for: 0.3, scheduler: RunLoop.main)
                .assign(to: \.titleText, on: vm)
                .store(in: &bindings)
            
            self.contentTextView
                .textPublisher
                .removeDuplicates()
                .debounce(for: 0.3, scheduler: RunLoop.main)
                .assign(to: \.postText, on: vm)
                .store(in: &bindings)
            
        }
        
        func bindViewModelToView() {
            self.vm.$selectedImages
                .receive(on: DispatchQueue.main)
                .sink { [weak self] images in
                    guard let `self` = self else { return }
                    self.photoCollectionView.reloadData()
                }
                .store(in: &bindings)
        }
        
        bindViewToViewModel()
        bindViewModelToView()
    }
    
    @objc private func submitButtonTapped() {
        
        Task {
            if type == .newPost {
                
                if let titleText = self.titleTextField.text,
                   titleText.isEmpty
                   || self.contentTextView.text.isEmpty {
                    print("Text view cannot be empty.")
                    return
                } else {
                    let imageData = self.vm.selectedImages.compactMap {
                        return $0?.jpegData(compressionQuality: 0.75)
                    }
                    let imageUrls = await vm.saveImages(imageData)
                    self.vm.savePost(imageUrls: imageUrls)
                    
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }

        /*
         else {
            // TODO: Type이 editPost인 경우에는 storage에 저장된 이미지 삭제, post는 업데이트
            // 1. Check if any changes in image or text
            if vm.isTextChanged {
                Task {
                    guard let postId = vm.postId else { return }
                    try await firestoreRepository.updatePost(
                        postId: postId,
                        postText: self.textView.text
                    )
                }
                
            } else {
                print("There is no change in post texts.")
            }
            
        }
        */
    }
    
}

extension WritePostViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return vm.numberOfItems(at: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.identifier, for: indexPath) as? PhotoCollectionViewCell else { return UICollectionViewCell() }
        
        if indexPath.section == 0 {
            cell.setCellType(.camera)
            cell.configure(with: UIImage(systemName: SFSymbol.cameraFill))
        } else {
            cell.setCellType(.photo)
            let photo = vm.selectedImages[indexPath.row]
            cell.configure(with: photo)
            cell.buttonTapAction = { [weak self] in
                self?.vm.selectedImages.remove(at: indexPath.row)
            }
        }
        return cell
    }
 
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            self.openPhotoLibrary()
        } else {
            
        }
    }
}

// MARK: - PHPickerViewControllerDelegate
extension WritePostViewController: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        let group = DispatchGroup()
        var images: [UIImage?] = []
        
        for result in results {
            group.enter()
            self.loadImageFromItemProvider(itemProvider: result.itemProvider) { [weak self] image in
                guard let `self` = self else { return }
                group.leave()
                images.append(image)
                self.vm.selectedImages.append(image)
            }
        }
        
        group.notify(queue: .main) {
            print("Imgs converted: \(images)")
//            self.vm.selectedImages = images
            
            guard let firstImage = images.first else { return }
            DispatchQueue.main.async {
                self.pickedImage.image = firstImage
            }
        }
        
        /*
        guard let itemProvider = results.first?.itemProvider else { return }
        self.loadImageFromItemProvider(itemProvider: itemProvider) { image in
            DispatchQueue.main.async {
                self.pickedImage.image = image
            }
        }
         */
        picker.dismiss(animated: true)
    }
    
    /// Change itemProvider to UIImage
    /// - Parameters:
    ///   - itemProvider: item provider instance to convert
    ///   - completion: callback
    private func loadImageFromItemProvider(itemProvider: NSItemProvider, completion: @escaping (UIImage?) -> Void) {
        if itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                guard error == nil else {
                    print("Error loading object from itemProvider: " + String(describing: error?.localizedDescription))
                    return
                }
                guard let image = image as? UIImage else {
                    return
                }
                completion(image)
            }
        } else {
            completion(nil)
        }
    }
    
}

//MARK: - TextView Placeholder
extension WritePostViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if contentTextView.text == WritePostConstants.contentPlaceholder {
            contentTextView.text = nil
            contentTextView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if contentTextView.text.isEmpty {
            contentTextView.text = WritePostConstants.contentPlaceholder
            contentTextView.textColor = .lightGray
        }
    }
    
}

extension UITextView {
    
    func setPlaceholder(_ placeholder: String) {
        self.textColor = .systemGray
        self.text = placeholder
    }
    
}
