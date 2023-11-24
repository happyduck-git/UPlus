//
//  CampainPostViewController.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/07/03.
//

import UIKit
import Combine
import PhotosUI

protocol CampaignPostViewControllerDelegate: AnyObject {
    func likebuttonDidTap(at indexPath: IndexPath, isLiked: Bool)
}

final class CampaignPostViewController: UIViewController {
    
    // MARK: - Dependency
    private let campaignPostVM: CampaignPostViewViewModel
    
    // MARK: - Delegate
    weak var delegate: CampaignPostViewControllerDelegate?
    var indexPath: IndexPath?
    
    // MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    //MARK: - Property
    private var collectionView: UICollectionView?
    private let postType: PostType
    private var activeView: UIView?
    private var activeCellSection: Int?
    
    private let photoPicker: PHPickerViewController = {
        var configuration = PHPickerConfiguration()
        configuration.filter = .any(of: [.images, .livePhotos])
        configuration.selectionLimit = 1
        let picker = PHPickerViewController(configuration: configuration)
        return picker
    }()
    
    // MARK: - Init
    init(
        postType: PostType,
        campaignPostVM: CampaignPostViewViewModel
    ) {
        self.postType = postType
        self.campaignPostVM = campaignPostVM
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Life Cycle
extension CampaignPostViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setUI()
        setLayout()
        setDelegate()
        
        bind()
        
        hideKeyboardWhenTappedAround()
    }
}

// MARK: - Set UI & Layout
extension CampaignPostViewController {
    private func setUI() {
        let collectionView = self.createCollectionView()
        self.collectionView = collectionView
        view.addSubview(collectionView)
    }
    
    private func setLayout() {
        guard let collectionView = collectionView else { return }
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setDelegate() {
        collectionView?.delegate = self
        collectionView?.dataSource = self
        photoPicker.delegate = self
    }
}

// MARK: - Bind ViewModel
extension CampaignPostViewController {
    
    private func bind() {
        func bindViewToViewModel() {}
        
        func bindViewModelToView() {
            campaignPostVM.post.$commentsTableDatasource
                .receive(on: DispatchQueue.main)
                .sink { [weak self] data in
                    guard let `self` = self else { return }
                    if !data.isEmpty {
                        self.collectionView?.reloadData()
                    }
                }
                .store(in: &bindings)
 
        }
        
        bindViewToViewModel()
        bindViewModelToView()
    }
    
}

// MARK: - Create CollectionView
extension CampaignPostViewController {
  
    private func createCollectionView() -> UICollectionView {
        let layout = UICollectionViewCompositionalLayout {  sectionIndex, _ in
            return self.createSection(for: sectionIndex)
        }
        
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        
        // Register section header
        collectionView.register(
            PostDetailCollectionViewHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: PostDetailCollectionViewHeader.identifier
        )
        collectionView.register(
            UICollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: UICollectionReusableView.identifier
        )

        // Register cell
        collectionView.register(
            UICollectionViewCell.self,
            forCellWithReuseIdentifier: UICollectionViewCell.identifier
        )

        collectionView.register(
            DefaultCollectionViewCell.self,
            forCellWithReuseIdentifier: DefaultCollectionViewCell.identifier
        )
        
        collectionView.register(
            PostCommentCollectionViewCell.self,
            forCellWithReuseIdentifier: PostCommentCollectionViewCell.identifier
        )
        
        collectionView.register(
            TextFieldCollectionViewCell.self,
            forCellWithReuseIdentifier: TextFieldCollectionViewCell.identifier
        )
        
        collectionView.register(
            RecommentTextInputCollectionViewCell.self,
            forCellWithReuseIdentifier: RecommentTextInputCollectionViewCell.identifier
        )
        
        switch self.postType {
        case .article:
            break
        case .multipleChoice:
            collectionView.register(
                MultipleQuizCollectionViewCell.self,
                forCellWithReuseIdentifier: MultipleQuizCollectionViewCell.identifier
            )
        case .shortForm:
            collectionView.register(
                ShortQuizCollectionViewCell.self,
                forCellWithReuseIdentifier: ShortQuizCollectionViewCell.identifier
            )
        case .bestComment:
            collectionView.register(
                CommentCampaignCollectionViewCell.self,
                forCellWithReuseIdentifier: CommentCampaignCollectionViewCell.identifier
            )
        }
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }
    
    private func createSection(for section: Int) -> NSCollectionLayoutSection {
        switch campaignPostVM.postType {
        case .article:
            switch section {
            case 0:
                return createCommentInputSectionLayout()
            default:
                return createPostSectionLayout()
            }
            
        default:
            switch section {
            case 0:
                return createCampaignSectionLayout()
            case 1:
                return createCommentInputSectionLayout()
            default:
                return createPostSectionLayout()
            }
        }
    }
    
