//
//  DailyRoutineMissionStampCollectionViewCell.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/28.
//

import UIKit
import Combine

final class DailyRoutineMissionStampCollectionViewCell: UICollectionViewCell {
    
    private let tempNumberOfStamps: Int = 15
    
    // MARK: - Dependency
    private var vm: DailyRoutineMissionDetailViewViewModel?
    
    // MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    // MARK: - UI Elements
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "참여 스탬프"
        label.font = .systemFont(ofSize: UPlusFont.head5, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let progressLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "6 / 12"
        label.font = .systemFont(ofSize: UPlusFont.subTitle1, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let stampCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.register(StampCollectionViewCell.self,
                            forCellWithReuseIdentifier: StampCollectionViewCell.identifier)
        collection.backgroundColor = .darkGray
        collection.alwaysBounceVertical = true
        collection.isScrollEnabled = false
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.backgroundColor = .darkGray
        self.contentView.clipsToBounds = true
        
        self.setUI()
        self.setLayout()
        self.setDelegate()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Configure & Bind with View Model
extension DailyRoutineMissionStampCollectionViewCell {
    
    func bind(with vm: DailyRoutineMissionDetailViewViewModel) {
        
        self.bindings.forEach { $0.cancel() }
        self.bindings.removeAll()
        
        self.vm = vm
        
        vm.$athleteMissions
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let `self` = self else { return }
                self.stampCollectionView.reloadData()
            }
            .store(in: &self.bindings)
    }
    
}

// MARK: - Set UI & Layout
extension DailyRoutineMissionStampCollectionViewCell {
    
    private func setDelegate() {
        self.stampCollectionView.delegate = self
        self.stampCollectionView.dataSource = self
    }
    
    private func setUI() {
        self.contentView.addSubviews(self.titleLabel,
                                     self.progressLabel,
                                     self.stampCollectionView)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.titleLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 2),
            self.titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 3),
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.progressLabel.trailingAnchor, multiplier: 2),
            self.progressLabel.bottomAnchor.constraint(equalTo: self.titleLabel.bottomAnchor),
            
            self.stampCollectionView.topAnchor.constraint(equalToSystemSpacingBelow: self.titleLabel.bottomAnchor, multiplier: 2),
            self.stampCollectionView.leadingAnchor.constraint(equalTo: self.titleLabel.leadingAnchor),
            self.stampCollectionView.trailingAnchor.constraint(equalTo: self.progressLabel.trailingAnchor),
            self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.stampCollectionView.bottomAnchor, multiplier: 2)
        ])
        
        self.titleLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
    
}

extension DailyRoutineMissionStampCollectionViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let cellVM = self.vm else { return 0 }
        return cellVM.athleteMissions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StampCollectionViewCell.identifier, for: indexPath) as? StampCollectionViewCell,
              let cellVM = self.vm
        else {
            fatalError()
        }

        let point = cellVM.athleteMissions[indexPath.item].missionRewardPoint
        
        cell.configure(with: point)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = self.stampCollectionView.frame.height / 3 - 10
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
}
