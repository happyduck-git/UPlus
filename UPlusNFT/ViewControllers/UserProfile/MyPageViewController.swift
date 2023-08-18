//
//  MyPageViewController.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/21.
//

import UIKit
import Combine
import FirebaseAuth
import OSLog

final class MyPageViewController: UIViewController {
    
    // MARK: - Dependency
    let vm: MyPageViewViewModel
    private var sideMenuVC: SideMenuViewController?
    
    // MARK: - Logger
    let logger = Logger()
    
    // MARK: - Side Menu Controller Manager
    private lazy var slideInTransitioningDelegate = SideMenuPresentationManager()
    
    // MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    // MARK: - Dynamic Constraints
    private var initialHeight: CGFloat = 680
    private var topOffset: CGFloat = 0.0
    private var initialTopOffset: CGFloat = 0.0
    private var isSet: Bool = false
    
    private var topConstraint: NSLayoutConstraint?
    private var heightConstraint: NSLayoutConstraint?
    
    // MARK: - UI Elements
    private var screenToShow: Int = 0
    
    private let loadingVC = LoadingViewController()
    
    private let refreshControl: UIRefreshControl = {
       let control = UIRefreshControl()
       return control
    }()
    
    private let containerView: PassThroughView = {
        let view = PassThroughView()
        view.backgroundColor = UPlusColor.gradient09light
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let shadowView: PassThroughView = {
        let view = PassThroughView()
        view.backgroundColor = .white
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 20)
        view.layer.shadowOpacity = 0.3
        view.layer.shadowRadius = 4.0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let userProfileView: UserProfileView = {
        let profileView = UserProfileView()
        profileView.translatesAutoresizingMaskIntoConstraints = false
        return profileView
    }()
    
    private let whiteBackView: PassThroughView = {
        let view = PassThroughView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let buttonStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var missionButton: UIButton = {
        let button = UIButton()
        button.tag = 0
        button.addTarget(self, action: #selector(buttonDidTap(_:)), for: .touchUpInside)
        button.backgroundColor = .white
        button.setTitleColor(UPlusColor.navy, for: .normal)
        button.setTitle("미션", for: .normal)
        return button
    }()
    
    private lazy var eventButton: UIButton = {
        let button = UIButton()
        button.tag = 1
        button.addTarget(self, action: #selector(buttonDidTap(_:)), for: .touchUpInside)
        button.backgroundColor = .white
        button.setTitleColor(UPlusColor.navy, for: .normal)
        button.setTitle("이벤트", for: .normal)
        return button
    }()
    
    private let buttonBottomBar: PassThroughView = {
        let view = PassThroughView()
        view.backgroundColor = UPlusColor.navy
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var collectionView: UICollectionView?
    
    //MARK: - Init
    init(vm: MyPageViewViewModel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
        
        self.bind()
        self.userProfileView.configure(with: vm)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUI()
        self.setLayout()
        self.setDelegate()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationItem()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if self.vm.memberShip.isVIP && self.vm.memberShip.isJustRegisterd {
            let vm = WelcomeBottomSheetViewViewModel()
            let vc = WelcomeBottomSheetViewController(vm: vm)
            vc.delegate = self
            vc.modalPresentationStyle = .overCurrentContext

            self.present(vc, animated: false)
        }

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let backBtnImage = UIImage(systemName: SFSymbol.arrowLeft)?.withTintColor(.black, renderingMode: .alwaysOriginal)
        
        navigationController?.navigationBar.backIndicatorImage = backBtnImage
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = backBtnImage
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    @objc func buttonDidTap(_ sender: UIButton) {
        self.screenToShow = sender.tag
        switch sender.tag {
        case 0:
            collectionView?.reloadData()
            return
        case 1:
            Task {
                await self.vm.getEventMission()
                print("Reloaded")
            }
        default:
            return
        }
    }
    
}

// MARK: - Bind with View Model
extension MyPageViewController {
    private func bind() {
        func bindViewToViewModel() {
            
        }
        func bindViewModelToView() {
            
            self.vm.$userProfileViewModel
                .receive(on: DispatchQueue.main)
                .sink { [weak self] mission in
                    guard let `self` = self,
                          let collection = self.collectionView
                    else { return }
                    collection.reloadSections(IndexSet(integer: 0))
                }
                .store(in: &bindings)
            
            self.vm.mission.$savedMissionType
                .receive(on: DispatchQueue.main)
                .sink { [weak self] mission in
                    guard let `self` = self,
                          let collection = self.collectionView
                    else { return }
                    
                    if let _ = mission {
                        collection.reloadSections(IndexSet(integer: 1))
                    }
                }
                .store(in: &bindings)
            
            self.vm.mission.$weeklyMissions
                .receive(on: DispatchQueue.main)
                .sink { [weak self] data in
                    guard let `self` = self,
                          let collection = self.collectionView
                    else { return }
                    collection.reloadSections(IndexSet(integer: 2))
                }
                .store(in: &bindings)
            
            self.vm.event.$eventMissions
                .receive(on: DispatchQueue.main)
                .sink { [weak self] data in
                    guard let `self` = self,
                          let collection = self.collectionView
                    else { return }
                    if self.screenToShow == 1 {
                        collection.reloadData()
                    }
                }
                .store(in: &bindings)
                
            self.vm.event.$missionPerLevel
                .receive(on: DispatchQueue.main)
                .sink {
                    print("Per level: \($0[0]?.count ?? 999)")
                }
                .store(in: &bindings)
            
            self.vm.mission.$isHistorySectionOpened
                .receive(on: DispatchQueue.main)
                .sink { [weak self]  in
                    guard let `self` = self,
                          let collection = self.collectionView
                    else { return }
                    if $0 && !self.vm.mission.isPointHistoryFetched {
                        self.vm.mission.isPointHistoryFetched = true
                        Task {
                            await self.vm.fetchPointHistory()
                            self.vm.mission.isPointHistoryFetched = false
                        }
                    }
//                    collection.reloadSections(IndexSet(integer: 4))
//                    collection.reloadSections(IndexSet(integer: 5))
                    collection.reloadData()
                }
                .store(in: &bindings)
            
            self.vm.mission.$participatedMissions
                .receive(on: DispatchQueue.main)
                .sink { [weak self] missions in
                    guard let `self` = self,
                          let collection = self.collectionView
                    else { return }
                    collection.reloadSections(IndexSet(integer: 5))
                }
                .store(in: &bindings)
            
            self.vm.mission.dateSelected
                .receive(on: DispatchQueue.main)
                .sink { [weak self] date in
                    guard let `self` = self else { return }
                    if !self.vm.mission.isDateSelected {
                        self.vm.mission.isDateSelected = true
                    }
                    let dateString = date.yearMonthDateFormat
                    self.vm.mission.selectedDatePointHistory = self.vm.mission.participatedHistory.filter {
                        $0.userPointTime == dateString
                    }.first
                }
                .store(in: &bindings)

            self.vm.mission.$selectedDateMissions
                .receive(on: DispatchQueue.main)
                .sink { [weak self] info in
                    guard let `self` = self else { return }
                    self.collectionView?.reloadSections(IndexSet(integer: 5))
                }
                .store(in: &bindings)
            
            self.vm.$updatedNfts
                .receive(on: DispatchQueue.main)
                .sink { [weak self] nfts in
                    guard let `self` = self else { return }
                   // TODO: Show bottom sheet
                    for nft in nfts {
                        let level = NftLevel.level(tokenId: Int64(nft) ?? 0)
                        if level < 6 {
                            self.showLevelUpBottomSheet(level: level)
                        } else {
                            self.showNewNftBottomSheet(tokenId: nft)
                        }
                    }
                }
                .store(in: &bindings)
        }
        
        bindViewToViewModel()
        bindViewModelToView()
    }
}

//MARK: - Set UI & Layout
extension MyPageViewController {
    
    private func setUI() {
        
        let collectionView = self.createCollectionView()
        self.collectionView = collectionView
        collectionView.backgroundColor = .systemGray6
        
        self.view.addSubviews(collectionView,
                              self.containerView)
        
        self.containerView.addSubviews(self.whiteBackView,
                                       self.shadowView,
                                       self.userProfileView,
                                       self.buttonStack)
        
        self.buttonStack.addArrangedSubviews(self.missionButton,
                                             self.eventButton)
    }
    
    private func setLayout() {
        let navHeight = self.navigationController?.navigationBar.frame.height ?? 0
        
        guard let collectionView = self.collectionView else { return }
        collectionView.frame = view.bounds

        collectionView.contentInset = UIEdgeInsets(top: self.initialHeight - (navHeight*1.6),
                                                   left: 0,
                                                   bottom: 0,
                                                   right: 0)
        
        self.topConstraint = self.containerView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: self.topOffset)
        self.topConstraint?.isActive = true
        
        self.heightConstraint = self.containerView.heightAnchor.constraint(equalToConstant: self.initialHeight)
        self.heightConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            self.containerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            
            self.userProfileView.topAnchor.constraint(equalToSystemSpacingBelow: self.containerView.topAnchor, multiplier: 10),
            self.userProfileView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.userProfileView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.userProfileView.bottomAnchor.constraint(equalTo: self.buttonStack.topAnchor),
            
            self.shadowView.topAnchor.constraint(equalTo: self.userProfileView.topAnchor),
            self.shadowView.leadingAnchor.constraint(equalTo: self.userProfileView.leadingAnchor),
            self.shadowView.trailingAnchor.constraint(equalTo: self.userProfileView.trailingAnchor),
            self.userProfileView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.shadowView.bottomAnchor, multiplier: 3),
            
            self.whiteBackView.topAnchor.constraint(equalTo: self.userProfileView.topAnchor),
            self.whiteBackView.leadingAnchor.constraint(equalTo: self.userProfileView.leadingAnchor),
            self.whiteBackView.trailingAnchor.constraint(equalTo: self.userProfileView.trailingAnchor),
            self.whiteBackView.bottomAnchor.constraint(equalTo: self.userProfileView.bottomAnchor),
            
            self.buttonStack.heightAnchor.constraint(equalToConstant: 60),
            self.buttonStack.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.buttonStack.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.buttonStack.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor)
        ])
        
    }
    
    private func setNavigationItem() {
        self.title = SideMenuConstants.home
        let menuItem = UIBarButtonItem(image: UIImage(systemName: SFSymbol.list)?.withTintColor(.black, renderingMode: .alwaysOriginal),
                                       style: .plain,
                                       target: self,
                                       action: #selector(openSideMenu))
        
        let speakerItem = UIBarButtonItem(image: UIImage(named: ImageAsset.speaker)?.withTintColor(.systemGray, renderingMode: .alwaysOriginal),
                                          style: .plain,
                                          target: self,
                                          action: #selector(speakerDidTap))
        
        self.navigationItem.setLeftBarButton(menuItem, animated: true)
        self.navigationItem.setRightBarButton(speakerItem, animated: true)
    }
    
    @objc func speakerDidTap() {
        //TODO: 공지사항 열람
    }
    
    private func setDelegate() {
        
        guard let collectionView = collectionView else { return }
        collectionView.delegate = self
        collectionView.dataSource = self
        
    }
    
    @objc func openSideMenu() {
        slideInTransitioningDelegate.direction = .left
        
        let vm = SideMenuViewViewModel()
        let sidemenuVC = SideMenuViewController(vm: vm)
        self.sideMenuVC = sidemenuVC
        sidemenuVC.transitioningDelegate = slideInTransitioningDelegate
        sidemenuVC.modalPresentationStyle = .custom
        sidemenuVC.delegate = self
        self.navigationController?.present(sidemenuVC, animated: true)
    }
    
}

extension MyPageViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if !isSet {
            self.initialTopOffset = scrollView.contentOffset.y
            self.isSet = true
        }
        
        if scrollView.contentOffset.y < self.initialTopOffset - 150 {
            // TODO: Refresh indicator 나타내기. Luniverse API Call.
            self.refreshControl.beginRefreshing()
        }
        
        self.topConstraint?.constant = self.initialTopOffset - scrollView.contentOffset.y
        let offset = -scrollView.contentOffset.y
        let newAlpha = (offset)/self.initialHeight
        
        self.shadowView.alpha = newAlpha
        self.userProfileView.alpha = newAlpha
    }
}

// MARK: - Create CollectionView
extension MyPageViewController {
    
