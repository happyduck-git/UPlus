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
    private var initialHeight: CGFloat = 660
    private var topOffset: CGFloat = 0.0
    private var initialTopOffset: CGFloat = 0.0
    private var isSet: Bool = false
    
    private var topConstraint: NSLayoutConstraint?
    private var heightConstraint: NSLayoutConstraint?
    
    // MARK: - UI Elements
    private let containerView: PassThroughView = {
        let view = PassThroughView()
        view.backgroundColor = UPlusColor.gradientMediumBlue
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let backBtnImage = UIImage(systemName: SFSymbol.arrowLeft)?.withTintColor(.black, renderingMode: .alwaysOriginal)
        
        navigationController?.navigationBar.backIndicatorImage = backBtnImage
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = backBtnImage
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }

    @objc func buttonDidTap(_ sender: UIButton) {
        
    }

}

// MARK: - Bind with View Model
extension MyPageViewController {
    private func bind() {
        func bindViewToViewModel() {
            
        }
        func bindViewModelToView() {
            self.vm.$weeklyMissions
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    guard let `self` = self,
                    let collection = self.collectionView
                    else { return }
                    collection.reloadSections(IndexSet(integer: 2))
                }
                .store(in: &bindings)
            
            self.vm.$isHistorySectionOpened
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    guard let `self` = self else { return }
                    
                    self.collectionView?.reloadSections(IndexSet(integer: 4))
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
                                       self.userProfileView,
                                       self.buttonStack)
        
        self.buttonStack.addArrangedSubviews(self.missionButton,
                                             self.eventButton)
    }
    
    private func setLayout() {
        let navHeight = self.navigationController?.navigationBar.frame.height ?? 0
        
        guard let collectionView = self.collectionView else { return }
        collectionView.frame = view.bounds
        collectionView.contentInset = UIEdgeInsets(top: self.initialHeight - navHeight,
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

        self.userProfileView.alpha = newAlpha
    }
}

// MARK: - Create CollectionView
extension MyPageViewController {
    
    private func createContainerCollectionView() -> UICollectionView {
        let layout = UICollectionViewCompositionalLayout {  sectionIndex, _ in
            return self.createContainerSection(for: sectionIndex)
        }
        
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
       
        collectionView.register(
            UICollectionViewCell.self,
            forCellWithReuseIdentifier: UICollectionViewCell.identifier
        )
        
        return collectionView
    }
    
    private func createContainerSection(for section: Int) -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
        )
        
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(400)
            ),
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        
        return section
    }
    
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
        
        collectionView.register(
            TodayMissionCollectionViewCell.self,
            forCellWithReuseIdentifier: TodayMissionCollectionViewCell.identifier
        )
        
        collectionView.register(
            RoutineMissionCollectionViewCell.self,
            forCellWithReuseIdentifier: RoutineMissionCollectionViewCell.identifier
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
            return self.weeklyMissionSectionLayout()
        case 3:
            return self.createHistorySectionLayout()
        default:
            return self.calendarSectionLayout()
        }
        
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
    
    private func createRoutineMissionSectionLayout() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
        )
        
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.9),
                heightDimension: .fractionalHeight(0.15)
            ),
            subitems: [item]
        )
        
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
    
    private func weeklyMissionSectionLayout() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
        )
        
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.9),
                heightDimension: .fractionalHeight(0.15)
            ),
            subitems: [item]
        )
        
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
    
    private func calendarSectionLayout() -> NSCollectionLayoutSection {
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
                heightDimension: .fractionalHeight(0.08)
            ),
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        return section
    }
    
}

