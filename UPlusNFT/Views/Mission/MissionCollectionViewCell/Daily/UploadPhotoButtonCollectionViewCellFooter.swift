//
//  UploadPhotoButtonCollectionViewCellFooter.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/31.
//

import UIKit
import Combine

protocol UploadPhotoButtonCollectionViewCellFooterDelegate: AnyObject {
    func confirmDidTap()
}

final class UploadPhotoButtonCollectionViewCellFooter: UICollectionViewCell {
    
    // MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    // MARK: - Delegate
    weak var delegate: UploadPhotoButtonCollectionViewCellFooterDelegate?
    
    // MARK: - UI Elements
    private let exampleImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "photo-example")
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private let reuploadButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemGray2
        button.setTitle("재업로드", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let confirmButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .black
        button.setTitle("확인", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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
    
    func bind(with vm: DailyRoutineMissionDetailViewViewModel) {
        
        self.bindings.forEach { $0.cancel() }
        self.bindings.removeAll()
        
        func bindViewToViewModel() {
            self.confirmButton.tapPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    guard let `self` = self else { return }
                    self.delegate?.confirmDidTap()
                }
                .store(in: &bindings)
        }
        
        func bindViewModelToView() {
            vm.$isFinishedRoutines
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    guard let `self` = self else { return }
                    if $0 {
                        self.confirmButton.setTitle("루틴 완성!", for: .normal)
                        self.confirmButton.backgroundColor = .systemGray
                        self.isUserInteractionEnabled = false
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
                                     self.reuploadButton,
                                     self.confirmButton)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.exampleImage.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 1),
            self.exampleImage.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.exampleImage.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.exampleImage.heightAnchor.constraint(equalToConstant: self.contentView.frame.height / 1.4),
            
            self.reuploadButton.topAnchor.constraint(equalToSystemSpacingBelow: self.exampleImage.bottomAnchor, multiplier: 2),
            self.reuploadButton.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 2),
            self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.reuploadButton.bottomAnchor, multiplier: 2),
            self.reuploadButton.widthAnchor.constraint(equalToConstant: self.contentView.frame.width / 3),
            self.confirmButton.topAnchor.constraint(equalTo: self.reuploadButton.topAnchor),
            self.confirmButton.bottomAnchor.constraint(equalTo: self.reuploadButton.bottomAnchor),
            self.confirmButton.leadingAnchor.constraint(equalToSystemSpacingAfter: self.reuploadButton.trailingAnchor, multiplier: 2),
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.confirmButton.trailingAnchor, multiplier: 2)
        ])
        
        self.reuploadButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }
}
