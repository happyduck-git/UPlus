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
    private let uploadButton: UIButton = {
        let button = UIButton()
        button.setTitle(MissionConstants.upload, for: .normal)
        button.setTitleColor(UPlusColor.gray06, for: .normal)
        button.backgroundColor = .white
        button.titleLabel?.font = .systemFont(ofSize: UPlusFont.h2, weight: .bold)
        button.setImage(UIImage(named: ImageAsset.uploadGray), for: .normal)
        button.alignVerticalCenter()
        button.clipsToBounds = true
        button.layer.cornerRadius = 8.0
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let uploadedPhotoView: UIImageView = {
        let imageView = UIImageView()
        imageView.isHidden = true
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8.0
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let infoStack: UIStackView = {
        let stack = UIStackView()
        stack.isHidden = true
        stack.axis = .horizontal
        stack.spacing = 5.0
        stack.distribution = .fillProportionally
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let infoImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: ImageAsset.infoRed)
        return imageView
    }()
    
    private let infoText: UILabel = {
        let label = UILabel()
        label.text = MissionConstants.noResubmitDesc
        label.font = .systemFont(ofSize: UPlusFont.body2, weight: .regular)
        label.textColor = UPlusColor.orange01
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let editButton: UIButton = {
        let button = UIButton()
        button.isHidden = true
        button.setTitleColor(UPlusColor.gray08, for: .normal)
        button.setTitle(MissionConstants.edit, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: UPlusFont.body1, weight: .bold)
        button.backgroundColor = UPlusColor.mint01
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let goToQuizButton: UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.setTitle(MissionConstants.goToQuiz, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UPlusColor.gray03
        button.titleLabel?.font = .systemFont(ofSize: UPlusFont.h2, weight: .bold)
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
    
    // MARK: - Init
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
        self.setDelegate()
        
        self.configure()
        self.bind()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.editButton.layer.cornerRadius = self.editButton.frame.height / 2
        self.goToQuizButton.layer.cornerRadius = self.goToQuizButton.frame.height / 2
    }
}

// MARK: - Configure
extension PhotoAuthQuizViewController {
    
    private func configure() {
        self.titleLabel.text = self.vm.mission.missionContentTitle
        self.quizLabel.text = self.vm.mission.missionContentText
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
        
        self.editButton.tapPublisher
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
            .sink { [weak self] in
                guard let `self` = self else { return }
                
                var vc: BaseMissionCompletedViewController?
                
                switch self.vm.type {
                case .event:
                    vc = EventCompletedViewController(vm: self.vm)
                    vc?.delegate = self
                case .weekly:
                    vc = WeeklyMissionCompleteViewController(vm: self.vm)
                    vc?.delegate = self
                }
                
                guard let vc = vc else { return }
                self.navigationController?.modalPresentationStyle = .fullScreen
                self.show(vc, sender: self)
            }
            .store(in: &bindings)
        
        self.vm.$selectedImage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in
                guard let `self` = self else { return }
               
                if image != nil {
                    self.uploadButton.isHidden = true
                    self.uploadedPhotoView.isHidden = false
                    self.infoStack.isHidden = false
                    self.editButton.isHidden = false
                    
                    self.uploadedPhotoView.image = image
                    
                    self.checkAnswerButton.isUserInteractionEnabled = true
                    self.checkAnswerButton.backgroundColor = .black
                } else {
                    print("No image")
                }
            }
            .store(in: &bindings)
        
        
    }
}

// MARK: - Set Delegate
extension PhotoAuthQuizViewController {
    private func setDelegate() {
        self.photoPicker.delegate = self
        self.camera.delegate = self
    }
}

// MARK: - Set UI & Layout
extension PhotoAuthQuizViewController {
    
    private func setUI() {
        self.quizContainer.addSubviews(self.uploadButton,
                                       self.uploadedPhotoView,
                                       self.infoStack,
                                       self.editButton)
        
        self.infoStack.addArrangedSubviews(self.infoImage,
                                           self.infoText)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.uploadButton.topAnchor.constraint(equalToSystemSpacingBelow: self.quizContainer.topAnchor, multiplier: 3),
            self.uploadButton.heightAnchor.constraint(equalToConstant: self.view.frame.height / 5),
            self.uploadButton.leadingAnchor.constraint(equalToSystemSpacingAfter: self.quizContainer.leadingAnchor, multiplier: 2),
            self.quizContainer.trailingAnchor.constraint(equalToSystemSpacingAfter: self.uploadButton.trailingAnchor, multiplier: 2),
            
            self.uploadedPhotoView.topAnchor.constraint(equalToSystemSpacingBelow: self.quizContainer.topAnchor, multiplier: 3),
            self.uploadedPhotoView.heightAnchor.constraint(equalToConstant: self.view.frame.height / 3),
            self.uploadedPhotoView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.quizContainer.leadingAnchor, multiplier: 2),
            self.quizContainer.trailingAnchor.constraint(equalToSystemSpacingAfter: self.uploadedPhotoView.trailingAnchor, multiplier: 2),
            
            self.infoStack.topAnchor.constraint(equalToSystemSpacingBelow: self.uploadedPhotoView.bottomAnchor, multiplier: 1),
            self.infoStack.centerXAnchor.constraint(equalTo: self.quizContainer.centerXAnchor),
            
            self.editButton.topAnchor.constraint(equalToSystemSpacingBelow: self.infoStack.bottomAnchor, multiplier: 1),
            self.editButton.leadingAnchor.constraint(equalToSystemSpacingAfter: self.uploadedPhotoView.leadingAnchor, multiplier: 4),
            self.uploadedPhotoView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.editButton.trailingAnchor, multiplier: 4),
            self.editButton.heightAnchor.constraint(equalToConstant: 46)
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

extension PhotoAuthQuizViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let pickedImage = info[.originalImage] as? UIImage else { return }
        self.vm.selectedImage = pickedImage
        dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
}

extension PhotoAuthQuizViewController: BaseMissionCompletedViewControllerDelegate {
    func redeemDidTap() {
        self.delegate?.redeemDidTap(vc: self)
    }
}
