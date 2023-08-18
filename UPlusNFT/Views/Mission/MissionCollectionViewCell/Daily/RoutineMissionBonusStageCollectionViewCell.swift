//
//  DailyRoutineMissionBonusStageCollectionViewCell.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/16.
//

import UIKit
import Combine

final class RoutineMissionBonusStageCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Dependency
    private var vm: RoutineMissionDetailViewViewModel?
    
    // MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    // MARK: - UI Elements
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = MissionConstants.bonusStage
        label.textColor = UPlusColor.blue04
        label.font = .systemFont(ofSize: UPlusFont.h2, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let progressLabel: UILabel = {
        let label = UILabel()
        label.textColor = UPlusColor.gray04
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let stampCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.register(StampCollectionViewCell.self,
                            forCellWithReuseIdentifier: StampCollectionViewCell.identifier)
        collection.backgroundColor = .white
        collection.alwaysBounceVertical = true
        collection.isScrollEnabled = false
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.text = MissionConstants.pointInfo
        label.textColor = UPlusColor.mint04
        label.font = .systemFont(ofSize: UPlusFont.caption1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.backgroundColor = .white
        self.contentView.layer.borderColor = UPlusColor.mint03.cgColor
        self.contentView.layer.borderWidth = 1.0
        self.contentView.clipsToBounds = true
        self.contentView.layer.cornerRadius = 16
        
        self.setUI()
        self.setLayout()
        self.setDelegate()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension RoutineMissionBonusStageCollectionViewCell {
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
                self.progressLabel.text = String(format: MissionConstants.missionProgress, $0 - MissionConstants.routineMissionLimit)
            }
            .store(in: &self.bindings)
        
        vm.$isFinishedRoutines
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let `self` = self,
                let isFinished = $0
                else { return }
                if isFinished {
                    // TODO: bonus 미션 all 완료한 경우
                    
                }
            }
            .store(in: &bindings)
        
    }
}

extension RoutineMissionBonusStageCollectionViewCell {
    
    private func setUI() {
        self.contentView.addSubviews(self.titleLabel,
                                     self.progressLabel,
                                     self.stampCollectionView,
                                     self.infoLabel)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.titleLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 2),
            self.titleLabel.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            self.progressLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.titleLabel.bottomAnchor, multiplier: 2),
            self.progressLabel.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            
            self.stampCollectionView.topAnchor.constraint(equalToSystemSpacingBelow: self.progressLabel.bottomAnchor, multiplier: 2),
            self.stampCollectionView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 4),
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.stampCollectionView.trailingAnchor, multiplier: 4),
            
            self.infoLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.stampCollectionView.bottomAnchor, multiplier: 2),
            self.infoLabel.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.infoLabel.bottomAnchor, multiplier: 2)
        ])
        self.infoLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
    
    private func setDelegate() {
        self.stampCollectionView.delegate = self
        self.stampCollectionView.dataSource = self
    }
}

extension RoutineMissionBonusStageCollectionViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return MissionConstants.bonusMissionLimit
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StampCollectionViewCell.identifier, for: indexPath) as? StampCollectionViewCell,
              let cellVM = self.vm
        else {
            return UICollectionViewCell()
        }
        
        cell.resetCell()
        
        if indexPath.item + MissionConstants.routineMissionLimit >= cellVM.athleteMissions.count {
            cell.showGiftMark(at: indexPath.item)
            return cell
        } else {
            cell.showCheckMark(at: indexPath.item)
            return cell
        }
    }
}
