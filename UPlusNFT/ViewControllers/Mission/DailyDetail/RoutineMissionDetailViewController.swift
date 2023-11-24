//
//  DailyRoutineMissionDetailViewController.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/27.
//

import UIKit
import PhotosUI
import Combine
import OSLog

protocol RoutineMissionDetailViewControllerDelegate: AnyObject {
    func submitDidTap()
}

final class RoutineMissionDetailViewController: UIViewController {
    
    // MARK: - Dependency
    private let vm: RoutineMissionDetailViewViewModel
    
    // MARK: - Delegate
    weak var delegate: RoutineMissionDetailViewControllerDelegate?
    
    // MARK: - Logger
    private let logger = Logger()
    
    // MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    // MARK: - UI Elements
    private let loadingVC = LoadingViewController()
    
    private var collectionView: UICollectionView?
    private var buttonSectionHeight: CGFloat = 0.4
    
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
    init(vm: RoutineMissionDetailViewViewModel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
        
        self.vm.delegate = self
        self.vm.getAtheleteMissions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UPlusColor.grayBackground
        
        self.setUI()
        self.setLayout()
        self.setDelegate()
        self.bind()
        
        self.addChildViewController(self.loadingVC)
    }
  
}

extension RoutineMissionDetailViewController {
    
    private func bind() {
        func bindViewToViewModel() {
            
        }
        func bindViewModelToView() {
            self.vm.$isFinishedRoutines
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    guard let `self` = self,
                        let collectionView = self.collectionView
                    else { return }
                    
                    collectionView.reloadData()
                }
                .store(in: &bindings)
        }
        
        bindViewToViewModel()
        bindViewModelToView()
    }
    
}

// MARK: - Set UI & Layout & Delegate
extension RoutineMissionDetailViewController {
    private func setUI() {
        let collectionView = self.createCollectionView()
        self.collectionView = collectionView
        view.addSubview(collectionView)
    }
    
    private func setLayout() {
        guard let collectionView = collectionView else { return }
        collectionView.frame = view.bounds
    }
    
    private func setDelegate() {
        self.collectionView?.dataSource = self
        self.collectionView?.delegate = self
        
        self.photoPicker.delegate = self
        self.camera.delegate = self
    }
}

// MARK: - Create Section
extension RoutineMissionDetailViewController {
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout {  sectionIndex, _ in
            return self.createSection(for: sectionIndex)
        }
        return layout
    }
     
    private func createCollectionView() -> UICollectionView {
  
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: self.createLayout()
        )
        
        // 1. Add a header to section#0
        collectionView.register(RoutineStampCollectionViewCellHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: RoutineStampCollectionViewCellHeader.identifier)
        
        // 2. Add stamp section cell
        collectionView.register(UICollectionViewCell.self,
                                forCellWithReuseIdentifier: UICollectionViewCell.identifier)
        collectionView.register(RoutineMissionStampCollectionViewCell.self,
            forCellWithReuseIdentifier: RoutineMissionStampCollectionViewCell.identifier)
        collectionView.register(RoutineCompleteCollectionViewCell.self,
                                forCellWithReuseIdentifier: RoutineCompleteCollectionViewCell.identifier)
        collectionView.register(RoutineMissionBonusStageCollectionViewCell.self,
                                forCellWithReuseIdentifier: RoutineMissionBonusStageCollectionViewCell.identifier)
        collectionView.register(RoutineBonusClosedCollectionViewCell.self,
                                forCellWithReuseIdentifier: RoutineBonusClosedCollectionViewCell.identifier)
        
        collectionView.register(UploadPhotoButtonCollectionViewCell.self,
            forCellWithReuseIdentifier: UploadPhotoButtonCollectionViewCell.identifier)
        
        // 3. Add a footer to section#1
        collectionView.register(UploadPhotoButtonCollectionViewCellFooter.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                withReuseIdentifier: UploadPhotoButtonCollectionViewCellFooter.identifier)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }
    
    private func createSection(for section: Int) -> NSCollectionLayoutSection {
        switch section {
        case 0:
            return self.createStampSectionLayout()
        default:
            return self.createUploadPhotoSectionLayout()
        }
    }
    
    private func createStampSectionLayout() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
        )
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 16, bottom: 5, trailing: 5)
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(0.3)
            ),
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(0.25)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
    
        section.boundarySupplementaryItems = [header]
        return section
    }
    
    private func createUploadPhotoSectionLayout() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
        )

        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(self.buttonSectionHeight)
