//
//  RankingViewController.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/24.
//

import UIKit
import Combine

class RankingViewController: UIViewController {

    // MARK: - Dependency
    private let vm: RankingViewViewModel
    
    // MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    // MARK: - UI Elements
    private let menuBar: RankingMenuBar = {
        let menuBar = RankingMenuBar()
        menuBar.translatesAutoresizingMaskIntoConstraints = false
        return menuBar
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: UICollectionViewCell.identifier)
        collection.register(TodayRankCollectionViewCell.self, forCellWithReuseIdentifier: TodayRankCollectionViewCell.identifier)
        collection.register(TotalRankCollectionViewCell.self, forCellWithReuseIdentifier: TotalRankCollectionViewCell.identifier)
        
        collection.showsHorizontalScrollIndicator = false
        collection.isPagingEnabled = true
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()
    
    private let bottomFlatSheet: RankBottomFlatSheetView = {
        let sheet = RankBottomFlatSheetView()
        sheet.translatesAutoresizingMaskIntoConstraints = false
        return sheet
    }()

    // MARK: - Init
    init(vm: RankingViewViewModel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
        
//        self.vm.getUserPoints()
        Task {
            self.vm.totakRankerFetched = await self.vm.getAllUserTotalPoint()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = RankingConstants.rank
        self.view.backgroundColor = .white
        
        self.setUI()
        self.setLayout()
        self.setDelegate()
        
        self.bottomFlatSheet.bind(with: self.vm, at: 0)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.itemSize = CGSize(width: self.view.frame.width, height: self.collectionView.frame.height)
        }
    }
}

// MARK: - Set UI & Layout
extension RankingViewController {
    private func setDelegate() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.menuBar.delegate = self
    }
    
    private func setUI() {
        self.view.addSubviews(self.menuBar,
                              self.collectionView,
                              self.bottomFlatSheet)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.menuBar.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.menuBar.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            self.menuBar.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            self.menuBar.heightAnchor.constraint(equalToConstant: 50),
            self.collectionView.topAnchor.constraint(equalTo: self.menuBar.bottomAnchor),
            self.collectionView.leadingAnchor.constraint(equalTo: self.menuBar.leadingAnchor),
            self.collectionView.trailingAnchor.constraint(equalTo: self.menuBar.trailingAnchor),
            self.collectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            
            self.bottomFlatSheet.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            self.bottomFlatSheet.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            self.bottomFlatSheet.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            self.bottomFlatSheet.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
}

extension RankingViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.item {
        case 0:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TodayRankCollectionViewCell.identifier, for: indexPath) as? TodayRankCollectionViewCell else {
                fatalError()
            }
            cell.contentView.backgroundColor = .systemGray6
            cell.configure(with: vm)
            return cell
            
        default:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TotalRankCollectionViewCell.identifier, for: indexPath) as? TotalRankCollectionViewCell else {
                fatalError()
            }
         
            cell.contentView.backgroundColor = .systemGray6
            cell.configure(with: vm)
            return cell
        }
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.menuBar.scrollIndicator(to: scrollView.contentOffset)
        
        if scrollView.contentOffset.x == 0 {
            self.bottomFlatSheet.bind(with: self.vm, at: 0)
        } else if scrollView.contentOffset.x == self.view.frame.width {
            self.bottomFlatSheet.bind(with: self.vm, at: 1)
        }
    }
    
    
}

extension RankingViewController: RankingMenuBarDelegate {
    func didSelectItemAt(index: Int) {
        self.menuBar.selectItem(at: index)
        self.collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: [], animated: true)
    }
}
