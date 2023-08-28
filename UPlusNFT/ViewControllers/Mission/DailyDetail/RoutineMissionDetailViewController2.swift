//
//  RoutineMissionDetailViewController2.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/28.
//

import UIKit
import Combine
import PhotosUI

protocol RoutineMissionDetailViewController2Delegate: AnyObject {
    func submitDidTap()
}

final class RoutineMissionDetailViewController2: UIViewController {
    
    // MARK: - Dependency
    private let vm: RoutineMissionDetailViewViewModel
    
    // MARK: - Delegate
    weak var delegate: RoutineMissionDetailViewController2Delegate?
    
    // MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    // MARK: - UI Elements
    private let loadingVC = LoadingViewController()
    
    // MARK: - Scroll Canvas
    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.isScrollEnabled = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let canvasView: UIView = {
        let view = UIView()
        view.backgroundColor = UPlusColor.blue05
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    //MARK: - UI Elements
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
    
    private let backgroundImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: ImageAsset.routineBackground)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let topContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UPlusColor.blue02
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let topLabel: UILabel = {
        let label = UILabel()
        
        let normalFont: UIFont = .systemFont(ofSize: UPlusFont.body2, weight: .regular)
        let boldFont: UIFont = .systemFont(ofSize: UPlusFont.body2, weight: .bold)
        
        let attributedString = NSMutableAttributedString(string: MissionConstants.routineMissionInfo,
                                                         attributes: [
                                                            .foregroundColor: UPlusColor.blue05,
                                                            .font: normalFont
                                                         ])
        
        if let range = attributedString.string.range(of: MissionConstants.masterCerti) {
            let nsRange = NSRange(range, in: attributedString.string)
            
            attributedString.addAttributes([
                .foregroundColor: UPlusColor.blue05,
                .font: boldFont
            ], range: nsRange)
        }
        
        label.attributedText = attributedString
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let titleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: ImageAsset.routineTitle)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let routineDescLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = MissionConstants.routineDesc
        label.font = .systemFont(ofSize: UPlusFont.body2, weight: .regular)
        label.textColor = UPlusColor.gray03
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = UPlusColor.blue05
        
        collection.register(UICollectionViewCell.self,
                            forCellWithReuseIdentifier: UICollectionViewCell.identifier)
        collection.register(RoutineMissionStampCollectionViewCell.self,
                            forCellWithReuseIdentifier: RoutineMissionStampCollectionViewCell.identifier)
        collection.register(RoutineCompleteCollectionViewCell.self,
                            forCellWithReuseIdentifier: RoutineCompleteCollectionViewCell.identifier)
        collection.register(RoutineMissionBonusStageCollectionViewCell.self,
                            forCellWithReuseIdentifier: RoutineMissionBonusStageCollectionViewCell.identifier)
        collection.register(RoutineBonusClosedCollectionViewCell.self,
                            forCellWithReuseIdentifier: RoutineBonusClosedCollectionViewCell.identifier)
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()
    
    private let pageControl: UIPageControl = {
        let control = UIPageControl()
        control.numberOfPages = 2
        control.backgroundColor = .clear
        control.pageIndicatorTintColor = UPlusColor.gray03
        control.currentPageIndicatorTintColor = UPlusColor.mint03
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    /* Upload View Container */
    private let uploadContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let uploadPhotoView: RoutineUploadPhotoView = {
        let view = RoutineUploadPhotoView()
        view.layer.borderColor = UPlusColor.gray04.cgColor
        view.layer.borderWidth = 1.0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let submitButton: UIButton = {
        let button = UIButton()
        button.setTitle(MissionConstants.submit, for: .normal)
        button.backgroundColor = .white
        button.setTitleColor(UPlusColor.gray03, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: UPlusFont.body1, weight: .bold)
        button.clipsToBounds = true
        button.layer.cornerRadius = 8.0
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    /* Photo View Container */
    private let photoContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let buttonStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 20.0
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let editButton: UIButton = {
        let button = UIButton()
        button.setTitle(MissionConstants.edit, for: .normal)
        button.backgroundColor = .white
        button.setTitleColor(UPlusColor.gray08, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: UPlusFont.body1, weight: .bold)
        button.clipsToBounds = true
        button.layer.cornerRadius = 8.0
        return button
    }()
    
    private let submitButton2: UIButton = {
        let button = UIButton()
        button.setTitle(MissionConstants.submit, for: .normal)
        button.backgroundColor = UPlusColor.mint03
        button.setTitleColor(UPlusColor.gray08, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: UPlusFont.body1, weight: .bold)
        button.clipsToBounds = true
        button.layer.cornerRadius = 8.0
        return button
    }()
    
    private let infoStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 5.0
        stack.distribution = .fillProportionally
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let infoImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: ImageAsset.infoGray)?.withTintColor(UPlusColor.mint03, renderingMode: .alwaysOriginal)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.text = MissionConstants.photoEditWarning
        label.textColor = UPlusColor.mint04
        label.font = .systemFont(ofSize: UPlusFont.caption1, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let infoView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: ImageAsset.routineInfo)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // MARK: - Init
    init(vm: RoutineMissionDetailViewViewModel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
        
        self.vm.delegate = self
        self.vm.getAtheleteMissions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = MissionConstants.startupMaster
        self.view.backgroundColor = UPlusColor.blue05
        
        self.setUI()
        self.setLayout()
        self.setDelegate()
        self.bind()
        
        self.addChildViewController(self.loadingVC)
    }
    
}

// MARK: - Bind
extension RoutineMissionDetailViewController2 {
    
    private func bind() {
        func bindViewToViewModel() {
            
        }
        func bindViewModelToView() {
            self.vm.$isFinishedRoutines
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    guard let `self` = self else { return }
                    
                    self.collectionView.reloadData()
                }
                .store(in: &bindings)
        }
        
        bindViewToViewModel()
        bindViewModelToView()
    }
    
}

// MARK: - Set UI & Layout
extension RoutineMissionDetailViewController2 {
    