    private func createCollectionView() -> UICollectionView {
        let layout = UICollectionViewCompositionalLayout {  sectionIndex, _ in
            return self.createSection(for: sectionIndex)
        }
        
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        
        collectionView.refreshControl = self.refreshControl
        
        collectionView.register(
            TestCollectionViewCell.self,
            forCellWithReuseIdentifier: TestCollectionViewCell.identifier
        )
        
        // 1. Register header
        collectionView.register(MissionCollectionViewHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: MissionCollectionViewHeader.identifier)
        
        // 2. Register cell
        collectionView.register(
            UICollectionViewCell.self,
            forCellWithReuseIdentifier: UICollectionViewCell.identifier
        )
        
        // Mission Cells
        collectionView.register(
            TodayMissionCollectionViewCell.self,
            forCellWithReuseIdentifier: TodayMissionCollectionViewCell.identifier
        )
        
        collectionView.register(
            RoutineMissionSelectCollectionViewCell.self,
            forCellWithReuseIdentifier: RoutineMissionSelectCollectionViewCell.identifier
        )
        
        collectionView.register(
            RoutineMissionProgressCollectionViewCell.self,
            forCellWithReuseIdentifier: RoutineMissionProgressCollectionViewCell.identifier
        )
        
        collectionView.register(
            MypageMissionCollectionViewCell.self,
            forCellWithReuseIdentifier: MypageMissionCollectionViewCell.identifier
        )
        
        collectionView.register(
            MissionHistoryButtonCollectionViewCell.self,
            forCellWithReuseIdentifier: MissionHistoryButtonCollectionViewCell.identifier
        )
        
        collectionView.register(
            MissionHistoryCalendarCollectionViewCell.self,
            forCellWithReuseIdentifier: MissionHistoryCalendarCollectionViewCell.identifier
        )
        
        collectionView.register(
            MissionHistoryDetailCollectionViewCell.self,
            forCellWithReuseIdentifier: MissionHistoryDetailCollectionViewCell.identifier
        )
        
        // Event Cell
        collectionView.register(
            MypageEventCollectionViewCell.self,
            forCellWithReuseIdentifier: MypageEventCollectionViewCell.identifier
        )
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }
    
