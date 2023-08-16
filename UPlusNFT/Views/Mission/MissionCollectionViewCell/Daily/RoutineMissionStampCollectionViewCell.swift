//
//  RoutineMissionStampCollectionViewCell.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/28.
//

import UIKit
import Combine

final class RoutineMissionStampCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Dependency
    private var vm: RoutineMissionDetailViewViewModel?
    
    // MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    // MARK: - UI Elements
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "참여 스탬프"
        label.font = .systemFont(ofSize: UPlusFont.h2, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let progressLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: UPlusFont.body1, weight: .medium)
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
extension RoutineMissionStampCollectionViewCell {
    
    func bind(with vm: RoutineMissionDetailViewViewModel) {
        
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
        
        vm.$successedMissionsCount
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let `self` = self else { return }
                self.progressLabel.text = String(format: MissionConstants.missionProgress, $0)
            }
            .store(in: &self.bindings)
        
        vm.$isFinishedRoutines
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let `self` = self,
                let isFinished = $0
                else { return }
                if isFinished {
                    // TODO: 미션 15개 완료한 경우
                    
                }
            }
            .store(in: &bindings)
        
    }
    
}

// MARK: - Set UI & Layout
extension RoutineMissionStampCollectionViewCell {
    
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

extension RoutineMissionStampCollectionViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StampCollectionViewCell.identifier, for: indexPath) as? StampCollectionViewCell,
              let cellVM = self.vm
        else {
            return UICollectionViewCell()
        }
        
        cell.resetCell()
        
        if indexPath.item >= cellVM.athleteMissions.count {
            cell.contentView.backgroundColor = .systemGray
            return cell
        } else {
            let point = cellVM.athleteMissions[indexPath.item].missionRewardPoint
            
            cell.configure(with: point)
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = self.stampCollectionView.frame.height / 3 - 8
        
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
}