extension MyPageViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.vm.sections.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 2:
            return self.vm.weeklyMissions.count
        case 4:
            return self.vm.isHistorySectionOpened ? 1 : 0
        default:
            return 1
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        switch indexPath.section {
        case 0:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TodayMissionCollectionViewCell.identifier, for: indexPath) as? TodayMissionCollectionViewCell else {
                fatalError()
            }
            cell.configure(with: self.vm.missionViewModel)
            return cell

        // Routine mission
        case 1:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RoutineMissionCollectionViewCell.identifier, for: indexPath) as? RoutineMissionCollectionViewCell else {
                fatalError()
            }

            return cell
        // Weekly mission
        case 2:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WeeklyMissionCollectionViewCell.identifier, for: indexPath) as? WeeklyMissionCollectionViewCell else {
                fatalError()
            }
            cell.resetCell()
            
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
            
            
        // Mission History button
        case 3:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MissionHistoryButtonCollectionViewCell.identifier, for: indexPath) as? MissionHistoryButtonCollectionViewCell else {
                fatalError()
            }
            
            cell.delegate = self
            return cell

            // TODO: Calendar
        default:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MissionHistoryCalendarCollectionViewCell.identifier, for: indexPath) as? MissionHistoryCalendarCollectionViewCell else {
                fatalError()
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
            header.configure(headerText: vm.sections[indexPath.section].rawValue,
                             buttonTitle: "자세히 보기")
            return header
            
        default:
            return UICollectionReusableView()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
           // TODO: 선택 가능한 Daily Mission 보여주기
            let vc = RoutineSelectBottomSheetViewController(vm: self.vm)
            vc.modalPresentationStyle = .overCurrentContext

            self.present(vc, animated: false)
            
        default:
            break
        }
    }

}

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
        case 1:
            
            // NOTE: Temporary cell view model.
            let userEmail = Auth.auth().currentUser?.email ?? "username@gmail.com"
            let username = userEmail.components(separatedBy: "@").first ?? "N/A"
            let tempProfileImage = "https://i.seadn.io/gae/lW22aEwUE0IqGaYm5HRiMS8DwkDwsdjPpprEqYnBqo2s7gSR-JqcYOjU9LM6p32ujG_YAEd72aDyox-pdCVK10G-u1qZ3zAsn2r9?auto=format&dpr=1&w=200"
            
            let tempVM = MissionMainViewViewModel(profileImage: tempProfileImage,
                                                  username: username,
                                                  points: 10,
                                                  maxPoints: 15,
                                                  level: 1,
                                                  numberOfMissions: 4,
                                                  timeLeft: 12,
                                                  dailyMissionCellVMList: [
                                                    DailyMissionCollectionViewCellViewModel(
                                                        missionTitle: "매일 6000보 걷기",
                                                        missionImage: "https://i.seadn.io/gae/0Qx_dJjClFLvuYFGzVUpvrOyjMuWVZjyUAU7FPNHUkg2XQzhgEBrV2kTDD-k8l0RoUiEh3lT93dGRHmb_MA57vQ0z2ZI7AY06qM9qTs?auto=format&dpr=1&w=200",
                                                        missionPoint: 1,
                                                        missionCount: 15
                                                    ),
                                                    DailyMissionCollectionViewCellViewModel(
                                                        missionTitle: "매일 6000보 걷기",
                                                        missionImage: "https://i.seadn.io/gae/PYzUnkLUGXrZp0GHQvNSx8-UWdeus_UxkypDeXRWmroFRL_4eWbxm7LqJvQIUSUdXxHqNRSRWkyc_sWjFrPqAxzsgzY2f6be4x1b9Q?auto=format&dpr=1&w=200",
                                                        missionPoint: 2,
                                                        missionCount: 6
                                                    ),
                                                    DailyMissionCollectionViewCellViewModel(
                                                        missionTitle: "매일 6000보 걷기",
                                                        missionImage: "https://i.seadn.io/gae/hxqKVEpDu1GmI8OIVpUeQFdvqWd6HKUREfEt58lBvCBEtJrTgsIRKOk2UFYVUK8jvwz8ir6sEGir862LntFXXb_shyUXSkkTCagzfA?auto=format&dpr=1&w=200",
                                                        missionPoint: 3,
                                                        missionCount: 10
                                                    )
                                                  ]
            )
            let vc = MissionMainViewController(vm: tempVM)
            self.addChildViewController(vc)
            self.navigationController?.navigationBar.backgroundColor = .white
            self.navigationItem.title = SideMenuConstants.mission
            
        case 2:
            let vm = RankingViewViewModel()
            let vc = RankingViewController(vm: vm)
            
            self.addChildViewController(vc)
            self.navigationItem.title = RankingConstants.rank
            
        default:
            let vc = EditUserInfoViewController()
            
            self.addChildViewController(vc)
            self.navigationItem.title = SideMenuConstants.resetPassword
        }
        self.sideMenuVC?.dismiss(animated: true)
    }
}

extension MyPageViewController: MissionHistoryButtonCollectionViewCellDelegate {
    func showMissionButtonDidTap(isOpened: Bool) {
        self.vm.isHistorySectionOpened = isOpened
    }
}
