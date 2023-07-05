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
    private let campaignPostVM: CampaignPostViewViewModel

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
        
        bind()
    }
 
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
            campaignPostVM.post.$tableDataSource
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    print("Comment reload")
                    self?.collectionView?.reloadData()
                }
                .store(in: &bindings)
           
            campaignPostVM.post.$recomments
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
            return createPostSectionLayout(at: section)
        default:
            if section == 0 {
                return createCampaignSectionLayout()
            } else {
                return createPostSectionLayout(at: section)
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
                heightDimension: .fractionalHeight(0.3)
            ),
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        
        var sectionNum: Int = 0
        switch campaignPostVM.postType {
        case .article:
            sectionNum = 0
        default:
            sectionNum = 1
        }
        
        if indexSection == sectionNum {
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
        return campaignPostVM.numberOfSections()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
            switch self.postType {
            case .article:
                return self.postCell(collectionView, viewModelAt: indexPath)
                
            case .multipleChoice:
                if indexPath.section == 0 {
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MultipleQuizCollectionViewCell.identifier, for: indexPath) as? MultipleQuizCollectionViewCell else {
                        return UICollectionViewCell()
                    }
                    cell.bind(with: campaignPostVM.campaignCellViewModel())
                    return cell
                } else {
                    return self.postCell(collectionView, viewModelAt: indexPath)
                }
                
            case .shortForm:
                if indexPath.section == 0 {
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShortQuizCollectionViewCell.identifier, for: indexPath) as? ShortQuizCollectionViewCell else {
                        return UICollectionViewCell()
                    }
                    cell.bind(with: campaignPostVM.campaignCellViewModel())
                    return cell
                } else {
                    return self.postCell(collectionView, viewModelAt: indexPath)
                }
                
            case .bestComment:
                if indexPath.section == 0 {
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: CommentCampaignCollectionViewCell.identifier,
                        for: indexPath
                    ) as? CommentCampaignCollectionViewCell else {
                        return UICollectionViewCell()
                    }
                    cell.bind(with: campaignPostVM.campaignCellViewModel())
                    return cell
                } else {
                    return self.postCell(collectionView, viewModelAt: indexPath)
                }
            }
        
    }
    
    func postCell(_ collectionView: UICollectionView, viewModelAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PostCommentCollectionViewCell.identifier,
            for: indexPath
        ) as? PostCommentCollectionViewCell,
              let defaultCell = collectionView.dequeueReusableCell(
                withReuseIdentifier: DefaultCollectionViewCell.identifier,
                for: indexPath
              ) as? DefaultCollectionViewCell
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UICollectionViewCell.identifier, for: indexPath)
            return cell
        }
        
        guard let commentCellVM = campaignPostVM.postCellViewModel(at: indexPath.section) else {
            defaultCell.configure(with: "댓글이 아직 없습니다.")
            return defaultCell
        }
        
        cell.resetCell()
        
        if indexPath.item == 0 {
            cell.configure(with: commentCellVM)
            cell.bind(with: commentCellVM)
            return cell
        } else {
         
            guard let recomments = campaignPostVM.post.recomments[indexPath.section],
                  !recomments.isEmpty
            else {
                defaultCell.configure(with: "아직 대댓글이 없습니다.")
                return defaultCell
            }
            /// recomment != nil nor empty
            let recomment = recomments[indexPath.item - 1]
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch campaignPostVM.postType {
        case .article:
            guard let cellVM = campaignPostVM.postCellViewModel(at: section)
            else { return 1 }
            
            if cellVM.isOpened {
//                print("Number of rows in section #\(section) --- \((campaignPostVM.post.recomments[section]?.count ?? 0) + 1)")
                return (campaignPostVM.post.recomments[section]?.count ?? 0) + 1
            }
            else {
                return 1
            }
        default:
            switch section {
            case 0:
                return 1
            default:
                guard let cellVM = campaignPostVM.postCellViewModel(at: section)
                else { return 1 }
                
                if cellVM.isOpened {
//                    print("Number of rows in section #\(section) --- \((campaignPostVM.post.recomments[section - 1]?.count ?? 0) + 1)")
                    return campaignPostVM.post.recomments[section - 1]?.count ?? 0
                }
                else {
                    return 1
                }
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Item tapped at : Section #\(indexPath.section) Item #\(indexPath.item)")
        switch campaignPostVM.postType {
        case .article:
            if indexPath.row == 0 {
                guard let cellVM = campaignPostVM.postCellViewModel(at: indexPath.section) else { return }
                cellVM.isOpened = !cellVM.isOpened
                campaignPostVM.fetchRecomment(at: indexPath.section, of: cellVM.id)
            }
        default:
            if indexPath.section > 0 && indexPath.row == 0 {
                guard let cellVM = campaignPostVM.postCellViewModel(at: indexPath.section) else { return }
                cellVM.isOpened = !cellVM.isOpened
                campaignPostVM.fetchRecomment(at: indexPath.section - 1, of: cellVM.id)
                
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
