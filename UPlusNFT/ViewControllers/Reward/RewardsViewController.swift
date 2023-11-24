//
//  RewardsViewController.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/24.
//

import UIKit
import Combine

final class RewardsViewController: UIViewController {

    // MARK: - Depedency
    private let vm: RewardsViewViewModel
    
    // MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    // MARK: - UI Elements
    private let rewardsOwnedLabel: UILabel = {
        let label = UILabel()
        label.textColor = UPlusColor.gray05
        label.font = .systemFont(ofSize: UPlusFont.h5, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 11.0
        layout.minimumLineSpacing = 24.0
        
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.register(RewardCollectionViewCell.self, forCellWithReuseIdentifier: RewardCollectionViewCell.identifier)
        collection.contentInset = UIEdgeInsets(top: 24, left: 20, bottom: 40, right: 20)
        
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()
    
    private let rewardInfoView: RewardInfoView = {
        let view = RewardInfoView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Init
    init(vm: RewardsViewViewModel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = RewardsConstants.ownedRewards
        
        self.view.backgroundColor = .white
        self.setUI()
        self.setLayout()
        self.setDelegate()
        self.configure()
    }

}

// MARK: - Set UI & Layout
extension RewardsViewController {
    private func setUI() {
        self.view.addSubviews(self.rewardsOwnedLabel,
                              self.collectionView,
                              self.rewardInfoView)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.rewardsOwnedLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.view.safeAreaLayoutGuide.topAnchor, multiplier: 2),
            self.rewardsOwnedLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.view.safeAreaLayoutGuide.leadingAnchor, multiplier: 2),
            self.view.trailingAnchor.constraint(equalToSystemSpacingAfter: self.rewardsOwnedLabel.trailingAnchor, multiplier: 2),
            
            self.collectionView.topAnchor.constraint(equalToSystemSpacingBelow: self.rewardsOwnedLabel.bottomAnchor, multiplier: 3),
            self.collectionView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            self.collectionView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            self.collectionView.bottomAnchor.constraint(equalTo: self.rewardInfoView.topAnchor),

            self.rewardInfoView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            self.rewardInfoView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            self.rewardInfoView.heightAnchor.constraint(equalToConstant: self.view.frame.height / 4),
            self.rewardInfoView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setDelegate() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
}

// MARK: - Bind with View Model
extension RewardsViewController {
    private func configure() {
        self.rewardsOwnedLabel.text = String(format: WalletConstants.totalNfts, self.vm.rewards.count)
        self.collectionView.reloadData()
//        self.vm.$rewards
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] in
//                guard let `self` = self else { return }
//
//                self.rewardsOwnedLabel.text = String(format: WalletConstants.totalNfts, $0.count)
//                self.collectionView.reloadData()
//
//            }
//            .store(in: &bindings)
    }
}

extension RewardsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.vm.rewards.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RewardCollectionViewCell.identifier, for: indexPath) as? RewardCollectionViewCell else {
            return UICollectionViewCell()
        }

        cell.configure(with: self.vm.rewards[indexPath.item])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.rewardInfoView.configure(with: self.vm.rewards[indexPath.item])
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width / 2 - 30, height: self.view.frame.height / 6 - 24)
    }
}
