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
    
    private let titleTextView: UITextView = {
        let textView = UITextView()
        textView.layer.borderColor = UIColor.systemGray.cgColor
        textView.layer.borderWidth = 1.0
        textView.backgroundColor = .systemGray2
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private let contentTextView: UITextView = {
        let textView = UITextView()
        textView.layer.borderColor = UIColor.systemGray.cgColor
        textView.layer.borderWidth = 1.0
        textView.backgroundColor = .systemGray2
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private lazy var submitButton: UIButton = {
        let button = UIButton()
        button.setTitle(WritePostConstants.submitButtonTitle, for: .normal)
        button.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
        //TODO: Inactivate when picture location is not valid.
        button.backgroundColor = .systemBlue
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
            pickedImage,
            titleTextView,
            contentTextView,
            submitButton
        )
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            pickedImage.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 3),
            pickedImage.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 2),
            view.trailingAnchor.constraint(equalToSystemSpacingAfter: pickedImage.trailingAnchor, multiplier: 2),
            
            titleTextView.topAnchor.constraint(equalToSystemSpacingBelow: pickedImage.bottomAnchor, multiplier: 2),
            titleTextView.heightAnchor.constraint(equalToConstant: 50),
            titleTextView.leadingAnchor.constraint(equalTo: pickedImage.leadingAnchor),
            titleTextView.trailingAnchor.constraint(equalTo: pickedImage.trailingAnchor),
            
            contentTextView.topAnchor.constraint(equalToSystemSpacingBelow: titleTextView.bottomAnchor, multiplier: 2),
            contentTextView.leadingAnchor.constraint(equalTo: pickedImage.leadingAnchor),
            contentTextView.trailingAnchor.constraint(equalTo: pickedImage.trailingAnchor),
            contentTextView.heightAnchor.constraint(equalToConstant: 200),
            
            submitButton.topAnchor.constraint(equalToSystemSpacingBelow: contentTextView.bottomAnchor, multiplier: 2),
            submitButton.trailingAnchor.constraint(equalTo: pickedImage.trailingAnchor),
            view.bottomAnchor.constraint(equalToSystemSpacingBelow: submitButton.bottomAnchor, multiplier: 2)
        ])
    }
    
    private func setNavItem() {
        let libraryButton = UIBarButtonItem(
            image: UIImage(systemName: "photo.on.rectangle.angled"),
            style: .done,
            target: self,
            action: #selector(openPhotoLibrary)
        )
        let photoButton = UIBarButtonItem(
            image: UIImage(systemName: "camera.viewfinder"),
            style: .done,
            target: self,
            action: #selector(openCamera)
        )
        navigationItem.setRightBarButtonItems([libraryButton, photoButton], animated: true)
    }
    
    private func setDelegate() {
        photoPicker.delegate = self
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
        
        titleTextView.text = titleText
        contentTextView.text = postText
    }
    
    // MARK: - Private
    @objc private func keyboardWillShow(_ notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        self.view.frame.origin.y = 0 - keyboardSize.height
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
            
            self.titleTextView
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
            
        }
        
        bindViewToViewModel()
        bindViewModelToView()
    }
    
    @objc private func submitButtonTapped() {
        
        Task {
            if type == .newPost {
                
                if self.titleTextView.text.isEmpty || self.contentTextView.text.isEmpty {
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

extension WritePostViewController: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        let group = DispatchGroup()
        var images: [UIImage?] = []
        
        for result in results {
            group.enter()
            self.loadImageFromItemProvider(itemProvider: result.itemProvider) { image in
                group.leave()
                images.append(image)
            }
        }
        
        group.notify(queue: .main) {
            print("Imgs converted: \(images)")
            self.vm.selectedImages = images
            
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
