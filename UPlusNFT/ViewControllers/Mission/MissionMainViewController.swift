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

enum MissionCellViewModel {
    case A(String)
    case B(Int)
    /*
    case profileCollectionViewCellViewModel(MissionMainViewViewModel)
    case todayMissionCollectionViewCellViewModel(MissionMainViewViewModel)
    case dailyQuizMissionCollectionViewCell(DailyAttendanceMission)
    case dailyMissionCollectionViewCell(DailyMissionCollectionViewCellViewModel)
    case suddenMissionCollectionViewCell(SuddenMission)
     */
}

struct SectionA: Hashable {
    
    let id: String
    let items: [MissionCellViewModel]
    var isVisible: Bool
    
    static func == (lhs: SectionA, rhs: SectionA) -> Bool {
        return lhs.id == rhs.id ? true : false
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}

class MissionMainViewController: UIViewController {

    //MARK: - Dependency
    private let vm: MissionMainViewViewModel
    
    // MARK: - Combine
    private var bindings = Set<AnyCancellable>()
   
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
//        self.setNavigationItem()
        view.backgroundColor = .systemGray6
        
        self.setUI()
        self.setLayout()
        self.setDelegate()
        
        self.vm.getDailyAttendanceMission()
        self.vm.getSuddenMission()
        self.bind()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let vc = WelcomeBottomSheetViewController()
        vc.modalPresentationStyle = .overCurrentContext

        self.present(vc, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let backBtnImage = UIImage(systemName: SFSymbol.arrowLeft)?.withTintColor(.black, renderingMode: .alwaysOriginal)
        
        navigationController?.navigationBar.backIndicatorImage = backBtnImage
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = backBtnImage
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

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
            
            self.vm.$suddenMissions
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    guard let `self` = self else { return }
                    self.collectionView?.reloadSections(IndexSet(integer: 4))
                }
                .store(in: &bindings)
            
            self.vm.$isHistorySectionOpened
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    guard let `self` = self else { return }
                    
                    self.collectionView?.reloadSections(IndexSet(integer: 6))
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
        
        collectionView.register(
            MissionHistoryButtonCollectionViewCell.self,
            forCellWithReuseIdentifier: MissionHistoryButtonCollectionViewCell.identifier
        )
        
        collectionView.register(
            MissionHistoryCalendarCollectionViewCell.self,
            forCellWithReuseIdentifier: MissionHistoryCalendarCollectionViewCell.identifier
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
        case 3:
            return self.createLongTermMissionSectionLayout()
        case 4:
            return self.createSuddenQuizSectionLayout()
        case 5:
            return self.createButtonSectionLayout()
        default:
            return self.createMissionHistorySectionLayout()
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
                heightDimension: .fractionalHeight(0.4)
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
    
    private func createLongTermMissionSectionLayout() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
        )
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.8),
                heightDimension: .fractionalHeight(0.3)
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
    
    private func createSuddenQuizSectionLayout() -> NSCollectionLayoutSection {
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
    
    private func createButtonSectionLayout() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
        )

        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(0.08)
            ),
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        return section
    }
    
    private func createMissionHistorySectionLayout() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
        )

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
            return self.vm.longTermMissionCellVMList.count
        case 4:
            return self.vm.suddenMissions.count
        case 6:
            return self.vm.isHistorySectionOpened ? 1 : 0
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
        case 3:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DailyMissionCollectionViewCell.identifier, for: indexPath) as? DailyMissionCollectionViewCell else { fatalError() }
            
            cell.configure(with: self.vm.longTermMissionCellVMList[indexPath.item])
            return cell
        case 4:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DailyQuizMissionCollectionViewCell.identifier, for: indexPath) as? DailyQuizMissionCollectionViewCell else { fatalError() }
            
            cell.configure(with: self.vm.suddenMissions[indexPath.item])
            return cell
        case 5:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MissionHistoryButtonCollectionViewCell.identifier, for: indexPath) as? MissionHistoryButtonCollectionViewCell else { fatalError() }
            cell.delegate = self
            return cell
        default:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MissionHistoryCalendarCollectionViewCell.identifier, for: indexPath) as? MissionHistoryCalendarCollectionViewCell else { fatalError() }
      
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
            let vm = DailyQuizMissionDetailViewViewModel(dataSource: self.vm.dailyAttendanceMissions[indexPath.item])
            
            let quizMissionDetailVC = DailyQuizMissionDetailViewController(vm: vm)
            self.show(quizMissionDetailVC, sender: self)
        case 5:
            guard let cell = collectionView.cellForItem(at: indexPath) as? MissionHistoryButtonCollectionViewCell else { return }
            cell.isOpened.toggle()
        default:
            break
        }
    }
}

extension MissionMainViewController: MissionHistoryButtonCollectionViewCellDelegate {
    func showMissionButtonDidTap(isOpened: Bool) {
        self.vm.isHistorySectionOpened = isOpened
    }
}

/*
extension MissionMainViewController: MyPageViewControllerDelegate {
    func myPageViewControllerDidShow(_ controller: UIViewController) {
        if controller is MyPageViewController {
            let speakerItem = UIBarButtonItem(image: UIImage(named: ImageAsset.speaker)?.withTintColor(.systemGray, renderingMode: .alwaysOriginal),
                                              style: .plain,
                                              target: self,
                                              action: nil)
            
            navigationItem.setRightBarButton(speakerItem, animated: true)
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }
}

*/
