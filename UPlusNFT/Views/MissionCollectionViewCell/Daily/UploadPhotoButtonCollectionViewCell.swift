//
//  UploadPhotoButtonCollectionViewCell.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/31.
//

import UIKit
import Combine

protocol UploadPhotoButtonCollectionViewCellDelegate: AnyObject {
    func uploadButtonDidTap()
}

final class UploadPhotoButtonCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Dependency
    private var vm: DailyRoutineMissionDetailViewViewModel?
    
    // MARK: - Delegate
    weak var delegate: UploadPhotoButtonCollectionViewCellDelegate?
    
    // MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    // MARK: - UI Elements
    private let uploadPhotoButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: ImageAsset.share), for: .normal)
        button.setTitle("날짜, 시간, 걸음수가 포함된 사진", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.alignVerticalCenter(padding: 30.0)
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let photoView: UIImageView = {
        let imageView = UIImageView()
        imageView.isHidden = true
        imageView.backgroundColor = .darkGray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.text = "꼭 확인하세요!\n날짜, 시간, 걸음수가 포함된 사진"
        label.numberOfLines = 2
        label.textAlignment = .center
        label.textColor = .black
        label.backgroundColor = .white
        label.isHidden = true
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

extension UploadPhotoButtonCollectionViewCell {

    func configure(with vm: DailyRoutineMissionDetailViewViewModel) {
        self.vm = vm
        self.bind()
    }
    
    private func bind() {
        
        self.bindings.forEach { $0.cancel() }
        self.bindings.removeAll()
        
        self.uploadPhotoButton.tapPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let `self` = self else { return }
                self.delegate?.uploadButtonDidTap()
            }
            .store(in: &bindings)
        
        guard let vm = vm else { return }
        vm.$selectedImage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in
                guard let `self` = self else { return }
                if image != nil {
                    UIView.animate(withDuration: 0.1) {
                        self.photoView.image = image
                        self.photoSelected()
                    }
                }
                
            }
            .store(in: &bindings)
    }
    
}

extension UploadPhotoButtonCollectionViewCell {
    private func setUI() {
        self.contentView.addSubviews(uploadPhotoButton,
                                     photoView,
                                     infoLabel)
        self.uploadPhotoButton.layer.cornerRadius = 10
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.uploadPhotoButton.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 2),
            self.uploadPhotoButton.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 2),
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.uploadPhotoButton.trailingAnchor, multiplier: 2),
            self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.uploadPhotoButton.bottomAnchor, multiplier: 2)
        ])
    }
}

extension UploadPhotoButtonCollectionViewCell {

    private func photoSelected() {
        self.uploadPhotoButton.isHidden = true
        self.photoView.isHidden = false
        self.infoLabel.isHidden = false
        
        NSLayoutConstraint.activate([
            self.photoView.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 2),
            self.photoView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 2),
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.photoView.trailingAnchor, multiplier: 2),
            self.photoView.heightAnchor.constraint(equalToConstant: self.contentView.frame.height / 1.5),
//                    self.photoView.heightAnchor.constraint(equalToConstant: 200),
            
            self.infoLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.photoView.bottomAnchor, multiplier: 2),
            self.infoLabel.leadingAnchor.constraint(equalTo: self.photoView.leadingAnchor),
            self.infoLabel.trailingAnchor.constraint(equalTo: self.photoView.trailingAnchor),
            self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.infoLabel.bottomAnchor, multiplier: 2)
        ])
    }
}