//                heightDimension: .estimated(150)
            ),
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        
        let footerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(0.5)
            
        )
        let footer = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: footerSize,
            elementKind: UICollectionView.elementKindSectionFooter,
            alignment: .bottom
        )
        
        section.boundarySupplementaryItems = [footer]
        return section
    }
    
}

extension RoutineMissionDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        default:
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch indexPath.section {
        case 0:
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
            
        case 1:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UploadPhotoButtonCollectionViewCell.identifier, for: indexPath) as? UploadPhotoButtonCollectionViewCell else {
                fatalError()
            }
            
            cell.bind(with: self.vm)
            cell.delegate = self
            return cell
            
        default:
            return UICollectionViewCell()
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: RoutineStampCollectionViewCellHeader.identifier,
                for: indexPath
            ) as? RoutineStampCollectionViewCellHeader else {
                return UICollectionReusableView()
            }
            
            header.bind(with: self.vm)
            
            return header

        case UICollectionView.elementKindSectionFooter:
            guard let footer = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: UploadPhotoButtonCollectionViewCellFooter.identifier,
                for: indexPath
            ) as? UploadPhotoButtonCollectionViewCellFooter else {
                return UICollectionReusableView()
            }
            
            footer.bind(with: self.vm)
            return footer
            
        default:
            return UICollectionReusableView()
        }
    }
    
}

extension RoutineMissionDetailViewController: UploadPhotoButtonCollectionViewCellDelegate {

    func uploadButtonDidTap() {
        self.showPhotoBottomAlert()
    }
    
    func editButtonDidTap() {
        self.showPhotoBottomAlert()
    }
    
    func submitButtonDidTap() {
        self.confirmDidTap()
        self.delegate?.submitDidTap()
    }

    private func updateLayout() {
        
//        self.collectionView?.reloadSections(IndexSet(integer: 1))
        
        self.buttonSectionHeight = 0.4 // the new height

        // Create a new layout and set it to the collection view
        let newLayout = self.createLayout()
        UIView.animate(withDuration: 0.1) {
            self.collectionView?.setCollectionViewLayout(newLayout, animated: true)
        }
    }
    
    private func showPhotoBottomAlert() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(
            title: "카메라",
            style: .default,
            handler: { [weak self] _ in
                guard let `self` = self else { return }
                self.present(
                    camera,
                    animated: true,
                    completion: nil
                )
        }))
        
        alert.addAction(UIAlertAction(
            title: "사진, 동영상 선택",
            style: .default,
            handler: { [weak self] _ in
                guard let `self` = self else { return }
                self.present(
                    photoPicker,
                    animated: true,
                    completion: nil
                )
        }))
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        
        self.present(alert, animated: true)
    }
    
    private func confirmDidTap() {
        
        self.addChildViewController(self.loadingVC)
        
        Task {
            do {
                // 1. Save participation info to Storage
                try await self.vm.saveRoutineParticipationStatus()
        
                // 2. Check level update
                let mission = try await self.vm.getTodayMissionInfo()
                
                try await self.vm.checkLevelUpdate(mission: mission)
                
                // 3. Point 수여 complete vc
                let vm = RoutineParticipationViewViewModel(mission: mission)
                let vc = RoutineParticipatedViewController(vm: vm)
                
                DispatchQueue.main.async { [weak self] in
                    self?.loadingVC.removeViewController()
                    guard let `self` = self else { return }
                    self.show(vc, sender: self)
                }
                
            }
            catch {
                // TODO: 오류 발생 alert
                self.logger.error("Error process confirm button -- \(String(describing: error))")
            }
        }
    }
    
}

// MARK: - PHPickerViewControllerDelegate
extension RoutineMissionDetailViewController: PHPickerViewControllerDelegate {
    
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
        self.updateLayout()
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

extension RoutineMissionDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let pickedImage = info[.originalImage] as? UIImage else { return }
        self.vm.selectedImage = pickedImage
        self.updateLayout()
        dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
}

extension RoutineMissionDetailViewController: RoutineMissionDetailViewViewModelDelegate {
    func didRecieveMission() {
        DispatchQueue.main.async {
            self.loadingVC.removeViewController()
        }
    }
}

extension RoutineMissionDetailViewController: RoutineCompleteCollectionViewCellDelegate {
    func redeemButtonDidTap(sender: RoutineCompleteCollectionViewCell) {
        let vc = RoutineCompleteViewController(vm: self.vm)
        vc.delegate = sender
        self.show(vc, sender: self)
    }

}