    private func createCampaignSectionLayout() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
        )

        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(0.5)
            ),
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        
        return section
    }
    
    private func createCommentInputSectionLayout() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(230)
            )
        )

        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(230)
            ),
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(150)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    
    private func createPostSectionLayout() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(150)
            )
        )
        
        let zeroSpacing = NSCollectionLayoutSpacing.fixed(0)
        let spacing = NSCollectionLayoutSpacing.fixed(2)
        item.edgeSpacing = NSCollectionLayoutEdgeSpacing(leading: zeroSpacing, top: spacing, trailing: zeroSpacing, bottom: zeroSpacing)
        
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(200)
            ),
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        
        return section
    }
}

// MARK: - UICollectionView Delegate & DataSource
extension CampaignPostViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let numberOfSections = campaignPostVM.numberOfSections()
        switch campaignPostVM.postType {
        case .article:
            campaignPostVM.itemsMode.append(contentsOf: Array(repeating: false, count: numberOfSections - 1))
        default:
            campaignPostVM.itemsMode = Array(repeating: false, count: numberOfSections - 2)
        }
        
        return numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
            switch self.postType {
            case .article:
                switch indexPath.section {
                case 0:
                    return self.makeTextFieldCell(collectionView, cellForItemAt: indexPath)
                default:
                    return self.makePostCell(collectionView, cellForItemAt: indexPath)
                }
                
            case .multipleChoice:
                switch indexPath.section {
                case 0:
                    return self.makeCampaignCell(collectionView, cellForItemAt: indexPath, postType: self.postType)
                case 1:
                    return self.makeTextFieldCell(collectionView, cellForItemAt: indexPath)
                default:
                    return self.makePostCell(collectionView, cellForItemAt: indexPath)
                }
          
            case .shortForm:
                switch indexPath.section {
                case 0:
                    return self.makeCampaignCell(collectionView, cellForItemAt: indexPath, postType: self.postType)
                case 1:
                    return self.makeTextFieldCell(collectionView, cellForItemAt: indexPath)
                default:
                    return self.makePostCell(collectionView, cellForItemAt: indexPath)
                }
         
            case .bestComment:
                switch indexPath.section {
                case 0:
                    return self.makeCampaignCell(collectionView, cellForItemAt: indexPath, postType: self.postType)
                case 1:
                    return self.makeTextFieldCell(collectionView, cellForItemAt: indexPath)
                default:
                    return self.makePostCell(collectionView, cellForItemAt: indexPath)
                }
            }
    }
    
    private func makeCampaignCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath, postType: PostType) -> UICollectionViewCell {
        guard let campaignVM = campaignPostVM.campaign else {
            return UICollectionViewCell()
        }
        
        switch postType {
        case .article:
            return UICollectionViewCell()
        case .multipleChoice:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MultipleQuizCollectionViewCell.identifier, for: indexPath) as? MultipleQuizCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.bind(with: campaignVM)
            return cell
        case .shortForm:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShortQuizCollectionViewCell.identifier, for: indexPath) as? ShortQuizCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.bind(with: campaignVM)
            return cell
        case .bestComment:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CommentCampaignCollectionViewCell.identifier, for: indexPath) as? CommentCampaignCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.bind(with: campaignVM)
            return cell
        }
    }
    
    private func makeTextFieldCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TextFieldCollectionViewCell.identifier, for: indexPath) as? TextFieldCollectionViewCell,
              let textInputVM = campaignPostVM.textInput else {
            return UICollectionViewCell()
        }
        
        cell.cameraButtonHandler = { [weak self] in
            guard let `self` = self else { return }
            self.activeView = cell
            self.present(self.photoPicker, animated: true)
        }
        
        cell.delegate = self
        cell.configure(with: textInputVM)
        cell.layoutIfNeeded()
        return cell
    }
    
    private func makePostCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostCommentCollectionViewCell.identifier, for: indexPath) as? PostCommentCollectionViewCell,
              let textInputCell = collectionView.dequeueReusableCell(withReuseIdentifier: RecommentTextInputCollectionViewCell.identifier, for: indexPath) as? RecommentTextInputCollectionViewCell,
              let defaultCell = collectionView.dequeueReusableCell(withReuseIdentifier: DefaultCollectionViewCell.identifier, for: indexPath) as? DefaultCollectionViewCell
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UICollectionViewCell.identifier, for: indexPath)
            return cell
        }
        
        guard let commentCellVM = campaignPostVM.postCellViewModel(at: indexPath.section) else {
            defaultCell.configure(with: "댓글이 아직 없습니다.")
            return defaultCell
        }
        
        var currentSection: Int = 0
        switch self.campaignPostVM.postType {
        case .article:
            currentSection = indexPath.section - 1
        default:
            currentSection = indexPath.section - 2
        }
        
        /// When camera button tapped.
        cell.commentEditViewCameraBtnDidTap = {
            self.activeView = cell
            self.activeCellSection = indexPath.section
            self.present(self.photoPicker, animated: true)
        }

        /// Conforming delegation
        cell.delegate = self
        cell.indexPath = indexPath
        
        /// Reset cell.
        if campaignPostVM.itemsMode[currentSection] { // Edit 상태에 따라 reset 상태 다르게 적용.
            cell.resetCellForEditMode()
        } else {
            cell.resetCell()
        }
        
        let numberOfItems = campaignPostVM.post.numberOfRecommentsForSection(at: indexPath.section)
        
        if indexPath.item == 0 {
            cell.configure(with: commentCellVM)
            cell.layoutIfNeeded()
            return cell
        } else if indexPath.item == numberOfItems - 1 {
            textInputCell.configure(with: commentCellVM)
            return textInputCell
        } else {
            let recommentCellVM = campaignPostVM.post.recommentsViewModelForItem(at: indexPath.item, section: indexPath.section)
            
            cell.contentView.backgroundColor = .systemGray5
            recommentCellVM.changeCellType(to: .recomment)
            cell.configure(with: recommentCellVM)
            
            cell.layoutIfNeeded()
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch campaignPostVM.postType {
        case .article:
            switch section {
            case 0:
                return 1
            default:
                guard let cellVM = campaignPostVM.postCellViewModel(at: section),
                      cellVM.isOpened
                else { return 1 }
                return campaignPostVM.post.numberOfRecommentsForSection(at: section)
            }
            
        default:
            switch section {
            case 0:
                return 1
                
            case 1:
                return 1
                
            default:
                guard let cellVM = campaignPostVM.postCellViewModel(at: section),
                      cellVM.isOpened
                else { return 1 }
                return campaignPostVM.post.numberOfRecommentsForSection(at: section)
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: PostDetailCollectionViewHeader.identifier,
            for: indexPath
        ) as? PostDetailCollectionViewHeader else {
            return UICollectionReusableView()
        }
        header.configure(with: campaignPostVM.post)
        header.delegate = self
        
        return header
    }

}

