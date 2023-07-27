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
    
    // MARK: - UI Elements
    private var collectionView: UICollectionView?
    
    //MARK: - Init
    init(vm: MyPageViewViewModel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)        
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

}

//MARK: - Set UI & Layout
extension MyPageViewController {
    
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
        
        // 1. Register section header
        collectionView.register(MyNftsCollectionViewHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: MyNftsCollectionViewHeader.identifier)

        // 2. Register cell
        collectionView.register(
            UICollectionViewCell.self,
            forCellWithReuseIdentifier: UICollectionViewCell.identifier
        )

        collectionView.register(
            MyPageProfileCollectionViewCell.self,
            forCellWithReuseIdentifier: MyPageProfileCollectionViewCell.identifier
        )
        
        collectionView.register(
            MyNftsCollectionViewCell.self,
            forCellWithReuseIdentifier: MyNftsCollectionViewCell.identifier
        )

        // 3. Register section footer
        collectionView.register(MyNftsCollectionViewFooter.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                withReuseIdentifier: MyNftsCollectionViewFooter.identifier)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }
    
    private func createSection(for section: Int) -> NSCollectionLayoutSection {
        
        switch section {
        case 0:
            return self.createProfileSectionLayout()
        default:
            return self.createOwnedNftsSectionLayout()
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
                heightDimension: .estimated(600)
            ),
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
       
        return section
    }
    
    private func createOwnedNftsSectionLayout() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
        )

        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.7),
                heightDimension: .fractionalHeight(0.4)
            ),
            subitems: [item]
        )
        
        let spacing = NSCollectionLayoutSpacing.fixed(10)
        group.edgeSpacing = NSCollectionLayoutEdgeSpacing(leading: spacing, top: nil, trailing: nil, bottom: nil)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        
        // Header
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(0.1)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        
        // Footer
        let footerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.8),
            heightDimension: .fractionalHeight(0.1)
        )
        
        let footer = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: footerSize,
            elementKind: UICollectionView.elementKindSectionFooter,
            alignment: .bottom
        )
        
        section.boundarySupplementaryItems = [header, footer]
        return section
    }
    
    private func createObtainedRewardsSectionLayout() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
        )
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(0.2)
            ),
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)

        return section
    }
}

extension MyPageViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.vm.sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        default:
            guard let userNfts = self.vm.user.userNfts,
                  !userNfts.isEmpty
            else {
                return 1
            }
            
            return userNfts.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch indexPath.section {
        case 0:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyPageProfileCollectionViewCell.identifier, for: indexPath) as? MyPageProfileCollectionViewCell else {
                fatalError()
            }
            
            cell.configure(with: self.vm)
            
            return cell
        default:
            guard let userNfts = self.vm.user.userNfts,
                  !userNfts.isEmpty else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UICollectionViewCell.identifier, for: indexPath)
                cell.contentView.backgroundColor = .systemOrange
                return cell
            }
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyNftsCollectionViewCell.identifier, for: indexPath) as? MyNftsCollectionViewCell else {
                fatalError()
            }
            cell.contentView.layer.cornerRadius = 5
            cell.configure(with: self.vm, at: indexPath.item)
            return cell
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch indexPath.section {
        case 1:
            switch kind {
            case UICollectionView.elementKindSectionHeader:
                guard let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: MyNftsCollectionViewHeader.identifier,
                    for: indexPath
                ) as? MyNftsCollectionViewHeader else {
                    return UICollectionReusableView()
                }
                header.configure(with: self.vm)
                
                return header
            case UICollectionView.elementKindSectionFooter:
                guard let footer = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: MyNftsCollectionViewFooter.identifier,
                    for: indexPath
                ) as? MyNftsCollectionViewFooter else {
                    return UICollectionReusableView()
                }
                
                footer.delegate = self
                footer.configure(with: self.vm)
                return footer
            default:
                return UICollectionReusableView()
            }
        default:
            return UICollectionReusableView()
        }
    }
    
}

extension MyPageViewController: MyNftsCollectionViewFooterDelegate {
    func rewardsButtomDidTap() {
        let vm = RewardsViewViewModel()
        let vc = RewardsViewController(vm: vm)
        self.show(vc, sender: self)
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
