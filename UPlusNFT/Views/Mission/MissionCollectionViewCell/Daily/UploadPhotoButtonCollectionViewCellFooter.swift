//
//  UploadPhotoButtonCollectionViewCellFooter.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/31.
//

import UIKit
import Combine

final class UploadPhotoButtonCollectionViewCellFooter: UICollectionViewCell {
    
    // MARK: - Combine
    private var bindings = Set<AnyCancellable>()

    // MARK: - UI Elements
    private let exampleImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "photo-example")
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private let infoTitle: UILabel = {
       let label = UILabel()
        label.text = MissionConstants.info
        label.textColor = .systemGray
        label.font = .systemFont(ofSize: UPlusFont.body1, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let infoDetailTitle: UILabel = {
       let label = UILabel()
        label.text = MissionConstants.infoDetail
        label.numberOfLines = 0
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.backgroundColor = .systemGray5
        self.setUI()
        self.setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Bind
extension UploadPhotoButtonCollectionViewCellFooter {
    
    func bind(with vm: RoutineMissionDetailViewViewModel) {
        
        self.bindings.forEach { $0.cancel() }
        self.bindings.removeAll()
        
        func bindViewToViewModel() {
 
        }
        
        func bindViewModelToView() {
            vm.$isFinishedRoutines
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    guard let `self` = self,
                    let isFinished = $0
                    else { return }
                    
                    if isFinished {
                      // 15일 미션을 모두 완료한 경우
                    }
                }
                .store(in: &bindings)
        }
        
        bindViewToViewModel()
        bindViewModelToView()
    }
    
}

// MARK: - Set UI & Layout
extension UploadPhotoButtonCollectionViewCellFooter {
    private func setUI() {
        self.contentView.addSubviews(self.exampleImage,
                                     self.infoTitle,
                                     self.infoDetailTitle)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.exampleImage.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 1),
            self.exampleImage.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.exampleImage.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.exampleImage.heightAnchor.constraint(equalToConstant: self.contentView.frame.height / 1.4),
            
            self.infoTitle.topAnchor.constraint(equalToSystemSpacingBelow: self.exampleImage.bottomAnchor, multiplier: 2),
            self.infoTitle.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.infoTitle.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            
            self.infoDetailTitle.topAnchor.constraint(equalToSystemSpacingBelow: self.infoTitle.bottomAnchor, multiplier: 1),
            self.infoDetailTitle.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.infoDetailTitle.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.infoDetailTitle.bottomAnchor, multiplier: 2)
        ])
    }
}
