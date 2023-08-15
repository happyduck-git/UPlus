//
//  MissionHistoryButtonCollectionViewCell.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/25.
//

import UIKit
import Combine

protocol MissionHistoryButtonCollectionViewCellDelegate: AnyObject {
    func showMissionButtonDidTap(isOpened: Bool)
}

final class MissionHistoryButtonCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Combine
    @Published var isOpened: Bool = false
    private var bindings = Set<AnyCancellable>()
    
    // MARK: - Delegate
    weak var delegate: MissionHistoryButtonCollectionViewCellDelegate?
    
    // MARK: - UI Elements
    private let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let button: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setUI()
        self.setLayout()
        self.bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MissionHistoryButtonCollectionViewCell {
    func bind() {
        
        self.button.tapPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.isOpened.toggle()
            }
            .store(in: &bindings)
        
        self.$isOpened
            .receive(on: RunLoop.current)
            .sink { [weak self] in
                guard let `self` = self else {
                    print("Self")
                    return }
                let text = $0 ? "이전 미션 참여기록 보기" : "이전 미션 참여기록 접기"
                let image = $0 ? ImageAsset.arrowHeadDown : ImageAsset.arrowHeadUp
                
                self.label.text = text
                self.button.setImage(UIImage(named: image), for: .normal)
                self.delegate?.showMissionButtonDidTap(isOpened: $0)
            }
            .store(in: &bindings)
    }
}

extension MissionHistoryButtonCollectionViewCell {
    private func setUI() {
        self.contentView.addSubviews(self.label,
                                     self.button)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.label.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.label.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            self.button.topAnchor.constraint(equalToSystemSpacingBelow: self.label.bottomAnchor, multiplier: 1),
            self.button.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            self.button.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
        ])
    }
}
