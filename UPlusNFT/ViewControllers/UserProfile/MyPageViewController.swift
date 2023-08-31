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
        view.backgroundColor = UPlusColor.gray09
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
        button.setTitleColor(UPlusColor.mint04, for: .normal)
        button.setTitle("미션", for: .normal)
        return button
    }()
    
    private lazy var eventButton: UIButton = {
        let button = UIButton()
        button.tag = 1
        button.addTarget(self, action: #selector(buttonDidTap(_:)), for: .touchUpInside)
        button.backgroundColor = .white
        button.setTitleColor(UPlusColor.gray03, for: .normal)
        button.setTitle("이벤트", for: .normal)
        return button
    }()
    
    private let buttonBottomBar1: PassThroughView = {
        let view = PassThroughView()
        view.backgroundColor = UPlusColor.mint04
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let buttonBottomBar2: PassThroughView = {
        let view = PassThroughView()
        view.isHidden = true
        view.backgroundColor = UPlusColor.mint04
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
            let vm = VipHolderBottomSheetViewViewModel(user: self.vm.user)
            let vc = VipHolderBottomSheetViewController(vm: vm)
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
            switchButton(tag: 0)
            collectionView?.reloadData()
            return
        case 1:
            switchButton(tag: 1)
            Task {
                await self.vm.getRegularEvents()
                await self.vm.getLevelEvents()
            }
        default:
            return
        }
    }
    
    private func switchButton(tag: Int) {
        if tag == 0 {
            UIView.animate(withDuration: 0.3) {
                self.buttonBottomBar1.isHidden = false
                self.buttonBottomBar2.isHidden = true
                self.missionButton.setTitleColor(UPlusColor.mint04, for: .normal)
                self.eventButton.setTitleColor(UPlusColor.gray03, for: .normal)
            }
            
        } else {
            self.buttonBottomBar1.isHidden = true
            self.buttonBottomBar2.isHidden = false
            self.missionButton.setTitleColor(UPlusColor.gray03, for: .normal)
            self.eventButton.setTitleColor(UPlusColor.mint04, for: .normal)
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
//                    collection.reloadSections(IndexSet(integer: 0))
                    collection.reloadData()
                }
                .store(in: &bindings)
            
            self.vm.mission.$weeklyMissions
                .receive(on: DispatchQueue.main)
                .sink { [weak self] data in
                    guard let `self` = self,
                          let collection = self.collectionView
                    else { return }
//                    collection.reloadSections(IndexSet(integer: 2))
                    collection.reloadData()
                }
                .store(in: &bindings)
                
            self.vm.event.$regularEvents
                .receive(on: DispatchQueue.main)
                .sink { [weak self] data in
                    guard let `self` = self,
                          let collection = self.collectionView
                    else { return }
                    if self.screenToShow == 1 {
//                        collection.reloadSections(IndexSet(integer: 1))
                        collection.reloadData()
                    }
                }
                .store(in: &bindings)
            
            self.vm.event.$levelEvents
                .receive(on: DispatchQueue.main)
                .sink { [weak self] data in
                    guard let `self` = self,
                          let collection = self.collectionView
                    else { return }
                    print("Level events: \(data.count)")
                    if self.screenToShow == 1 {
                        collection.reloadData()
                    }
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
//                    collection.reloadSections(IndexSet(integer: 5))
                    collection.reloadData()
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
//                    self.collectionView?.reloadSections(IndexSet(integer: 5))
                    self.collectionView?.reloadData()
                }
                .store(in: &bindings)
            
            self.vm.mission.$routineParticipationStatus
                .receive(on: DispatchQueue.main)
                .sink { [weak self] status in
                    guard let `self` = self else { return }
//                    self.collectionView?.reloadSections(IndexSet(integer: 1))
                    self.collectionView?.reloadData()
                }
                .store(in: &bindings)
            
            self.vm.$updatedNfts
                .receive(on: DispatchQueue.main)
                .sink { [weak self] nfts in
                    guard let `self` = self else { return }
                    if !nfts.isEmpty {
                        self.startPresenting()
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
        collectionView.backgroundColor = UPlusColor.grayBackground
        
        self.view.addSubviews(collectionView,
                              self.containerView)
        
        self.containerView.addSubviews(self.whiteBackView,
                                       self.shadowView,
                                       self.userProfileView,
                                       self.buttonStack)
        
        self.missionButton.addSubview(self.buttonBottomBar1)
        self.eventButton.addSubview(self.buttonBottomBar2)
        
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
        
        NSLayoutConstraint.activate([
            self.buttonBottomBar1.heightAnchor.constraint(equalToConstant: 4),
            self.buttonBottomBar1.widthAnchor.constraint(equalTo: self.missionButton.widthAnchor),
            self.buttonBottomBar1.bottomAnchor.constraint(equalTo: self.missionButton.bottomAnchor),
            
            self.buttonBottomBar2.heightAnchor.constraint(equalToConstant: 4),
            self.buttonBottomBar2.widthAnchor.constraint(equalTo: self.eventButton.widthAnchor),
            self.buttonBottomBar2.bottomAnchor.constraint(equalTo: self.eventButton.bottomAnchor),
        ])
    }
    
    private func setNavigationItem() {
        
        let menuItem = UIBarButtonItem(image: UIImage(named: ImageAsset.hamburgerMenu)?.withTintColor(UPlusColor.gray04, renderingMode: .alwaysOriginal),
                                       style: .plain,
                                       target: self,
                                       action: #selector(openSideMenu))
        
        let walletItem = UIBarButtonItem(image: UIImage(named: ImageAsset.wallet)?.withTintColor(UPlusColor.gray04, renderingMode: .alwaysOriginal),
                                         style: .plain,
                                         target: self,
                                         action: #selector(speakerDidTap))
        
        let speakerItem = UIBarButtonItem(image: UIImage(named: ImageAsset.speaker)?.withTintColor(UPlusColor.gray04, renderingMode: .alwaysOriginal),
                                          style: .plain,
                                          target: self,
                                          action: #selector(speakerDidTap))
        
        self.navigationItem.setLeftBarButton(menuItem, animated: true)
        self.navigationItem.setRightBarButtonItems([speakerItem, walletItem], animated: true)
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
        
        if !self.vm.isRefreshing && scrollView.contentOffset.y < self.initialTopOffset - 200 {
            logger.debug("Refreshing")
            self.vm.isRefreshing.toggle()
            
            self.refreshControl.beginRefreshing()
            self.refreshControl.isHidden = true
            
            Task {
                await self.vm.createMissionMainViewViewModel()
                self.vm.isRefreshing.toggle()
                self.refreshControl.endRefreshing()
            }
        }
        
        self.topConstraint?.constant = self.initialTopOffset - scrollView.contentOffset.y
        let offset = -scrollView.contentOffset.y
        let newAlpha = (offset)/(self.initialHeight / 1.5)
        
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
        
        // 1. Register header
        collectionView.register(MissionCollectionViewHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: MissionCollectionViewHeader.identifier)
        
        collectionView.register(UICollectionReusableView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: UICollectionReusableView.identifier)
        
        
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
            NewEventCollectionViewCell.self,
            forCellWithReuseIdentifier: NewEventCollectionViewCell.identifier
        )

        collectionView.register(
            RoutineMissionProgressCollectionViewCell.self,
            forCellWithReuseIdentifier: RoutineMissionProgressCollectionViewCell.identifier
        )
        
        collectionView.register(
            WeeklyMissionCollectionViewCell.self,
            forCellWithReuseIdentifier: WeeklyMissionCollectionViewCell.identifier
        )
        
        collectionView.register(
            WeeklyLockedCollectionViewCell.self,
            forCellWithReuseIdentifier: WeeklyLockedCollectionViewCell.identifier
        )
        
        collectionView.register(
            WeeklyCompletedCollectionViewCell.self,
            forCellWithReuseIdentifier: WeeklyCompletedCollectionViewCell.identifier
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
        
        collectionView.register(
            MissionHistoryNoParticipationCollectionViewCell.self,
            forCellWithReuseIdentifier: MissionHistoryNoParticipationCollectionViewCell.identifier
        )
        
        // Event Cell
        collectionView.register(
            MypageEventCollectionViewCell.self,
            forCellWithReuseIdentifier: MypageEventCollectionViewCell.identifier
        )
        
        collectionView.register(
            LevelDividerCollectionViewCell.self,
            forCellWithReuseIdentifier: LevelDividerCollectionViewCell.identifier
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
            return self.createTodayMissionSectionLayout()
        case 3:
            return self.createWeeklyMissionSectionLayout()
        case 4:
            return self.createHistoryButtonSectionLayout()
        case 5:
            return self.createCalendarSectionLayout()
        case 6:
            return self.createHistorySectionLayout()

        default:
            return self.createHistorySectionLayout()
        }
        
    }
    
    private func createLevel0MissionSectionLayout() -> NSCollectionLayoutSection {
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
 
    // Missions
    private func createTodayMissionSectionLayout() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(150)
            )
        )
        
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(150)
            ),
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        
        return section
    }
    
    private func createRoutineMissionSectionLayout() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(150)
            )
        )
        
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(150)
            ),
            subitems: [item]
        )
        
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 10.0
        
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
                heightDimension: .estimated(110)
            )
        )
        
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(110)
            ),
            subitems: [item]
        )
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 10
        
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
            case 0, 2, 4:
                return 1
            case 1:
                return 2
            case 3:
                // NOTE: self.vm.weeklyMissions.count 시 에러 확인
                //            return self.vm.weeklyMissions.count
                return 3
            case 5:
                return self.vm.mission.isHistorySectionOpened ? 1 : 0
            case 6:
                var numberOfItems: Int = 0
                
                if self.vm.mission.isDateSelected {
                    numberOfItems = self.vm.mission.selectedDateMissions.count
                    
                } else {
                    numberOfItems = self.vm.mission.participatedMissions.count
                }
                
                return self.vm.mission.isHistorySectionOpened ? numberOfItems : 0
                
            case 7:
                 return self.vm.mission.isHistorySectionOpened ? 1 : 0
                
            default:
                return 1
            }
            
        } else {
            
            switch section {
            case 0:
                return 1
                
            case 1:
                return self.vm.event.regularEvents.count
                
            case 3:
                return self.vm.event.levelEvents.count
                
            default:
                return 0
            }
        
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if self.screenToShow == 0 {
            switch indexPath.section {
            case 0:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TodayMissionCollectionViewCell.identifier, for: indexPath) as? TodayMissionCollectionViewCell else {
                    fatalError()
                }
                guard let vm = self.vm.userProfileViewModel else {
                    return cell
                }
                
                cell.type = .daily
                cell.configure(with: vm)
                return cell
                
                // Routine mission
            case 1:
                if indexPath.item == 0 {
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RoutineMissionProgressCollectionViewCell.identifier, for: indexPath) as? RoutineMissionProgressCollectionViewCell else {
                        fatalError()
                    }
                    cell.bind(with: self.vm)
                    return cell
                } else {
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewEventCollectionViewCell.identifier, for: indexPath) as? NewEventCollectionViewCell else {
                        fatalError()
                    }
                    return cell
                }
                
                // Weekly mission
            case 2:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TodayMissionCollectionViewCell.identifier, for: indexPath) as? TodayMissionCollectionViewCell else {
                    fatalError()
                }
                guard let vm = self.vm.userProfileViewModel else {
                    return cell
                }
                
                cell.type = .weekly
                cell.configure(with: vm)
                return cell
                
            case 3:
                let baseCell = collectionView.dequeueReusableCell(withReuseIdentifier: UICollectionViewCell.identifier, for: indexPath)

                if !self.vm.mission.weeklyMissions.isEmpty {
                    
                    let (status, collectionId) = self.weeklyMissionInfo(week: indexPath.item + 1)
                    let title = self.vm.mission.missionTitles[indexPath.item]
                    
                    let missionInfo = self.vm.mission.weeklyMissions[collectionId] ?? []
                    
                    let begin = missionInfo[0].dateValue()
                    let end = missionInfo[1].dateValue()
                    let today = Date()
                    
                    let timeLeft = self.vm.timeDifference(from: today, to: end)
                    let weekTotalPoint: Int64 = 600 // TODO: Query from DB
                    
                    switch status {
                    case .before:
                        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WeeklyLockedCollectionViewCell.identifier, for: indexPath) as? WeeklyLockedCollectionViewCell else {
                            fatalError()
                        }
                        
                        cell.configure(title: title, openDate: begin.monthDayFormat)

                        return cell
                        
                    case .open:
                        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WeeklyMissionCollectionViewCell.identifier, for: indexPath) as? WeeklyMissionCollectionViewCell else {
                            fatalError()
                        }
                        cell.resetCell()
                        cell.configure(item: indexPath.item,
                                       title: title,
                                       period: timeLeft,
                                       numberOfParticipation: vm.mission.numberOfFinishedMissions[indexPath.item],
                                       point: weekTotalPoint)

                        return cell
                        
                    case .close:
                        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WeeklyCompletedCollectionViewCell.identifier, for: indexPath) as? WeeklyCompletedCollectionViewCell else {
                            fatalError()
                        }
                        
                        cell.configure(title: title)

                        return cell
                    }

                } else {
                    return baseCell
                }
                
                // Mission History button
            case 4:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MissionHistoryButtonCollectionViewCell.identifier, for: indexPath) as? MissionHistoryButtonCollectionViewCell else {
                    fatalError()
                }
                
                cell.delegate = self
                return cell
                
            case 5:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MissionHistoryCalendarCollectionViewCell.identifier, for: indexPath) as? MissionHistoryCalendarCollectionViewCell else {
                    fatalError()
                }
                cell.delegate = self
                cell.bind(with: self.vm)
                
                return cell
                
            case 6:
//                guard let goToMissionCell = collectionView.dequeueReusableCell(withReuseIdentifier: MissionHistoryNoParticipationCollectionViewCell.identifier, for: indexPath) as? MissionHistoryNoParticipationCollectionViewCell else {
//                    fatalError()
//                }
                
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MissionHistoryDetailCollectionViewCell.identifier, for: indexPath) as? MissionHistoryDetailCollectionViewCell else {
                    fatalError()
                }
                
                if self.vm.mission.isDateSelected {
                    let data = self.vm.mission.selectedDateMissions[indexPath.item]
                    cell.configure(title: data.missionContentTitle ?? "no-title",
                                   point: data.missionRewardPoint)
                    
                    return cell
                } else {
                    let data = self.vm.mission.participatedMissions[indexPath.item]
                    cell.configure(title: data.missionContentTitle ?? "no-title",
                                   point: data.missionRewardPoint)
                    
                    return cell
                }
                
            default:
                
                return UICollectionViewCell()
            }
        } else {
            switch indexPath.section {
            case 0:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TodayMissionCollectionViewCell.identifier, for: indexPath) as? TodayMissionCollectionViewCell else {
                    fatalError()
                }
                guard let vm = self.vm.userProfileViewModel else {
                    return cell
                }
                
                cell.type = .event
                cell.configure(with: vm)
                return cell
                
                
            case 1:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MypageEventCollectionViewCell.identifier, for: indexPath) as? MypageEventCollectionViewCell else {
                    fatalError()
                }
                cell.resetCell()
                
                
                let mission = self.vm.event.regularEvents[indexPath.item]
                
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
                
            case 3:
                
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MypageEventCollectionViewCell.identifier, for: indexPath) as? MypageEventCollectionViewCell else {
                    fatalError()
                }
                
                cell.resetCell()
                
                guard let dividerCell = collectionView.dequeueReusableCell(withReuseIdentifier: LevelDividerCollectionViewCell.identifier, for: indexPath) as? LevelDividerCollectionViewCell else {
                    fatalError()
                }

                guard let mission = self.vm.event.levelEvents[indexPath.item] else {
                    
                    dividerCell.configure(level: 1)
                    return dividerCell
                }

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
                
            default:
                return collectionView.dequeueReusableCell(withReuseIdentifier: UICollectionViewCell.identifier, for: indexPath)
                
            }
        
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
        
            header.delegate = self
            
            var headerType: MissionHeaderType = .master
            if self.screenToShow == 0 {
                
                switch vm.missionSections[indexPath.section] {
                case .todayDetail:
                    headerType = .master
                case .weeklyDetail:
                    headerType = .world
                default:
                    break
                }
                
                header.configure(type: headerType,
                                 headerText: vm.missionSections[indexPath.section].rawValue,
                                 buttonTitle: MissionConstants.details)
                return header
            } else {
                switch vm.eventSections[indexPath.section] {
                case .regularEvent:
                    headerType = .contest
                case .levelEvent:
                    headerType = .level
                default:
                    break
                }
                
                header.configure(type: headerType,
                                 headerText: vm.eventSections[indexPath.section].rawValue,
                                 buttonTitle: MissionConstants.details)
                
                return header
            }

        default:
            return UICollectionReusableView()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // 퀘스트
        if self.screenToShow == 0 {
            switch indexPath.section {
            case 1:
                let participationStatus = self.vm.mission.routineParticipationStatus
                
                // NOTE: pending status에 대한 temporary action
                if participationStatus == .pending {
                    
                    let action = UIAlertAction(title: "확인", style: .cancel)
                    let alert = UIAlertController(title: "이미 참여하셨습니다!", message: "현재 미션 참여 검토 중입니다.", preferredStyle: .alert)
                    alert.addAction(action)
                    
                    self.present(alert, animated: true)
                    
                    return
                }
                
                self.addChildViewController(self.loadingVC)
                let vm = RoutineMissionDetailViewViewModel(missionType: .dailyExpGoodWorker)
                let vc = RoutineMissionDetailViewController2(vm: vm)
                vc.delegate = self
                
                self.loadingVC.removeViewController()
                
                self.show(vc, sender: self)
                
            case 3:
                
                let (status, title) = self.weeklyMissionInfo(week: indexPath.item + 1)
                let missionInfo = self.vm.mission.weeklyMissions[title] ?? []
                let end = missionInfo[1].dateValue()

                switch status {
                case .open:
                    let vm = WeeklyMissionOverViewViewModel(week: indexPath.item + 1, endDate: end)
                    let vc = WeeklyMissionOverViewViewController(vm: vm)

                    self.show(vc, sender: self)
                case .before, .close:
                    return
                }
                
            default:
                break
            }
            
        // 이벤트
        } else {
   
            var anyMission: (any Mission)?
            
            switch indexPath.section {
            case 1:
                anyMission = self.vm.event.regularEvents[indexPath.item]
            case 3:
                anyMission = self.vm.event.levelEvents[indexPath.item]
            default:
                return
            }
            
            guard let mission = anyMission else { return }
            let type = MissionSubFormatType(rawValue: mission.missionSubFormatType) ?? .userComment
            let topicType = MissionTopicType(rawValue: mission.missionTopicType) ?? .eventMission
            
            switch type {
            case .photoAuthManagement, .photoAuthNoManagement:
                guard let mission = mission as? PhotoAuthMission else { return }
                let vm = PhotoAuthQuizViewViewModel(type: .event, mission: mission)
                let vc = PhotoAuthQuizViewController(vm: vm)
                vc.delegate = self
                
                self.show(vc, sender: self)
                
            case .contentReadOnly:
                guard let mission = mission as? ContentReadOnlyMission else { return }
                let vm = ContentReadOnlyMissionViewViewModel(type: .event, mission: mission, numberOfWeek: 0)
                let vc = ContentReadOnlyMissionViewController(vm: vm, type: .event)
//                vc.delegate = self
                
                self.show(vc, sender: self)

            case .governanceElection:
                guard let mission = mission as? GovernanceMission else { return }
                let vm = GovernanceElectionMissionViewViewModel(type: .event, mission: mission)
                let vc = GovernanceElectionMissionViewController(vm: vm)
                vc.delegate = self
                
                self.show(vc, sender: self)
                
            case .userCommentRich:
                guard let mission = mission as? CommentCountMission else { return }
                let vm = CommentCountMissionViewViewModel(type: .event, mission: mission)
                let vc = CommentCountMissionViewController(vm: vm)
                vc.delegate = self
                
                self.show(vc, sender: self)
                
            case .userCommentAuthSharing:
                    guard let mission = mission as? CommentCountMission else { return }
                    let vm = ShareMediaOnSlackMissionViewViewModel(level: Int(self.vm.userProfileViewModel?.level ?? 0), type: .event, mission: mission)
                    let vc = ShareMediaOnSlackMissionViewController(vm: vm)
    //                vc.delegate = self
                    
                    self.show(vc, sender: self)
                
            case .choiceQuizOX:
                guard let mission = mission as? ChoiceQuizMission else { return }
                let vm = ChoiceQuizzOXViewViewModel(type: .event, mission: mission)
                let vc = ChoiceQuizOXViewController(vm: vm)
                
                self.show(vc, sender: self)
                
            case .choiceQuizMore:
                guard let mission = mission as? ChoiceQuizMission else { return }
                let vm = ChoiceQuizMoreViewViewModel(type: .event, mission: mission)
                let vc = ChoiceQuizMoreViewController(vm: vm)
                
                self.show(vc, sender: self)
                
            case .choiceQuizVideo:
                guard let mission = mission as? ChoiceQuizMission else { return }
                let vm = ChoiceQuizVideoViewViewModel(type: .event, mission: mission)
                let vc = ChoiceQuizVideoViewController(vm: vm)
                
                self.show(vc, sender: self)
                
            default:
                break
            }

        }
    }
    
}