    private func setDelegate() {
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        self.photoPicker.delegate = self
        self.camera.delegate = self
    }
    
    private func setUI() {
        self.view.addSubview(self.scrollView)
        self.scrollView.addSubview(self.canvasView)
        
        self.canvasView.addSubviews(self.backgroundImage,
                                    self.topContainerView,
                                    self.titleImageView,
                                    self.routineDescLabel,
                                    self.collectionView,
                                    self.pageControl,
                                    self.uploadContainerView,
                                    self.infoView)
        
        self.uploadContainerView.addSubviews(self.uploadPhotoView,
                                             self.submitButton)
        
        self.topContainerView.addSubviews(self.topLabel)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.scrollView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            self.scrollView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            self.scrollView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.scrollView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            
            self.canvasView.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor),
            self.canvasView.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor),
            self.canvasView.topAnchor.constraint(equalTo: self.scrollView.topAnchor),
            self.canvasView.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor),
            self.canvasView.widthAnchor.constraint(equalTo: self.scrollView.widthAnchor)
        ])
        
        NSLayoutConstraint.activate([
            self.backgroundImage.topAnchor.constraint(equalTo: self.canvasView.topAnchor),
            self.backgroundImage.leadingAnchor.constraint(equalTo: self.canvasView.leadingAnchor),
            self.backgroundImage.trailingAnchor.constraint(equalTo: self.canvasView.trailingAnchor),
            
            self.topContainerView.topAnchor.constraint(equalTo: self.canvasView.topAnchor),
            self.topContainerView.leadingAnchor.constraint(equalTo: self.canvasView.leadingAnchor),
            self.topContainerView.trailingAnchor.constraint(equalTo: self.canvasView.trailingAnchor),
            self.topContainerView.heightAnchor.constraint(equalToConstant: 60),
            
            self.topLabel.centerYAnchor.constraint(equalTo: self.topContainerView.centerYAnchor),
            self.topLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.topContainerView.leadingAnchor, multiplier: 1),
            self.topContainerView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.topLabel.trailingAnchor, multiplier: 1),
            
            self.titleImageView.topAnchor.constraint(equalToSystemSpacingBelow: self.topContainerView.bottomAnchor, multiplier: 3),
            self.titleImageView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.canvasView.leadingAnchor, multiplier: 2),
            self.canvasView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.titleImageView.trailingAnchor, multiplier: 2),
            
            self.routineDescLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.titleImageView.bottomAnchor, multiplier: 1),
            self.routineDescLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.canvasView.leadingAnchor, multiplier: 2),
            self.canvasView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.routineDescLabel.trailingAnchor, multiplier: 1),
            
            self.collectionView.topAnchor.constraint(equalToSystemSpacingBelow: self.routineDescLabel.bottomAnchor, multiplier: 3),
            self.collectionView.leadingAnchor.constraint(equalTo: self.canvasView.leadingAnchor),
            self.collectionView.trailingAnchor.constraint(equalTo: self.canvasView.trailingAnchor),
            self.collectionView.heightAnchor.constraint(equalToConstant: 300),
            
            self.pageControl.topAnchor.constraint(equalToSystemSpacingBelow: self.collectionView.bottomAnchor, multiplier: 1),
            self.pageControl.centerXAnchor.constraint(equalTo: self.collectionView.centerXAnchor),
            
            self.uploadContainerView.topAnchor.constraint(equalToSystemSpacingBelow: self.pageControl.bottomAnchor, multiplier: 3),
            self.uploadContainerView.leadingAnchor.constraint(equalTo: self.canvasView.leadingAnchor),
            self.uploadContainerView.trailingAnchor.constraint(equalTo: self.canvasView.trailingAnchor),
            
            self.infoView.topAnchor.constraint(equalTo: self.uploadContainerView.bottomAnchor),
            self.infoView.leadingAnchor.constraint(equalTo: self.canvasView.leadingAnchor),
            self.infoView.trailingAnchor.constraint(equalTo: self.canvasView.trailingAnchor),
            self.infoView.bottomAnchor.constraint(equalTo: self.canvasView.bottomAnchor)
            
        ])
        
        NSLayoutConstraint.activate([
            self.uploadPhotoView.topAnchor.constraint(equalToSystemSpacingBelow: self.uploadContainerView.topAnchor, multiplier: 2),
            self.uploadPhotoView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.uploadContainerView.leadingAnchor, multiplier: 2),
            self.uploadContainerView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.uploadPhotoView.trailingAnchor, multiplier: 2),
            
            self.submitButton.topAnchor.constraint(equalToSystemSpacingBelow: self.uploadPhotoView.bottomAnchor, multiplier: 2),
            self.submitButton.heightAnchor.constraint(equalToConstant: LoginConstants.buttonHeight),
            self.submitButton.leadingAnchor.constraint(equalTo: self.uploadPhotoView.leadingAnchor),
            self.submitButton.trailingAnchor.constraint(equalTo: self.uploadPhotoView.trailingAnchor),
            self.uploadContainerView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.submitButton.bottomAnchor, multiplier: 2)
        ])
    }
}



