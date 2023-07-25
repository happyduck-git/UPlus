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
    private var sideMenuVC: SideMenuViewController?
    // MARK: - Side Menu Controller Manager
    private lazy var slideInTransitioningDelegate = SideMenuPresentationManager()
    
    // MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    // MARK: - UI Elements
    private var collectionView: UICollectionView?
    
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
        collectionView.register(MyPageCollectionViewHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: MyPageCollectionViewHeader.identifier)
        
        // 2. Register cell
        collectionView.register(
            UICollectionViewCell.self,
            forCellWithReuseIdentifier: UICollectionViewCell.identifier
        )

        collectionView.register(
            MyNftsCollectionViewCell.self,
            forCellWithReuseIdentifier: MyNftsCollectionViewCell.identifier
        )

        // 3. Register section footer
        collectionView.register(MyPageCollectionViewFooter.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                withReuseIdentifier: MyPageCollectionViewFooter.identifier)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }
    
    private func createSection(for section: Int) -> NSCollectionLayoutSection {
        /*
        switch section {
        case 0:
            return self.createMyPageProfileSectionLayout()
        default:
            return self.createObtainedRewardsSectionLayout()
        }
         */
        return self.createMyPageProfileSectionLayout()
    }
    
    private func createMyPageProfileSectionLayout() -> NSCollectionLayoutSection {
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
            heightDimension: .estimated(600)
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
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch indexPath.section {
        default:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyNftsCollectionViewCell.identifier, for: indexPath) as? MyNftsCollectionViewCell else {
                fatalError()
            }
            cell.contentView.layer.cornerRadius = 5
            
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: MyPageCollectionViewHeader.identifier,
                for: indexPath
            ) as? MyPageCollectionViewHeader else {
                return UICollectionReusableView()
            }
            
            return header
        case UICollectionView.elementKindSectionFooter:
            guard let footer = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: MyPageCollectionViewFooter.identifier,
                for: indexPath
            ) as? MyPageCollectionViewFooter else {
                return UICollectionReusableView()
            }
            
            footer.delegate = self
            
            return footer
        default:
            return UICollectionReusableView()
        }

    }
    
}

extension MyPageViewController: MyPageCollectionViewFooterDelegate {
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
