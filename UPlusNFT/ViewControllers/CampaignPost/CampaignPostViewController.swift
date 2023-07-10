//
//  CampainPostViewController.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/07/03.
//

import UIKit
import Combine
import PhotosUI

final class CampaignPostViewController: UIViewController {
    
    // MARK: - Dependency
    private let campaignPostVM: CampaignPostViewViewModel
    
    // MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    //MARK: - Property
    private var collectionView: UICollectionView?
    private let postType: PostType
    
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

// MARK: -  Create CollectionView
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
        item.contentInsets = NSDirectionalEdgeInsets(top: 0,
                                                     leading: 0,
                                                     bottom: 10,
                                                     trailing: 0)
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
                heightDimension: .fractionalHeight(1.0)
            )
        )
        item.contentInsets = NSDirectionalEdgeInsets(top: 0,
                                                     leading: 0,
                                                     bottom: 10,
                                                     trailing: 0)
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(0.4)
            ),
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(0.7)
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
                heightDimension: .fractionalHeight(1.0)
            )
        )
        item.contentInsets = NSDirectionalEdgeInsets(top: 0,
                                                     leading: 0,
                                                     bottom: 10,
                                                     trailing: 0)
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(0.3)
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
            self.present(self.photoPicker, animated: true)
        }
        
        cell.configure(with: textInputVM)
        return cell
    }
    
    private func makePostCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostCommentCollectionViewCell.identifier, for: indexPath) as? PostCommentCollectionViewCell,
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
        
        // Edit button tap 여부 확인.
        cell.editButtonDidTap = { [weak self] in
            self?.campaignPostVM.itemsMode[currentSection] = true
        }
//        print("Tap status: \(self.campaignPostVM.itemsMode)")
        // Edit 상태에 따라 reset 상태 다르게 적용.
        if campaignPostVM.itemsMode[currentSection] {
            // Edit 상태인 경우.
            cell.resetCellForEditMode()
        }
        // 모든 상태에 적용.
        cell.resetCell()
        
        if indexPath.item == 0 {
            cell.configure(with: commentCellVM)
            return cell
        } else {
            let recommentCellVM = campaignPostVM.post.recommentsViewModelForItem(at: indexPath.item, section: indexPath.section)
 
            cell.contentView.backgroundColor = .systemGray5
            cell.configure(with: recommentCellVM)
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch campaignPostVM.postType {
        case .article:
            print("Cell did tap at: Section#\(indexPath.section) Item#\(indexPath.item)")
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
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: PostDetailCollectionViewHeader.identifier,
            for: indexPath
        ) as? PostDetailCollectionViewHeader else {
            return UICollectionReusableView()
        }
        header.configure(with: campaignPostVM.post)
        return header
    }
}

// MARK: - PHPPicker Delegate
extension CampaignPostViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
 
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
