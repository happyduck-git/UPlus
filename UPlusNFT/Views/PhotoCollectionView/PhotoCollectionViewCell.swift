//
//  PhotoCollectionViewCell.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/06/30.
//

import UIKit

final class PhotoCollectionViewCell: UICollectionViewCell {
    
    enum `Type` {
        case camera
        case photo
    }
    
    private var cellType: Type? {
        didSet {
            switch cellType {
            case .some(let cellType):
                switch cellType {
                case .camera:
                    deleteButton.isHidden = true
                    return
                default:
                    deleteButton.isHidden = false
                    return
                }
            case .none:
                return
            }
        }
    }
    
    var buttonTapAction: (() -> Void)?
    
    //MARK: - UI Elements
    private let photo: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .systemGray4
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 5
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
 
    private lazy var deleteButton: UIButton = {
       let button = UIButton()
        button.setImage(UIImage(systemName: "x.circle.fill"), for: .normal)
        button.tintColor = .systemGray
        button.addTarget(self, action: #selector(deleteButtonDidTap), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Set UI & Layout
    private func setUI() {
        contentView.addSubview(photo)
        contentView.addSubview(deleteButton)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            photo.topAnchor.constraint(equalTo: contentView.topAnchor),
            photo.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            photo.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            photo.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            photo.topAnchor.constraint(equalToSystemSpacingBelow: deleteButton.topAnchor, multiplier: 1),
            deleteButton.trailingAnchor.constraint(equalToSystemSpacingAfter: photo.trailingAnchor, multiplier: 1),
            deleteButton.heightAnchor.constraint(equalToConstant: 20),
            deleteButton.widthAnchor.constraint(equalToConstant: 20),
            
        ])
    }
    
    @objc private func deleteButtonDidTap() {
        self.buttonTapAction?() 
    }
    //MARK: - Internal
    func configure(with image: UIImage?) {
        if self.cellType == .camera {
            self.photo.tintColor = .systemGray
        }
        self.photo.image = image
    }
    
    func setCellType(_ type: Type) {
        self.cellType = type
    }
}

