//
//  RoutineUploadPhotoView.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/08/18.
//

import UIKit
import Combine

protocol RoutineUploadPhotoViewDelegate: AnyObject {
    func uploadButtonDidTap()
}

final class RoutineUploadPhotoView: UIView {
    
    // MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    // MARK: - Delegate
    weak var delegate: RoutineUploadPhotoViewDelegate?
    
    //MARK: - UI Elements
    private let rewardLabel: UILabel = {
        let label = UILabel()
        label.text = MissionConstants.rewardPoint
        label.textColor = .black
        label.textAlignment = .center
        label.font = .systemFont(ofSize: UPlusFont.h1, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let uploadPhotoButton: UIButton = {
        let button = UIButton()
        button.setTitle(MissionConstants.upload, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.alignVerticalCenter(padding: 10.0)
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.text = "조건 멘트"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = UPlusColor.mint04
        label.font = .systemFont(ofSize: UPlusFont.caption1, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let photoView: UIImageView = {
        let imageView = UIImageView()
        imageView.isHidden = true
        imageView.backgroundColor = .darkGray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UPlusColor.gray03
        self.setUI()
        self.setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.uploadPhotoButton.layer.cornerRadius = self.uploadPhotoButton.frame.height / 2
    }
    
}

extension RoutineUploadPhotoView {
    private func setUI() {
        self.addSubviews(self.rewardLabel,
                         self.uploadPhotoButton,
                         self.infoLabel,
                         self.photoView)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.rewardLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.topAnchor, multiplier: 3),
            self.rewardLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.leadingAnchor, multiplier: 4),
            self.trailingAnchor.constraint(equalToSystemSpacingAfter: self.rewardLabel.trailingAnchor, multiplier: 4),
            
            self.uploadPhotoButton.topAnchor.constraint(equalToSystemSpacingBelow: self.rewardLabel.bottomAnchor, multiplier: 2),
            self.uploadPhotoButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.uploadPhotoButton.widthAnchor.constraint(equalToConstant: 170),
            self.uploadPhotoButton.heightAnchor.constraint(equalToConstant: 40),
            
            self.infoLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.uploadPhotoButton.bottomAnchor, multiplier: 1),
            self.infoLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.leadingAnchor, multiplier: 3),
            self.trailingAnchor.constraint(equalToSystemSpacingAfter: self.infoLabel.trailingAnchor, multiplier: 3),
            self.bottomAnchor.constraint(equalToSystemSpacingBelow: self.infoLabel.bottomAnchor, multiplier: 5)
            
        ])
        self.infoLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
    }
    
    private func photoSelected() {
        self.uploadPhotoButton.isHidden = true
        self.photoView.isHidden = false
        self.infoLabel.isHidden = false
        
        NSLayoutConstraint.activate([
            self.photoView.topAnchor.constraint(equalToSystemSpacingBelow: self.topAnchor, multiplier: 2),
            self.photoView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.leadingAnchor, multiplier: 2),
            self.trailingAnchor.constraint(equalToSystemSpacingAfter: self.photoView.trailingAnchor, multiplier: 2),
            self.photoView.heightAnchor.constraint(equalToConstant: self.frame.height / 1.5),
//                    self.photoView.heightAnchor.constraint(equalToConstant: 200),
            
            self.infoLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.photoView.bottomAnchor, multiplier: 2),
            self.infoLabel.leadingAnchor.constraint(equalTo: self.photoView.leadingAnchor),
            self.infoLabel.trailingAnchor.constraint(equalTo: self.photoView.trailingAnchor),
            self.bottomAnchor.constraint(equalToSystemSpacingBelow: self.infoLabel.bottomAnchor, multiplier: 2)
        ])
    }

}

extension RoutineUploadPhotoView {
    func bind(with vm: RoutineMissionDetailViewViewModel) {
        
        self.bindings.forEach { $0.cancel() }
        self.bindings.removeAll()
        
        self.uploadPhotoButton.tapPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let `self` = self else { return }
                self.delegate?.uploadButtonDidTap()
            }
            .store(in: &bindings)

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

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct RoutineUploadPhotoPreView: PreviewProvider{
    static var previews: some View {
        UIViewPreview {
            let view = RoutineUploadPhotoView(frame: .zero)
            return view
        }.previewLayout(.sizeThatFits)
    }
}
#endif
