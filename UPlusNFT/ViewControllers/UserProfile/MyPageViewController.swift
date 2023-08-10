//
//  MyPageViewController.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/21.
//

import UIKit
import Combine
import FirebaseAuth

final class MyPageViewController: UIViewController {
    
    // MARK: - Dependency
    private let vm: MyPageViewViewModel
    private var sideMenuVC: SideMenuViewController?
    
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
    
    private let containerView: PassThroughView = {
        let view = PassThroughView()
        view.backgroundColor = UPlusColor.gradientMediumBlue
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

        if self.vm.isJustRegistered && self.vm.isVIP {
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
            collectionView?.reloadData()
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
            self.vm.$missionViewModel
                .receive(on: DispatchQueue.main)
                .sink { [weak self] mission in
                    guard let `self` = self,
                          let collection = self.collectionView
                    else { return }
                    collection.reloadSections(IndexSet(integer: 0))
                }
                .store(in: &bindings)
            
            self.vm.$savedMissionType
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
            
            self.vm.$weeklyMissions
                .receive(on: DispatchQueue.main)
                .sink { [weak self] data in
                    guard let `self` = self,
                          let collection = self.collectionView
                    else { return }
                    collection.reloadSections(IndexSet(integer: 2))
                }
                .store(in: &bindings)
            
            self.vm.$eventMissions
                .receive(on: DispatchQueue.main)
                .sink { [weak self] data in
                    guard let `self` = self,
                          let collection = self.collectionView
                    else { return }
                    if self.screenToShow == 1 {
                        print("Reloaded")
                        collection.reloadData()
                    }
                }
                .store(in: &bindings)
                
            
            self.vm.$isHistorySectionOpened
                .receive(on: DispatchQueue.main)
                .sink { [weak self]  in
                    guard let `self` = self,
                          let collection = self.collectionView
                    else { return }
                    if $0 && !self.vm.isPointHistoryFetched {
                        self.vm.isPointHistoryFetched = true
                        Task {
                            await self.vm.fetchPointHistory()
                            self.vm.isPointHistoryFetched = false
                        }
                    }
//                    collection.reloadSections(IndexSet(integer: 4))
//                    collection.reloadSections(IndexSet(integer: 5))
                    collection.reloadData()
                }
                .store(in: &bindings)
            
            self.vm.$participatedMissions
                .receive(on: DispatchQueue.main)
                .sink { [weak self] missions in
                    guard let `self` = self,
                          let collection = self.collectionView
                    else { return }
                    print("Missions fetched: \(missions)")
                    collection.reloadSections(IndexSet(integer: 5))
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
                                          action: nil)
        
        self.navigationItem.setLeftBarButton(menuItem, animated: true)
        self.navigationItem.setRightBarButton(speakerItem, animated: true)
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
        //        print("Y OffSet: \(scrollView.contentOffset.y)")
        //        print("Min: \(self.initialHeight)")
        
        if !isSet {
            self.initialTopOffset = scrollView.contentOffset.y
            self.isSet = true
        }
        
        self.topConstraint?.constant = self.initialTopOffset - scrollView.contentOffset.y
        //        print("New top: \(self.initialTopOffset - scrollView.contentOffset.y)")
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
            WeeklyMissionCollectionViewCell.self,
            forCellWithReuseIdentifier: WeeklyMissionCollectionViewCell.identifier
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
            EventCollectionViewCell.self,
            forCellWithReuseIdentifier: EventCollectionViewCell.identifier
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
            return self.createCalendarSectionLayout()
        }
        
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
                return self.vm.isHistorySectionOpened ? 1 : 0
            case 5:
                return self.vm.isHistorySectionOpened ? self.vm.participatedMissions.count : 0
            default:
                return 1
            }
        } else {
            print("Itmes: \(self.vm.eventMissions.count)")
            return self.vm.eventMissions.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if self.screenToShow == 0{
            switch indexPath.section {
            case 0:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TodayMissionCollectionViewCell.identifier, for: indexPath) as? TodayMissionCollectionViewCell else {
                    fatalError()
                }
                guard let vm = self.vm.missionViewModel else {
                    return cell
                }
                
                cell.configure(with: vm)
                return cell
                
                // Routine mission
            case 1:
                if self.vm.savedMissionType == nil {
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
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WeeklyMissionCollectionViewCell.identifier, for: indexPath) as? WeeklyMissionCollectionViewCell else {
                    fatalError()
                }
                cell.resetCell()
                
                if !self.vm.weeklyMissions.isEmpty {
                    let weekCollection = String(format: "weekly_quiz__%d__mission_set", (indexPath.item + 1))
                    let missionInfo = self.vm.weeklyMissions[weekCollection] ?? []
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
                
                // TODO: Calendar
            case 4:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MissionHistoryCalendarCollectionViewCell.identifier, for: indexPath) as? MissionHistoryCalendarCollectionViewCell else {
                    fatalError()
                }
                
                return cell
                
            case 5:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MissionHistoryDetailCollectionViewCell.identifier, for: indexPath) as? MissionHistoryDetailCollectionViewCell else {
                    fatalError()
                }
               
                let data = self.vm.participatedMissions[indexPath.item]
                
                cell.configure(title: data)
                
                return cell
                
            default:
                return UICollectionViewCell()
            }
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EventCollectionViewCell.identifier, for: indexPath) as? EventCollectionViewCell else {
                fatalError()
            }
            cell.configure(with: self.vm.eventMissions[indexPath.item])
            
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
                if let missionType = self.vm.savedMissionType {
                    let vm = DailyRoutineMissionDetailViewViewModel(missionType: missionType)
                    let vc = DailyRoutineMissionDetailViewController(vm: vm)

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
            let mission = self.vm.eventMissions[indexPath.item]
            let type = MissionFormatType(rawValue: mission.missionFormatType) ?? .commentCount
            
            switch type {
            case .contentReadOnly:
                guard let mission = mission as? ContentReadOnlyMission else { return }
                let vm = ContentReadOnlyMissionViewViewModel(mission: mission)
                let vc = ContentReadOnlyMissionViewController(vm: vm)
                self.show(vc, sender: self)
                
            case .shareMediaOnSlack:
                guard let mission = mission as? MediaShareMission else { return }
                let vm = ShareMediaOnSlackMissionViewViewModel(mission: mission)
                let vc = ShareMediaOnSlackMissionViewController(vm: vm)
                self.show(vc, sender: self)
                
            case .governanceElection:
                guard let mission = mission as? GovernanceMission else { return }
                let vm = GovernanceElectionMissionViewViewModel(mission: mission)
                let vc = GovernanceElectionMissionViewController(vm: vm)
                self.show(vc, sender: self)
                
            case .commentCount:
                guard let mission = mission as? CommentCountMission else { return }
                let vm = CommentCountMissionViewViewModel(mission: mission)
                let vc = CommentCountMissionViewController(vm: vm)
                self.show(vc, sender: self)
                
            default:
                break
            }

//            Task {
//                let mission = self.vm.eventMissions[indexPath.item]
//                let type = MissionFormatType(rawValue: mission.missionFormatType) ?? .commentCount
//
//                var selectedIndex: Int?
//                var comment: String?
//
//                switch type {
//                case .governanceElection:
//                    selectedIndex = 1 // NOTE: DEMO
//                case .commentCount:
//                    comment = "Demo comment입니다." // NOTE: DEMO
//                default:
//                   break
//                }
//                do {
//                    try await FirestoreManager.shared.saveParticipatedEventMission(
//                        type: type,
//                        eventId: mission.missionId,
//                        selectedIndex: selectedIndex,
//                        comment: comment,
//                        point: mission.missionRewardPoint
//                    )
//                }
//                catch {
//                    print("Error saving participated event -- \(error)")
//                }
//            }

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
            
        default:
            // TODO: Wallet VC
            break
        }
        self.sideMenuVC?.dismiss(animated: true)
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
        self.vm.isHistorySectionOpened = isOpened
    }
}

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