extension RoutineMissionDetailViewController2: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
            guard let isFinished = self.vm.isFinishedRoutines else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UICollectionViewCell.identifier, for: indexPath)
                return cell
            }
            
            if indexPath.item == 0 {
                if isFinished {
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RoutineCompleteCollectionViewCell.identifier, for: indexPath) as? RoutineCompleteCollectionViewCell else {
                        fatalError()
                    }
                    cell.delegate = self
                    
                    return cell
                } else {
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RoutineMissionStampCollectionViewCell.identifier, for: indexPath) as? RoutineMissionStampCollectionViewCell else {
                        fatalError()
                    }
                    
                    cell.bind(with: self.vm)

                    return cell
                }
 
            } else {
               
                if isFinished {
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RoutineMissionBonusStageCollectionViewCell.identifier, for: indexPath) as? RoutineMissionBonusStageCollectionViewCell else {
                        return UICollectionViewCell()
                    }
                    cell.bind(with: self.vm)
                    
                    return cell
                } else {
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RoutineBonusClosedCollectionViewCell.identifier, for: indexPath) as? RoutineBonusClosedCollectionViewCell else {
                        return UICollectionViewCell()
                    }
           
                    return cell
                }
            }
        
    }
   
}
extension RoutineMissionDetailViewController2: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.canvasView.frame.width, height: self.collectionView.frame.height)
    }
}


extension RoutineMissionDetailViewController2: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let pickedImage = info[.originalImage] as? UIImage else { return }
        self.vm.selectedImage = pickedImage

        dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
}

extension RoutineMissionDetailViewController2: RoutineCompleteCollectionViewCellDelegate {
    func redeemButtonDidTap(sender: RoutineCompleteCollectionViewCell) {
        let vc = RoutineCompleteViewController(vm: self.vm)
        vc.delegate = sender
        self.show(vc, sender: self)
    }

}

extension RoutineMissionDetailViewController2: RoutineMissionDetailViewViewModelDelegate {
    func didRecieveMission() {
        DispatchQueue.main.async {
            self.loadingVC.removeViewController()
        }
    }
}

// MARK: - PHPickerViewControllerDelegate
extension RoutineMissionDetailViewController2: PHPickerViewControllerDelegate {
    
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

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct RoutineMissionDetailViewController2_Preview: PreviewProvider {
    static var previews: some View {
        let vm = RoutineMissionDetailViewViewModel(missionType: .dailyExpGoodWorker)
        RoutineMissionDetailViewController2(vm: vm).toPreview()
    }
}
#endif