    private func createSection(for section: Int) -> NSCollectionLayoutSection {
        
        switch section {
        case 0:
            return self.createTodayMissionSectionLayout()
        case 1:
            return self.createRoutineMissionSectionLayout()
        case 2:
            return self.createWeeklyMissionSectionLayout()
        case 3:
            return self.createHistoryButtonSectionLayout()
        case 4:
            return self.createCalendarSectionLayout()
        case 5:
            return self.createHistorySectionLayout()
        default:
            return self.createTest()
        }
        
    }
    
    private func createTest() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
        )
        
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(2.0)
            ),
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        
        return section
    }
    
    // Missions
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
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 10, trailing: 20)
        
        let section = NSCollectionLayoutSection(group: group)
        
        return section
    }
    
    private func createRoutineMissionSectionLayout() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
        )
        
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(0.15)
            ),
            subitems: [item]
        )
        
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
        
        let section = NSCollectionLayoutSection(group: group)
        
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(0.09)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    private func createWeeklyMissionSectionLayout() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
        )
        
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(0.15)
            ),
            subitems: [item]
        )
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 10, trailing: 20)
        
        let section = NSCollectionLayoutSection(group: group)
        
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(0.1)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        
        section.boundarySupplementaryItems = [header]
        return section
    }
    
    private func createHistoryButtonSectionLayout() -> NSCollectionLayoutSection {
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
    
    private func createCalendarSectionLayout() -> NSCollectionLayoutSection {
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
    
    private func createHistorySectionLayout() -> NSCollectionLayoutSection {
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
    
    // Event
    private func createEventSectionLayout() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(0.1)
            )
        )
        
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(1.0)
            ),
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        
        return section
    }
}

