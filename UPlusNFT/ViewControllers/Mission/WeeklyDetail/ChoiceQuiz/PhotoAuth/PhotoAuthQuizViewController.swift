//
//  PhotoAuthQuizViewController.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/08/16.
//

import UIKit
import Combine
import PhotosUI

final class PhotoAuthQuizViewController: BaseMissionViewController {

    //MARK: - Dependency
    private let vm: PhotoAuthQuizViewViewModel
    
    //MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    //MARK: - UI Elements
    private let container: UIImageView = {
       let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = UPlusColor.gray04
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let uploadButton: UIButton = {
       let button = UIButton()
        button.setTitle(MissionConstants.upload, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.titleLabel?.font = .systemFont(ofSize: UPlusFont.h2, weight: .bold)
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let photoPicker: PHPickerViewController = {
        var configuration = PHPickerConfiguration()
        configuration.filter = .any(of: [.images, .livePhotos])
        configuration.selectionLimit = 1
        let picker = PHPickerViewController(configuration: configuration)
        return picker
    }()
    
    private let camera: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.cameraCaptureMode = .photo
        
        return picker
    }()
    
    init(vm: PhotoAuthQuizViewViewModel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setUI()
        self.setLayout()
        self.configure()
        self.bind()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.uploadButton.layer.cornerRadius = self.uploadButton.frame.height / 2
    }
}

extension PhotoAuthQuizViewController {
    
    private func configure() {
        self.checkAnswerButton.setTitle(MissionConstants.submit, for: .normal)
    }
    
    private func bind() {
        self.uploadButton.tapPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let `self` = self else { return }
                self.present(
                    photoPicker,
                    animated: true,
                    completion: nil
                )
            }
            .store(in: &bindings)
        
        self.checkAnswerButton.tapPublisher
            .receive(on: DispatchQueue.main)
            .sink {[weak self] in
                guard let `self` = self else { return }
                
                let vc = WeeklyMissionCompleteViewController(vm: self.vm)
                self.show(vc, sender: self)
            }
            .store(in: &bindings)
        
        self.vm.$selectedImage
            .receive(on: DispatchQueue.main)
            .sink {[weak self] in
                guard let `self` = self else { return }
                self.uploadButton.isHidden = true
                self.container.image = $0
                self.checkAnswerButton.isUserInteractionEnabled = true
                self.checkAnswerButton.backgroundColor = .black
            }
            .store(in: &bindings)
        
        
    }
}


extension PhotoAuthQuizViewController {
    
    private func setUI() {
        self.quizContainer.addSubviews(self.container,
                                       self.uploadButton)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.container.topAnchor.constraint(equalToSystemSpacingBelow: self.quizContainer.topAnchor, multiplier: 5),
            self.container.leadingAnchor.constraint(equalToSystemSpacingAfter: self.quizContainer.leadingAnchor, multiplier: 3),
            self.quizContainer.trailingAnchor.constraint(equalToSystemSpacingAfter: self.container.trailingAnchor, multiplier: 3),
            self.quizContainer.bottomAnchor.constraint(equalToSystemSpacingBelow: self.container.bottomAnchor, multiplier: 5),
            
            self.uploadButton.centerYAnchor.constraint(equalTo: self.container.centerYAnchor),
            self.uploadButton.leadingAnchor.constraint(equalToSystemSpacingAfter: self.container.leadingAnchor, multiplier: 6),
            self.container.trailingAnchor.constraint(equalToSystemSpacingAfter: self.uploadButton.trailingAnchor, multiplier: 6)
        ])
    }
}

// MARK: - PHPickerViewControllerDelegate
extension PhotoAuthQuizViewController: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        let group = DispatchGroup()
        var pickedImage: UIImage?
        
        for result in results {
            group.enter()
            self.loadImageFromItemProvider(itemProvider: result.itemProvider) {  image in
                group.leave()
                pickedImage = image
            }
        }
        
        group.notify(queue: .main) {
            self.vm.selectedImage = pickedImage
        }

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
