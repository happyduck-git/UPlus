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
    func editButtonDidTap()
    func submitButtonDidTap()
}

final class UploadPhotoButtonCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Dependency
    private var vm: RoutineMissionDetailViewViewModel?
    
    // MARK: - Delegate
    weak var delegate: UploadPhotoButtonCollectionViewCellDelegate?
    
    // MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    // MARK: - UI Elements

    private let uploadPhotoView: RoutineUploadPhotoView = {
        let view = RoutineUploadPhotoView()
        view.layer.borderColor = UPlusColor.gray04.cgColor
        view.layer.borderWidth = 1.0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let buttonStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 20.0
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let editButton: UIButton = {
        let button = UIButton()
        button.setTitle(MissionConstants.edit, for: .normal)
        button.backgroundColor = UPlusColor.gray09
        button.clipsToBounds = true
        button.layer.cornerRadius = 10.0
        return button
    }()
    
    private let submitButton: UIButton = {
        let button = UIButton()
        button.setTitle(MissionConstants.submit, for: .normal)
        button.backgroundColor = UPlusColor.gray09
        button.clipsToBounds = true
        button.layer.cornerRadius = 10.0
        return button
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.text = MissionConstants.photoEditWarning
        label.textColor = UPlusColor.mint04
        label.font = .systemFont(ofSize: UPlusFont.caption1, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.backgroundColor = .systemGray5
        self.setUI()
        self.setLayout()

        self.uploadPhotoView.delegate = self
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Bind with View Model
extension UploadPhotoButtonCollectionViewCell {
    
    func bind(with vm: RoutineMissionDetailViewViewModel) {
        
        self.bindings.forEach { $0.cancel() }
        self.bindings.removeAll()
        
        self.vm = vm
        self.uploadPhotoView.bind(with: vm)
        
        func bindViewToViewModel() {
            
            self.editButton.tapPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    guard let `self` = self else { return }
                    
                    self.delegate?.editButtonDidTap()
                }
                .store(in: &bindings)
            
            self.submitButton.tapPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    guard let `self` = self else { return }
                    
                    self.delegate?.submitButtonDidTap()
                }
                .store(in: &bindings)
            
        }
        
        func bindViewModelToView() {
            
        }
        
        bindViewToViewModel()
        bindViewModelToView()
    }
    
}

// MARK: - Set UI & Layout
extension UploadPhotoButtonCollectionViewCell {
    
    private func setUI() {
        self.contentView.addSubviews(self.uploadPhotoView,
                                     self.buttonStack,
                                     self.infoLabel)
        
        self.buttonStack.addArrangedSubviews(self.editButton,
                                             self.submitButton)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.uploadPhotoView.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 1),
            self.uploadPhotoView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 1),
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.uploadPhotoView.trailingAnchor, multiplier: 1),
            
            self.buttonStack.topAnchor.constraint(equalToSystemSpacingBelow: self.uploadPhotoView.bottomAnchor, multiplier: 3),
            self.buttonStack.leadingAnchor.constraint(equalTo: self.uploadPhotoView.leadingAnchor),
            self.buttonStack.trailingAnchor.constraint(equalTo: self.uploadPhotoView.trailingAnchor),
            
            self.infoLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.buttonStack.bottomAnchor, multiplier: 2),
            self.infoLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 2),
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.infoLabel.trailingAnchor, multiplier: 2),
            self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.infoLabel.bottomAnchor, multiplier: 2)
        ])
    }
    
}

extension UploadPhotoButtonCollectionViewCell: RoutineUploadPhotoViewDelegate {

    func uploadButtonDidTap() {
        self.delegate?.uploadButtonDidTap()
    }

}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct UploadPhotoButtonCellPreView: PreviewProvider{
    static var previews: some View {
        UIViewPreview {
            let view = UploadPhotoButtonCollectionViewCell(frame: .zero)
            return view
        }.previewLayout(.sizeThatFits)
    }
}
#endif