extension MyPageViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        switch self.screenToShow {
        case 0:
            return self.vm.missionSections.count
        case 1:
            return self.vm.eventSections.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.screenToShow == 0 {
            switch section {
            case 2:
                // NOTE: self.vm.weeklyMissions.count 시 에러 확인
                //            return self.vm.weeklyMissions.count
                return 3
            case 4:
                return self.vm.mission.isHistorySectionOpened ? 1 : 0
            case 5:
                var numberOfItems: Int = 0
                
                if self.vm.mission.isDateSelected { // 특정 날짜가 선택된 경우
                    numberOfItems = self.vm.mission.selectedDateMissions.count
                    
                } else { // 날짜가 선택되지 않은 경우
                    numberOfItems = self.vm.mission.participatedMissions.count
                }
                
                return self.vm.mission.isHistorySectionOpened ? numberOfItems : 0
            case 6:
                 return self.vm.mission.isHistorySectionOpened ? 1 : 0
            default:
                return 1
            }
        } else {
            print("Itmes: \(self.vm.event.eventMissions.count)")
            return self.vm.event.eventMissions.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if self.screenToShow == 0{
            switch indexPath.section {
            case 0:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TodayMissionCollectionViewCell.identifier, for: indexPath) as? TodayMissionCollectionViewCell else {
                    fatalError()
                }
                guard let vm = self.vm.userProfileViewModel else {
                    return cell
                }
                
                cell.configure(with: vm)
                return cell
                
                // Routine mission
            case 1:
                if self.vm.mission.savedMissionType == nil {
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RoutineMissionSelectCollectionViewCell.identifier, for: indexPath) as? RoutineMissionSelectCollectionViewCell else {
                        fatalError()
                    }
                    
                    return cell
                } else {
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RoutineMissionProgressCollectionViewCell.identifier, for: indexPath) as? RoutineMissionProgressCollectionViewCell else {
                        fatalError()
                    }
                    cell.bind(with: self.vm)
                    return cell
                }
                
