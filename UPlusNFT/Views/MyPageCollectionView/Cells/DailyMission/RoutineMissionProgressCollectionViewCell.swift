//
//  RoutineMissionProgressCollectionViewCell.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/02.
//

import UIKit
import Combine

final class RoutineMissionProgressCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    // MARK: - UI Elements
    private let title: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.font = .systemFont(ofSize: UPlusFont.head6, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let numberOfParticipation: UILabel = {
        let label = UILabel()
        label.textColor = UPlusColor.green
        label.textAlignment = .center
        label.font = .systemFont(ofSize: UPlusFont.subTitle3, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.backgroundColor = .white
        self.setUI()
        self.setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Bind with View Model
extension RoutineMissionProgressCollectionViewCell {
    
    func bind(with vm: MyPageViewViewModel) {
        
        self.bindings.forEach { $0.cancel() }
        self.bindings.removeAll()
        
        vm.$savedMissionType
            .receive(on: DispatchQueue.main)
            .sink {
                self.title.text = $0?.displayName ?? "걷기 루틴 미션"
            }
            .store(in: &bindings)
        
        vm.$routineParticipationCount
            .receive(on: DispatchQueue.main)
            .sink {
                self.numberOfParticipation.text = String(describing: $0) + "회"
            }
            .store(in: &bindings)
        
    }
}

// MARK: - Set UI & Layout
extension RoutineMissionProgressCollectionViewCell {
    private func setUI() {
        self.contentView.addSubviews(self.title,
                         self.numberOfParticipation)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.title.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 1),
            self.title.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 1),
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.title.trailingAnchor, multiplier: 1),
            
            self.numberOfParticipation.topAnchor.constraint(equalToSystemSpacingBelow: self.title.bottomAnchor, multiplier: 1),
            self.numberOfParticipation.leadingAnchor.constraint(equalTo: self.title.leadingAnchor),
            self.numberOfParticipation.trailingAnchor.constraint(equalTo: self.title.trailingAnchor),
            self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.numberOfParticipation.bottomAnchor, multiplier: 1)
        ])
        
        self.numberOfParticipation.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
}