extension CampaignPostViewController: PostCommentCollectionViewCellPorotocol {
    @MainActor
    func commentDeleted() {
        self.collectionView?.reloadData()
    }
    
    @MainActor
    func showCommentDidTap(at indexPath: IndexPath) {
        switch campaignPostVM.postType {
        case .article:
            if indexPath.section > 0 && indexPath.item == 0 {
                guard let cellVM = campaignPostVM.postCellViewModel(at: indexPath.section) else { return }
                cellVM.isOpened = !cellVM.isOpened
                self.collectionView?.reloadData()
            }
        default:
            if indexPath.section > 1 && indexPath.item == 0 {
                guard let cellVM = campaignPostVM.postCellViewModel(at: indexPath.section) else { return }
                cellVM.isOpened = !cellVM.isOpened
                self.collectionView?.reloadData()
            }
        }
    }
    
    func editButtonDidTap(at indexPath: IndexPath) {
        var currentSection: Int = 0
        switch self.campaignPostVM.postType {
        case .article:
            currentSection = indexPath.section - 1
        default:
            currentSection = indexPath.section - 2
        }
        self.campaignPostVM.itemsMode[currentSection] = true
//        print("Item mode: \(self.campaignPostVM.itemsMode)")
        self.collectionView?.layoutIfNeeded()
    }

}


extension CampaignPostViewController: PostDetailCollectionViewHeaderProtocol {
    func likeButtonDidTap(vm: PostDetailViewViewModel) {
        guard let indexPath = self.indexPath else { return }
        //                try await vm.updatePostLike(postId: vm.postId, isLiked: vm.isLiked)
        self.delegate?.likebuttonDidTap(at: indexPath, isLiked: vm.isLiked)
    }
}

// MARK: - PHPPicker Delegate
extension CampaignPostViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        if activeView is PostCommentCollectionViewCell {
            
            guard let cellSection = self.activeCellSection,
                  let vm = campaignPostVM.postCellViewModel(at: cellSection)
            else { return }
            
            guard let result = results.first else {
                picker.dismiss(animated: true)
                return
            }
            self.loadImageFromItemProvider(itemProvider: result.itemProvider) { image in
                vm.selectedImageToEdit = image
            }
            
            picker.dismiss(animated: true)
            
        } else if activeView is TextFieldCollectionViewCell {
            
            guard let vm = campaignPostVM.textInput
            else { return }
            
            guard let result = results.first else {
                vm.isCameraButtonTapped = false
                picker.dismiss(animated: true)
                return
            }
            
            self.loadImageFromItemProvider(itemProvider: result.itemProvider) { image in
                vm.selectedImage = image
            }
            
            vm.isCameraButtonTapped = false
            picker.dismiss(animated: true)
        } else {
            print("Some other collection view cell selected images.")
        }
       
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

extension CampaignPostViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        let totalContentHeight = scrollView.contentSize.height
        let totalScrollViewFixedHeight = scrollView.frame.size.height
        
        if offset >= (totalContentHeight - totalScrollViewFixedHeight)
            && campaignPostVM.post.queryDocumentSnapshot != nil
            && !campaignPostVM.post.isLoading
        {
            campaignPostVM.post.fetchAdditionalPaginatedComments(of: campaignPostVM.post.postId)
        }
    }
}

extension CampaignPostViewController: TextFieldCollectionViewCellProtocol {
    func commentReloaded() {
        campaignPostVM.post.fetchInitialPaginatedComments(of: campaignPostVM.post.postId)
    }
}
