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
    private let completeLabel: UILabel = {
        let label = UILabel()
        label.textColor = UPlusColor.mint04
        label.textAlignment = .center
        label.font = .systemFont(ofSize: UPlusFont.body1, weight: .regular)
        label.text = MissionConstants.untilCompletion
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let progressLabel: UILabel = {
        let label = UILabel()
        label.textColor = UPlusColor.blue04
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
        collection.backgroundColor = .white
        collection.alwaysBounceVertical = true
        collection.isScrollEnabled = false
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.backgroundColor = .white
        self.contentView.clipsToBounds = true
        self.contentView.layer.cornerRadius = 16.0
        self.contentView.layer.borderColor = UPlusColor.mint03.cgColor
        self.contentView.layer.borderWidth = 4.0
        
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
        
        vm.$goodWorkerMissions
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
                self.progressLabel.attributedText = setLabelAttributes(current: $0, max: MissionConstants.routineMissionLimit)
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

//MARK: - Private
extension RoutineMissionStampCollectionViewCell {

    private func setLabelAttributes(current: Int, max: Int) -> NSAttributedString {
        
        let currentText = String(format: MissionConstants.currentProgress, current)
        let maxText = String(format: MissionConstants.maxProgress, max)
        
        let bold: UIFont = .systemFont(ofSize: UPlusFont.h2, weight: .bold)
        let regular: UIFont = .systemFont(ofSize: UPlusFont.body2, weight: .regular)
        
        let attributedString = NSMutableAttributedString(string: currentText, attributes: [
            .font: bold,
            .foregroundColor: UPlusColor.blue05
        ])
        
        let regularString = NSAttributedString(string: maxText, attributes: [
            .font: regular,
            .foregroundColor: UPlusColor.gray04
        ])
        
        attributedString.append(regularString)
        return attributedString
    }
}

// MARK: - Set UI & Layout
extension RoutineMissionStampCollectionViewCell {
    
    private func setDelegate() {
        self.stampCollectionView.delegate = self
        self.stampCollectionView.dataSource = self
    }
    
    private func setUI() {
        self.contentView.addSubviews(self.completeLabel,
                                     self.progressLabel,
                                     self.stampCollectionView)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.completeLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 2),
            self.completeLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 2),
            
            self.progressLabel.topAnchor.constraint(equalTo: self.completeLabel.topAnchor),
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.progressLabel.trailingAnchor, multiplier: 2),
        
            self.stampCollectionView.topAnchor.constraint(equalToSystemSpacingBelow: self.progressLabel.bottomAnchor, multiplier: 2),
            self.stampCollectionView.leadingAnchor.constraint(equalTo: self.completeLabel.leadingAnchor),
            self.stampCollectionView.trailingAnchor.constraint(equalTo: self.progressLabel.trailingAnchor),
            self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.stampCollectionView.bottomAnchor, multiplier: 2)
        ])
        
        self.progressLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
    
}

extension RoutineMissionStampCollectionViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return MissionConstants.routineMissionLimit
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StampCollectionViewCell.identifier, for: indexPath) as? StampCollectionViewCell,
              let cellVM = self.vm
        else {
            return UICollectionViewCell()
        }
        
        cell.resetCell()
        
        if indexPath.item >= cellVM.goodWorkerMissions.count {
            cell.markNotYetParticipated(at: indexPath.item)
            return cell
        } else {
            cell.checkAsParticipated(at: indexPath.item)
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let cellHeight = self.stampCollectionView.frame.height / 3 - 20
        let cellWidth = (self.stampCollectionView.frame.width - 80) / 5
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
}
