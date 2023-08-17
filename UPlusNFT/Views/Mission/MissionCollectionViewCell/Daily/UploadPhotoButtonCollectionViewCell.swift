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
    
    private let submitButton: UIButton = {
        let button = UIButton()
        button.setTitle(MissionConstants.submit, for: .normal)
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

extension UploadPhotoButtonCollectionViewCell {


    
}

extension UploadPhotoButtonCollectionViewCell {
    private func setUI() {
        self.contentView.addSubviews(self.uploadPhotoView,
                                     self.submitButton)
        
       
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.uploadPhotoView.topAnchor.constraint(equalToSystemSpacingBelow: self.contentView.topAnchor, multiplier: 1),
            self.uploadPhotoView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.contentView.leadingAnchor, multiplier: 1),
            self.contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.uploadPhotoView.trailingAnchor, multiplier: 1),
            
            self.submitButton.topAnchor.constraint(equalToSystemSpacingBelow: self.uploadPhotoView.bottomAnchor, multiplier: 3),
            self.submitButton.leadingAnchor.constraint(equalTo: self.uploadPhotoView.leadingAnchor),
            self.submitButton.trailingAnchor.constraint(equalTo: self.uploadPhotoView.trailingAnchor),
            self.contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.submitButton.bottomAnchor, multiplier: 2)
        ])
        
        self.submitButton.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
}

extension UploadPhotoButtonCollectionViewCell {


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