                // Weekly mission
            case 2:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MypageMissionCollectionViewCell.identifier, for: indexPath) as? MypageMissionCollectionViewCell else {
                    fatalError()
                }
                cell.resetCell()
                
                if !self.vm.mission.weeklyMissions.isEmpty {
                    let weekCollection = String(format: "weekly_quiz__%d__mission_set", (indexPath.item + 1))
                    let missionInfo = self.vm.mission.weeklyMissions[weekCollection] ?? []
                    let begin = missionInfo[0].dateValue().monthDayFormat
                    let end = missionInfo[1].dateValue().monthDayFormat
                    let weekTotalPoint: Int64 = 100 // TODO: Query from DB
                    
                    if missionInfo[0].dateValue() > Date() {
                        cell.configure(type: .close,
                                       title: weekCollection,
                                       period: begin + " - " + end,
                                       point: weekTotalPoint,
                                       openDate: begin)
                        return cell
                    } else {
                        cell.configure(type: .open, // open
                                       title: weekCollection,
                                       period: begin + " - " + end,
                                       point: weekTotalPoint)
                        return cell
                    }
                } else {
                    return cell
                }
                
                
                // Mission History button
            case 3:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MissionHistoryButtonCollectionViewCell.identifier, for: indexPath) as? MissionHistoryButtonCollectionViewCell else {
                    fatalError()
                }
                
                cell.delegate = self
                return cell
                
            case 4:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MissionHistoryCalendarCollectionViewCell.identifier, for: indexPath) as? MissionHistoryCalendarCollectionViewCell else {
                    fatalError()
                }
                cell.delegate = self
                cell.bind(with: self.vm)
                
                return cell
                
            case 5:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MissionHistoryDetailCollectionViewCell.identifier, for: indexPath) as? MissionHistoryDetailCollectionViewCell else {
                    fatalError()
                }
                
                if self.vm.mission.isDateSelected {
                    let data = self.vm.mission.selectedDateMissions[indexPath.item]
                    cell.configure(title: data.missionContentTitle ?? "no-title")
                    
                    return cell
                } else {
                    let data = self.vm.mission.participatedMissions[indexPath.item]
                    cell.configure(title: data.missionContentTitle ?? "no-title")
                    
                    return cell
                }
                
            default:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TestCollectionViewCell.identifier, for: indexPath) as? TestCollectionViewCell else {
                    fatalError()
                }
                return cell
            }
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MypageEventCollectionViewCell.identifier, for: indexPath) as? MypageEventCollectionViewCell else {
                fatalError()
            }
            cell.resetCell()
            
            let mission = self.vm.event.eventMissions[indexPath.item]

            let participatedUsers = mission.missionUserStateMap ?? [:]
            if participatedUsers.contains(where: { (key, _) in
                key == String(describing: self.vm.user.userIndex)
            }) { // 참여한 경우
                cell.configure(type: .participated,
                               mission: mission)
                
            } else { // 참여하지 않은 경우
                if self.vm.getUserLevel() < mission.missionPermitAvatarLevel {
                    cell.configure(type: .close,
                                   mission: mission)
                } else {
                    cell.configure(type: .open,
                                   mission: mission)
                }
            }
            
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: MissionCollectionViewHeader.identifier,
                for: indexPath
            ) as? MissionCollectionViewHeader else {
                return UICollectionReusableView()
            }
            header.configure(headerText: vm.missionSections[indexPath.section].rawValue,
                             buttonTitle: "자세히 보기")
            return header
            
        default:
            return UICollectionReusableView()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.screenToShow == 0 {
            switch indexPath.section {
            case 1:
                if let missionType = self.vm.mission.savedMissionType {
                    let vm = RoutineMissionDetailViewViewModel(missionType: missionType)
                    let vc = RoutineMissionDetailViewController(vm: vm)

                    self.show(vc, sender: self)
                } else {
                    let vc = RoutineSelectBottomSheetViewController(vm: self.vm)
                    vc.modalPresentationStyle = .overCurrentContext
                    vc.delegate = self
                    self.present(vc, animated: false)
                }
            case 2:
                let vm = WeeklyMissionOverViewViewModel(week: indexPath.item + 1)
                let vc = WeeklyMissionOverViewViewController(vm: vm)

                self.show(vc, sender: self)
            default:
                break
            }
        } else {
            // Temp: 해당 화면 보여주기
            let mission = self.vm.event.eventMissions[indexPath.item]
            let type = MissionFormatType(rawValue: mission.missionFormatType) ?? .commentCount
            
            switch type {
            case .contentReadOnly:
                guard let mission = mission as? ContentReadOnlyMission else { return }
                let vm = ContentReadOnlyMissionViewViewModel(mission: mission, numberOfWeek: 0)
                let vc = ContentReadOnlyMissionViewController(vm: vm, type: .event)
//                vc.delegate = self
                
                self.show(vc, sender: self)
                
            case .shareMediaOnSlack:
                guard let mission = mission as? MediaShareMission else { return }
                let vm = ShareMediaOnSlackMissionViewViewModel(mission: mission)
                let vc = ShareMediaOnSlackMissionViewController(vm: vm)
                vc.delegate = self
                
                self.show(vc, sender: self)
                
            case .governanceElection:
                guard let mission = mission as? GovernanceMission else { return }
                let vm = GovernanceElectionMissionViewViewModel(mission: mission)
                let vc = GovernanceElectionMissionViewController(vm: vm)
                vc.delegate = self
                
                self.show(vc, sender: self)
                
            case .commentCount:
                guard let mission = mission as? CommentCountMission else { return }
                let vm = CommentCountMissionViewViewModel(mission: mission)
                let vc = CommentCountMissionViewController(vm: vm)
                vc.delegate = self
                
                self.show(vc, sender: self)
                
            default:
                break
            }

        }
    }
    
}

