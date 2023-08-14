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
        label.backgroundColor = .systemGray3
        label.numberOfLines = 0
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.register(<#T##nib: UINib?##UINib?#>, forCellWithReuseIdentifier: <#T##String#>)
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
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
        self.bind()
    }

}

// MARK: - Set UI & Layout
extension RewardsViewController {
    private func setUI() {
        self.view.addSubview(self.rewardsOwnedLabel)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.rewardsOwnedLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.view.safeAreaLayoutGuide.topAnchor, multiplier: 2),
            self.rewardsOwnedLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.view.safeAreaLayoutGuide.leadingAnchor, multiplier: 2),
            self.view.trailingAnchor.constraint(equalToSystemSpacingAfter: self.rewardsOwnedLabel.trailingAnchor, multiplier: 2)
        ])
    }
}

// MARK: - Bind with View Model
extension RewardsViewController {
    private func bind() {
        self.vm.$rewards
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let `self` = self else { return }
                print("Rewards: \($0)")
            }
            .store(in: &bindings)
    }
}
