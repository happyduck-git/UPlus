//
//  MissionMainViewController.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/17.
//

import UIKit
import FirebaseAuth
import SwiftUI

class MissionMainViewController: UIViewController {

    // MARK: - Side Menu Controller Manager
    private lazy var slideInTransitioningDelegate = SideMenuPresentationManager()
    
    // MARK: - UI Elements
    private var collectionView: UICollectionView?
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationItem()
        view.backgroundColor = .white
        
        setUI()
        setLayout()
        setDelegate()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let vc = WelcomeBottomSheetViewController()
        vc.modalPresentationStyle = .overCurrentContext

        self.present(vc, animated: false)
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
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }
    
    private func createSection(for section: Int) -> NSCollectionLayoutSection {
        switch section {
        case 0:
            return self.createProfileSectionLayout()
        case 1:
            return self.createTodayMissionSectionLayout()
        default:
            return self.createDailyQuizSectionLayout()
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

extension MissionMainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    private func setDelegate() {
        self.collectionView?.dataSource = self
        self.collectionView?.delegate = self
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

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
                                              quizTitle: "OX 퀴즈",
                                              quizDesc: "1분이면 끝! 데일리 퀴즈 풀기",
                                              quizPoint: 1
        )
     
        switch indexPath.section {
        case 0:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MissionProfileCollectionViewCell.identifier, for: indexPath) as? MissionProfileCollectionViewCell else { fatalError() }
            
            cell.configure(with: tempVM)
            return cell
        case 1:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TodayMissionCollectionViewCell.identifier, for: indexPath) as? TodayMissionCollectionViewCell else { fatalError() }
            
            cell.configure(with: tempVM)
            return cell
        default:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DailyQuizMissionCollectionViewCell.identifier, for: indexPath) as? DailyQuizMissionCollectionViewCell else { fatalError() }
            
            cell.configure(with: tempVM)
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
        
        return header
    }

}

// MARK: - Preview
//struct PreView: PreviewProvider {
//    static var previews: some View {
//        MissionMainViewController().toPreview()
//    }
//}