extension MyPageViewController: SideMenuViewControllerDelegate {
    func menuTableViewController(controller: SideMenuViewController, didSelectRow selectedRow: Int) {
        
        self.navigationItem.setRightBarButton(nil, animated: true)
        
        for child in self.children {
            child.removeViewController()
        }
        print("Selected row: \(selectedRow)")
        switch selectedRow {
        case 0:
            let speakerItem = UIBarButtonItem(image: UIImage(named: ImageAsset.speaker)?.withTintColor(.systemGray, renderingMode: .alwaysOriginal),
                                              style: .plain,
                                              target: self,
                                              action: nil)
            
            self.navigationItem.setRightBarButton(speakerItem, animated: true)
            self.navigationItem.title = SideMenuConstants.home
            
            // Check nft update
            Task {
                let _ = await self.vm.updateUserOwnedNft()
            }
            
        case 1:
            let vm = WalletViewViewModel()
            let vc = WalletViewController(vm: vm)
            self.addChildViewController(vc)
            self.navigationItem.title = WalletConstants.wallet
            
        case 2:
            let vm = RankingViewViewModel()
            let vc = RankingViewController(vm: vm)
            
            self.addChildViewController(vc)
            self.navigationItem.title = RankingConstants.rank
        
            // pop game
        case 3:
            // NOTE: DEMO FOR NFT TRANSFER
         /*
            Task {
                do {
                    let result = try await NFTServiceManager.shared.requestSingleNft(userIndex: self.vm.user.userIndex, nftType: .gift)
                    print("Result: \(result.data)")
                }
                catch {
                    
                }
            }
            */
            break
            
            // notice
        case 4:
            break
            // FAQ
        case 5:
            break
        default:
            
            break
        }
        self.sideMenuVC?.dismiss(animated: true)
    }
    
