//
//  DetailInftoBottomSheetViewController.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/30.
//

import UIKit
import Combine

final class DetailInftoBottomSheetViewController: BottomSheetViewController {
    
    // MARK: - Dependency
    private let vm: DetailInftoBottomSheetViewViewModel
    
    // MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    // MARK: - UI Elements
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.font = .systemFont(ofSize: UPlusFont.h2, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let infoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: ImageAsset.xMarkBlack), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Init
    init(vm: DetailInftoBottomSheetViewViewModel, defaultHeight: CGFloat = 600) {
        self.vm = vm
        super.init(defaultHeight: defaultHeight)
        
        self.setUI()
        self.setLayout()
        
        self.configure()
        self.bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Configure
extension DetailInftoBottomSheetViewController {
    private func configure() {
        self.titleLabel.text = self.vm.type.title
        self.infoImageView.image = self.vm.type.image
    }
}

extension DetailInftoBottomSheetViewController {
    private func bind() {
        self.cancelButton.tapPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let `self` = self else { return }
                
                self.dismissView {}
            }
            .store(in: &bindings)
    }
}

// MARK: - Set UI & Layout
extension DetailInftoBottomSheetViewController {
    private func setUI() {
        self.containerView.addSubviews(self.titleLabel,
                                       self.cancelButton,
                                       self.infoImageView)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.titleLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.containerView.topAnchor, multiplier: 2),
            self.titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.containerView.leadingAnchor, multiplier: 2),
            self.containerView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.titleLabel.trailingAnchor, multiplier: 2),
            
            self.cancelButton.topAnchor.constraint(equalTo: self.titleLabel.topAnchor),
            self.containerView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.cancelButton.trailingAnchor, multiplier: 2),
            self.cancelButton.bottomAnchor.constraint(equalTo: self.titleLabel.bottomAnchor),
            
            self.infoImageView.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor),
            self.infoImageView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.infoImageView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.infoImageView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor)
        ])
    }
}
