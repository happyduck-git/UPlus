//
//  MissionMainViewController.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/17.
//

import UIKit
import FirebaseAuth
import SwiftUI
import Combine

class MissionMainViewController: UIViewController {

    //MARK: - Dependency
    private let vm: MissionMainViewViewModel
    
    // MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    // MARK: - Side Menu Controller Manager
    private lazy var slideInTransitioningDelegate = SideMenuPresentationManager()
    
    // MARK: - UI Elements
    private var collectionView: UICollectionView?
    
    //MARK: - Init
    init(vm: MissionMainViewViewModel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationItem()
        view.backgroundColor = .systemGray6
        
        self.setUI()
        self.setLayout()
        self.setDelegate()
        
        self.vm.getDailyAttendanceMission()
        self.bind()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let vc = WelcomeBottomSheetViewController()
        vc.modalPresentationStyle = .overCurrentContext

        self.present(vc, animated: false)
    }
}

// MARK: - Bind
extension MissionMainViewController {
    
    private func bind() {
        
        func bindViewToViewModel() {
            
        }
        
        func bindViewModelToView() {
            self.vm.$dailyAttendanceMissions
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    guard let `self` = self else { return }
                    self.collectionView?.reloadSections(IndexSet(integer: 2))
                }
                .store(in: &bindings)
        }
        
        bindViewToViewModel()
        bindViewModelToView()
        
    }

}

// MARK: - Create CollectionView
extension MissionMainViewController {
    private func createCollectionView() -> UICollectionView {
        let layout = UICollectionViewCompositionalLayout {  sectionIndex, _ in
            return self.createSection(for: sectionIndex)
        }
        
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        
        // 1. Register section header
        collectionView.register(MissionCollectionViewHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: MissionCollectionViewHeader.identifier)
        
        // 2. Register cell
        collectionView.register(
            UICollectionViewCell.self,
            forCellWithReuseIdentifier: UICollectionViewCell.identifier
        )

        collectionView.register(
            MissionProfileCollectionViewCell.self,
            forCellWithReuseIdentifier: MissionProfileCollectionViewCell.identifier
        )
        
        collectionView.register(
            TodayMissionCollectionViewCell.self,
            forCellWithReuseIdentifier: TodayMissionCollectionViewCell.identifier
        )
        
        collectionView.register(
            DailyQuizMissionCollectionViewCell.self,
            forCellWithReuseIdentifier: DailyQuizMissionCollectionViewCell.identifier
        )
        
        collectionView.register(
            DailyMissionCollectionViewCell.self,
            forCellWithReuseIdentifier: DailyMissionCollectionViewCell.identifier
        )
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }
    
    private func createSection(for section: Int) -> NSCollectionLayoutSection {
        switch section {
        case 0:
            return self.createProfileSectionLayout()
        case 1:
            return self.createTodayMissionSectionLayout()
        case 2:
            return self.createDailyQuizSectionLayout()
        default:
            return self.createDailyMissionSectionLayout()
        }
    }
    
    private func createProfileSectionLayout() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
        )

        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(0.6)
            ),
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        
        return section
    }
   
    private func createTodayMissionSectionLayout() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
        )

        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(0.1)
            ),
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        
        return section
    }
    
    private func createDailyQuizSectionLayout() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
        )

        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(0.2)
            ),
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(0.06)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        
        section.boundarySupplementaryItems = [header]
        return section
    }
    
    private func createDailyMissionSectionLayout() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
        )
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.8),
                heightDimension: .fractionalHeight(0.4)
            ),
            subitems: [item]
        )

        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(0.06)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        
        section.boundarySupplementaryItems = [header]
        return section
    }
}

// MARK: - Set UI & Layout
extension MissionMainViewController {
    
    private func setUI() {
        let collectionView = self.createCollectionView()
        self.collectionView = collectionView
        view.addSubview(collectionView)
    }
    
    private func setLayout() {
        guard let collectionView = collectionView else { return }
        collectionView.frame = view.bounds
    }
    
    private func setNavigationItem() {
        let menuItem = UIBarButtonItem(image: UIImage(systemName: SFSymbol.list)?.withTintColor(.black, renderingMode: .alwaysOriginal),
                                       style: .plain,
                                       target: self,
                                       action: #selector(openSideMenu))
        
        let speakerItem = UIBarButtonItem(image: UIImage(systemName: SFSymbol.speaker)?.withTintColor(.systemGray, renderingMode: .alwaysOriginal),
                                          style: .plain,
                                          target: self,
                                          action: nil)
        
        navigationItem.setLeftBarButton(menuItem, animated: true)
        navigationItem.setRightBarButton(speakerItem, animated: true)
        navigationItem.title = "미션 홈"
    }
    
    @objc func openSideMenu() {
        slideInTransitioningDelegate.direction = .left
        let sideMenuVC = SideMenuViewController()
        sideMenuVC.transitioningDelegate = slideInTransitioningDelegate
        sideMenuVC.modalPresentationStyle = .custom
        self.navigationController?.present(sideMenuVC, animated: true)
    }
    
}

// MARK: - Collection DataSource, Delegate
extension MissionMainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    private func setDelegate() {
        self.collectionView?.dataSource = self
        self.collectionView?.delegate = self
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return vm.sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 2:
            return self.vm.dailyAttendanceMissions.count
        case 3:
            return self.vm.dailyMissionCellVMList.count
        default:
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        switch indexPath.section {
        case 0:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MissionProfileCollectionViewCell.identifier, for: indexPath) as? MissionProfileCollectionViewCell else { fatalError() }
            
            cell.configure(with: self.vm)
            return cell
        case 1:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TodayMissionCollectionViewCell.identifier, for: indexPath) as? TodayMissionCollectionViewCell else { fatalError() }
            
            cell.configure(with: self.vm)
            return cell
        case 2:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DailyQuizMissionCollectionViewCell.identifier, for: indexPath) as? DailyQuizMissionCollectionViewCell else { fatalError() }
            
            cell.configure(with: self.vm.dailyAttendanceMissions[indexPath.item])
            return cell
        default:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DailyMissionCollectionViewCell.identifier, for: indexPath) as? DailyMissionCollectionViewCell else { fatalError() }
            
            cell.configure(with: self.vm.dailyMissionCellVMList[indexPath.item])
            return cell
        }
        
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: MissionCollectionViewHeader.identifier,
            for: indexPath
        ) as? MissionCollectionViewHeader else {
            return UICollectionReusableView()
        }
        header.configure(with: vm.sections[indexPath.section].rawValue)
        return header
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.section {
        case 2:
            let quizMissionDetailVC = DailyQuizMissionDetailViewController()
            
            quizMissionDetailVC.configure(with: self.vm.dailyAttendanceMissions[indexPath.item])
            self.show(quizMissionDetailVC, sender: self)
        default:
            break
        }
    }
}

// MARK: - Preview
//struct PreView: PreviewProvider {
//    static var previews: some View {
//        MissionMainViewController().toPreview()
//    }
//}