    private func shareOnSlack() async -> Bool {
        let urlString = MissionConstants.slackScheme
        guard let url = URL(string: urlString) else {
            self.logger.error("Wrong URL")
            return false
        }
        
        return await UIApplication.shared.open(url)
    }
    
    func resetPasswordDidTap() {
        let vm = EditUserInfoViewViewModel()
        let vc = EditUserInfoViewController(vm: vm)
        self.addChildViewController(vc)
        self.sideMenuVC?.dismiss(animated: true)
    }
    
    func signOutDidTap() {
        self.sideMenuVC?.dismiss(animated: false)
        self.navigationController?.popViewController(animated: true)
    }
}

extension MyPageViewController: MissionHistoryButtonCollectionViewCellDelegate {
    func showMissionButtonDidTap(isOpened: Bool) {
        self.vm.mission.isHistorySectionOpened = isOpened
    }
}

extension MyPageViewController: MissionHistoryCalendarCollectionViewCellDelegate {
    func dateSelected(_ date: Date) {
        self.vm.mission.dateSelected.send(date)
    }
}

// NOTE: Routine selection logic will be deleted.
extension MyPageViewController: RoutineSelectBottomSheetViewControllerDelegate {
    func routineSelected() {
        self.addChildViewController(self.loadingVC)
        
        Task {

            await self.vm.getSelectedRoutine()
            
            DispatchQueue.main.async {
                self.loadingVC.removeViewController()
                guard let collection = self.collectionView else { return }
                collection.reloadSections(IndexSet(integer: 1))
            }
        }
    }
}

extension MyPageViewController: WelcomeBottomSheetViewControllerDelegate {

    func userVipPointSaveStatus(status: Bool) {
        if status {
            self.vm.saveUserToUserDefaults()
        } else {
            // TODO: VIP Point 저장에 실패한 경우
        }
    }
    
}

// MARK: - Private
extension MyPageViewController {
    private func showNewNftBottomSheet(tokenId: String) {
        let vm = NewNFTNoticeBottomSheetViewViewModel(tokenId: tokenId)
        let vc = NewNFTNoticeBottomSheetViewController(vm: vm)
        vc.modalPresentationStyle = .overCurrentContext

        self.present(vc, animated: false)
    }
    
    private func showLevelUpBottomSheet(level: Int) {
        let vc = LevelUpBottomSheetViewController(newLevel: level)
        vc.modalPresentationStyle = .overCurrentContext

        self.present(vc, animated: false)
    }
}