// MARK: - Private
extension MyPageViewController {
    
    private func weeklyMissionInfo(week: Int) -> (status: WeeklyCellType, title: String) {
        let weekCollection = String(format: FirestoreConstants.weeklyQuizMissionSetCollection, week)
        let missionInfo = self.vm.mission.weeklyMissions[weekCollection] ?? []
        
        let begin = missionInfo[0].dateValue()
        let end = missionInfo[1].dateValue()
        let today = Date()
        
        if begin > today {
            return (.before, weekCollection)
        } else if end > today {
            return (.open, weekCollection)
        } else {
            return (.before, weekCollection)
        }
    }
    
}

// MARK: - Routine Detail VC Delegate
extension MyPageViewController: RoutineMissionDetailViewController2Delegate {
    func submitDidTap() {
        self.vm.mission.routineParticipationStatus = .pending
    }
}

// MARK: - Side Menu Delegate
extension MyPageViewController: SideMenuViewControllerDelegate {
    func menuTableViewController(controller: SideMenuViewController, didSelectRow selectedRow: Int) {
        
        self.navigationItem.setRightBarButton(nil, animated: true)
        
        for child in self.children {
            child.removeViewController()
        }
        
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
            
            break
            
            // notice
        case 4:
            self.openURL(from: EnvironmentConfig.uplusNoticeLink)
            
            break
            // FAQ
        case 5:
            print("\(EnvironmentConfig.uplusFaqLink)")
            self.openURL(from: EnvironmentConfig.uplusFaqLink)
            break
        default:
            
            break
        }
        self.sideMenuVC?.dismiss(animated: true)
    }
    
    private func openURL(from urlString: String) {
        if let url = URL(string: urlString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
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
        let vm = EditPasswordViewViewModel()
        let vc = EditPasswordViewController(vm: vm)
        self.addChildViewController(vc)
        self.sideMenuVC?.dismiss(animated: true)
    }
    
    func signOutDidTap() {
        self.sideMenuVC?.dismiss(animated: false)
        
        let vc = LogOutBottomSheetViewController()
        vc.modalPresentationStyle = .overCurrentContext
//        vc.delegate = self
        
        self.present(vc, animated: false)

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

extension MyPageViewController: VipHolderBottomSheetViewControllerDelegate {

    func userVipPointSaveStatus(status: Bool) {
        if status {
            self.vm.saveUserToUserDefaults()
        } else {
            // TODO: VIP Point 저장에 실패한 경우
        }
    }
    
}

// MARK: - Private
extension MyPageViewController: NftBottomSheetDelegate {
    
    func redeemButtonDidTap() {
        self.presentBottomSheets()
    }
    
    private func presentBottomSheets() {
        logger.info("Present bottom sheets: \(self.vm.updatedNftsCopy)")
        
        guard !self.vm.updatedNftsCopy.isEmpty else {
            logger.info("No more nfts")
            return
        }
        
        let nft = self.vm.updatedNftsCopy.removeFirst()
        let level = NftLevel.level(tokenId: Int64(nft) ?? 0)
        
        if level < 10 && level > 1 {
            logger.info("Show level up: \(String(describing: level))")
            self.showLevelUpBottomSheet(level: level, tokenId: nft)
            
        } else if level == 10 {
            logger.info("Show new nft: \(String(describing: nft))")
            self.showNewNftBottomSheet(tokenId: nft)
        
        } else {
            logger.info("Skip: token no. \(nft)")
            self.redeemButtonDidTap()
        }

    }
    
    // Call this function initially to start presenting
    private func startPresenting() {
        self.presentBottomSheets()
    }
    
    private func showNewNftBottomSheet(tokenId: String) {
        let vm = NewNFTNoticeBottomSheetViewViewModel(tokenId: tokenId)
        let vc = NewNFTNoticeBottomSheetViewController(vm: vm)
        vc.modalPresentationStyle = .overCurrentContext
        vc.delegate = self
        logger.info("Showing...")
        self.present(vc, animated: false)
    }
    
    private func showLevelUpBottomSheet(level: Int, tokenId: String) {
        let vm = LevelUpBottomSheetViewViewModel(newLevel: level, tokenId: tokenId)
        let vc = LevelUpBottomSheetViewController(vm: vm)
        vc.modalPresentationStyle = .overCurrentContext
        vc.delegate = self
        logger.info("Showing...")
        self.present(vc, animated: false)
    }
}

extension MyPageViewController: MissionCollectionViewHeaderDelegate {
    func detailButtonDidTap(type: MissionHeaderType) {
        var vcHeight: CGFloat = 600
        
        switch type {
        case .contest:
            break
        case .level:
            vcHeight = 400
        case .master:
            vcHeight = 550
        case .world:
            vcHeight = 500
        }
        let vm = DetailInftoBottomSheetViewViewModel(type: type)
        let vc = DetailInftoBottomSheetViewController(vm: vm, defaultHeight: vcHeight)
        
        vc.modalPresentationStyle = .overCurrentContext

        self.present(vc, animated: false)
    }
}
