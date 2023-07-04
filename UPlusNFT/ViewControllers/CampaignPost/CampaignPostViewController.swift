//
//  CampainPostViewController.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/07/03.
//

import UIKit

final class CampaignPostViewController: UIViewController {
    
    // MARK: - Dependency
    private let vm: CampaignCollectionViewCellViewModel
    
    //MARK: - Property
    private var collectionView: UICollectionView?
    private let postType: PostType
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        setLayout()
        setDelegate()
        
        vm.fetchPostMetaData(vm.postId)
    }
 
    init(
        postType: PostType,
        vm: CampaignCollectionViewCellViewModel
    ) {
        self.postType = postType
        self.vm = vm
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
    
    // MARK: -  Create CollectionView
    
    private func createCollectionView() -> UICollectionView {
        let layout = UICollectionViewCompositionalLayout {  sectionIndex, _ in
            return self.createSection(for: sectionIndex)

        }
        
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        collectionView.register(
            MultipleQuizCollectionViewCell.self,
            forCellWithReuseIdentifier: MultipleQuizCollectionViewCell.identifier
        )
        collectionView.register(
            ShortQuizCollectionViewCell.self,
            forCellWithReuseIdentifier: ShortQuizCollectionViewCell.identifier
        )
        collectionView.register(
            CommentCampaignViewCell.self,
            forCellWithReuseIdentifier: CommentCampaignViewCell.identifier
        )
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }
    
    private func createSection(for section: Int) -> NSCollectionLayoutSection {
        if section == 0 {
            return createCampaignSectionLayout()
        } else {
            return createPostSectionLayout()
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
                heightDimension: .fractionalHeight(0.5)
            ),
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        
        return section
    }
}

extension CampaignPostViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            switch self.postType {
            case .article:
                return UICollectionViewCell()
            case .multipleChoice:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MultipleQuizCollectionViewCell.identifier, for: indexPath) as? MultipleQuizCollectionViewCell else {
                    return UICollectionViewCell()
                }
                cell.bind(with: vm)
                return cell
            case .shortForm:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShortQuizCollectionViewCell.identifier, for: indexPath) as? ShortQuizCollectionViewCell else {
                    return UICollectionViewCell()
                }
                cell.bind(with: vm)
                return cell
            case .bestComment:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CommentCampaignViewCell.identifier, for: indexPath) as? CommentCampaignViewCell else {
                    return UICollectionViewCell()
                }
                cell.bind(with: vm)
                return cell
            }
        } else {
            switch self.postType {
            case .article:
                return UICollectionViewCell()
            case .multipleChoice:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MultipleQuizCollectionViewCell.identifier, for: indexPath) as? MultipleQuizCollectionViewCell else {
                    return UICollectionViewCell()
                }
                cell.bind(with: vm)
                return cell
            case .shortForm:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShortQuizCollectionViewCell.identifier, for: indexPath) as? ShortQuizCollectionViewCell else {
                    return UICollectionViewCell()
                }
                cell.bind(with: vm)
                return cell
            case .bestComment:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CommentCampaignViewCell.identifier, for: indexPath) as? CommentCampaignViewCell else {
                    return UICollectionViewCell()
                }
                cell.bind(with: vm)
                return cell
            }
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
}
