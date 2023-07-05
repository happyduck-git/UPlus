//
//  CampainPostViewController.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/07/03.
//

import UIKit
import Combine

final class CampaignPostViewController: UIViewController {
    
    // MARK: - Dependency
    private let campaignCellVM: CampaignCollectionViewCellViewModel
    private let postCellVM: PostDetailViewViewModel

    private var bindings = Set<AnyCancellable>()
    
    //MARK: - Property
    private var collectionView: UICollectionView?
    private let postType: PostType
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setUI()
        setLayout()
        setDelegate()
        
        campaignCellVM.fetchPostMetaData(campaignCellVM.postId)
        bind()
    }
 
    init(
        postType: PostType,
        campaignCellVM: CampaignCollectionViewCellViewModel,
        postCellVM: PostDetailViewViewModel
    ) {
        self.postType = postType
        self.campaignCellVM = campaignCellVM
        self.postCellVM = postCellVM
        super.init(nibName: nil, bundle: nil)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Set UI & Layout
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
    }
    
    private func bind() {
        
        func bindViewToViewModel() {
            
        }
        
        func bindViewModelToView() {

            postCellVM.$tableDataSource
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    self?.collectionView?.reloadData()
                }
                .store(in: &bindings)
            
            postCellVM.$recomments
                .receive(on: DispatchQueue.main)
                .sink { [weak self] recomment in
                    print("Recomment count -- \(recomment.count)")
                    self?.collectionView?.reloadData()
                }
                .store(in: &bindings)
        }
        
        bindViewToViewModel()
        bindViewModelToView()
    }
    
    // MARK: -  Create CollectionView

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

        // Register cell
        collectionView.register(
            UICollectionViewCell.self,
            forCellWithReuseIdentifier: UICollectionViewCell.identifier
        )
        collectionView.register(
            PostCommentCollectionViewCell.self,
            forCellWithReuseIdentifier: PostCommentCollectionViewCell.identifier
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
        if section == 0 {
            return createCampaignSectionLayout()
        } else {
            return createPostSectionLayout(at: section)
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
    
    private func createPostSectionLayout(at indexSection: Int) -> NSCollectionLayoutSection {
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
                heightDimension: .fractionalHeight(0.2)
            ),
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        
        if indexSection == 1 {
            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(0.5)
            )
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            
            section.boundarySupplementaryItems = [header]
        }
        return section
    }
}

extension CampaignPostViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let count = postCellVM.numberOfSections()
        return count == 1 ? 2 : count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            switch self.postType {
            case .article:
                return UICollectionViewCell()
            case .multipleChoice:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MultipleQuizCollectionViewCell.identifier, for: indexPath) as? MultipleQuizCollectionViewCell else {
                    return UICollectionViewCell()
                }
                cell.bind(with: campaignCellVM)
                return cell
            case .shortForm:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShortQuizCollectionViewCell.identifier, for: indexPath) as? ShortQuizCollectionViewCell else {
                    return UICollectionViewCell()
                }
                cell.bind(with: campaignCellVM)
                return cell
            case .bestComment:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CommentCampaignCollectionViewCell.identifier, for: indexPath) as? CommentCampaignCollectionViewCell else {
                    return UICollectionViewCell()
                }
                cell.bind(with: campaignCellVM)
                return cell
            }
        } else {
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostCommentCollectionViewCell.identifier, for: indexPath) as? PostCommentCollectionViewCell,
                  let commentCellVM = postCellVM.viewModelForRow(at: indexPath.section - 1)
            else {
                return UICollectionViewCell()
            }
            cell.resetCell()
            
            if indexPath.item == 0 {
                cell.configure(with: commentCellVM)
                cell.bind(with: commentCellVM)
                return cell
            } else {
                guard let recomments = self.postCellVM.recomments[indexPath.section],
                      !recomments.isEmpty
                else {
                    let defaultCell = collectionView.dequeueReusableCell(withReuseIdentifier: UICollectionViewCell.identifier, for: indexPath)
                    // recomment == nil || recomment is empty
//                    var config = defaultCell.defaultContentConfiguration()
//                    config.text = "아직 대댓글이 없습니다!"
//                    defaultCell.contentConfiguration = config
                    defaultCell.backgroundColor = .systemGray4
                    return defaultCell
                }
                // recomment != nil nor empty
                let recomment = recomments[indexPath.row - 1]
                let cellVM = CommentTableViewCellModel(
                    type: .normal,
                    id: recomment.recommentId,
                    userId: recomment.recommentAuthorUid,
                    comment: recomment.recommentContentText,
                    imagePath: nil,
                    likeUserCount: nil,
                    recomments: nil,
                    createdAt: recomment.recommentCreatedTime
                )
                cell.contentView.backgroundColor = .systemGray5
                cell.configure(with: cellVM)
                return cell
            }
            
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        default:
            guard let cellVM = postCellVM.viewModelForRow(at: section - 1)
            else { return 1 }
            
            if cellVM.isOpened {
                print("Number of rows in section #\(section) --- \((self.postCellVM.recomments[section]?.count ?? 0) + 1)")
                return (self.postCellVM.recomments[section]?.count ?? 0) + 1
            }
            else {
                return 1
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Item tapped at : Section #\(indexPath.section) Item #\(indexPath.item)")
        if indexPath.section > 0 && indexPath.row == 0 {
            guard let cellVM = postCellVM.viewModelForRow(at: indexPath.section - 1) else { return }
            cellVM.isOpened = !cellVM.isOpened
            
            self.postCellVM.fetchRecomment(at: indexPath.section, of: cellVM.id)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch indexPath.section {
        case 1:
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: PostDetailCollectionViewHeader.identifier,
                for: indexPath
            ) as? PostDetailCollectionViewHeader else {
                return UICollectionReusableView()
            }
            header.configure(with: postCellVM)
            return header
            
        default:
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: UICollectionReusableView.identifier,
                for: indexPath
            )
            return header
        }
    }
}

extension CampaignPostViewController {
    
    //MARK: - Data Source
    enum Section {
        case post
    }
    
    enum ListItem: Hashable {
        case comment(CommentContent)
        case recomment(Recomment)
    }
    
    private func createDatasourceSnapshot() {
        guard let collection = collectionView else { return }
        var dataSource = UICollectionViewDiffableDataSource<Section, ListItem>(collectionView: collection) { collectionView, indexPath, listItem in
            return nil
        }
        var dataSourceSnapshot = NSDiffableDataSourceSnapshot<Section, ListItem>()
        dataSourceSnapshot.appendSections([.post])
        dataSource.apply(dataSourceSnapshot)
    }
    
    
    
}
