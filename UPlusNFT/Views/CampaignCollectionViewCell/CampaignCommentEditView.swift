//
//  CampaignCommentEditView.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/10.
//

import UIKit

final class CampaignCommentEditView: UIView {
    
    // MARK: - UI Elements
    private let editTextField: UITextField = {
        let txtField = UITextField()
        txtField.isHidden = true
        txtField.borderStyle = .roundedRect
        txtField.translatesAutoresizingMaskIntoConstraints = false
        return txtField
    }()
    
    private let editImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .systemBlue
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let cameraButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: SFSymbol.camera), for: .normal)
        button.tintColor = .systemGray
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton()
        button.isHidden = true
        button.setTitle("취소", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGray
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let confirmButton: UIButton = {
        let button = UIButton()
        button.isHidden = true
        button.setTitle("수정", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGray
        button.isUserInteractionEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUI()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension CampaignCommentEditView {
    private func setUI() {
        self.addSubviews(editTextField,
                         editImage,
                         cameraButton,
                         cancelButton,
                         confirmButton)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            editTextField.topAnchor.constraint(equalTo: self.topAnchor),
            editTextField.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            editTextField.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            editImage.topAnchor.constraint(equalToSystemSpacingBelow: editTextField.bottomAnchor, multiplier: 1),
            editImage.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            editImage.heightAnchor.constraint(equalToConstant: self.frame.height / 2),
            editImage.widthAnchor.constraint(equalTo: editImage.heightAnchor),
            
            confirmButton.topAnchor.constraint(equalToSystemSpacingBelow: editTextField.bottomAnchor, multiplier: 1),
            confirmButton.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            cancelButton.topAnchor.constraint(equalTo: confirmButton.topAnchor),
            cancelButton.trailingAnchor.constraint(equalToSystemSpacingAfter: confirmButton.leadingAnchor, multiplier: 1),
            
            cameraButton.centerYAnchor.constraint(equalTo: confirmButton.centerYAnchor),
            cameraButton.leadingAnchor.constraint(equalTo: self.leadingAnchor),
        ])
    }
}

extension CampaignCommentEditView {
    func configure(with vm: CommentTableViewCellModel) {
        editTextField.text = vm.comment
        Task {
            guard let image = vm.imagePath,
                  let url = URL(string: image)
            else {
                self.editImage.isHidden = true
                return
            }

            do {
                let photo = try await URL.urlToImage(url)
                self.editImage.image = photo
            }
            catch {
                print("Error fetching comment image \(error)")
            }
            
        }
    }
}
