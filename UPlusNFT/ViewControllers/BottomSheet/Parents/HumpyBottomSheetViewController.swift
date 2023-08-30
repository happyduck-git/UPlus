//
//  HumpyBottomSheetViewController.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/28.
//

import UIKit

class HumpyBottomSheetViewController: BottomSheetViewController {
    
    private let humpView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let topImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.backgroundColor = UPlusColor.grayBackground
        imageView.layer.cornerRadius = 60.0
        imageView.layer.borderColor = UPlusColor.mint03.cgColor
        imageView.layer.borderWidth = 6.0
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleBgImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: ImageAsset.titleBackground)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let levelLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: UPlusFont.mainFont, size: UPlusFont.h2)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let middleContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let confirmButton: UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.layer.cornerRadius = 8.0
        button.setTitleColor(UPlusColor.gray08, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: UPlusFont.body1, weight: .bold)
        button.backgroundColor = UPlusColor.mint03
        button.setTitleColor(UPlusColor.gray08, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Init
    override init(defaultHeight: CGFloat = 600) {
        super.init(defaultHeight: defaultHeight)
        
        self.setUI()
        self.setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.humpView.layer.cornerRadius = self.humpView.frame.width / 2.5
        self.topImageView.layer.cornerRadius = self.topImageView.frame.width / 2.5
    }
    
}

// MARK: - Set UI & Layout
extension HumpyBottomSheetViewController {
    private func setUI() {
        self.view.addSubviews(self.humpView,
                              self.topImageView,
                              self.titleBgImageView,
                              self.levelLabel)
        
        self.containerView.addSubviews(self.middleContainer,
                                       self.confirmButton)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.containerView.topAnchor.constraint(equalToSystemSpacingBelow: self.humpView.topAnchor, multiplier: 9),
            self.humpView.widthAnchor.constraint(equalToConstant: self.view.frame.width / 2),
            self.humpView.heightAnchor.constraint(equalTo: self.humpView.widthAnchor),
            self.humpView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            
            self.topImageView.topAnchor.constraint(equalToSystemSpacingBelow: self.humpView.topAnchor, multiplier: 2),
            self.topImageView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.humpView.leadingAnchor, multiplier: 2),
            self.humpView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.topImageView.trailingAnchor, multiplier: 2),
            self.humpView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.topImageView.bottomAnchor, multiplier: 2),
            
            self.topImageView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.titleBgImageView.topAnchor, multiplier: 3),
            self.titleBgImageView.centerXAnchor.constraint(equalTo: self.topImageView.centerXAnchor),
            
            self.levelLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.titleBgImageView.topAnchor, multiplier: 1),
            self.levelLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.titleBgImageView.leadingAnchor, multiplier: 2),
            self.titleBgImageView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.levelLabel.trailingAnchor, multiplier: 2),
            self.titleBgImageView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.levelLabel.bottomAnchor, multiplier: 1),
            
            self.middleContainer.topAnchor.constraint(equalToSystemSpacingBelow: self.titleBgImageView.bottomAnchor, multiplier: 1),
            self.middleContainer.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.middleContainer.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            
            self.confirmButton.topAnchor.constraint(equalTo: self.middleContainer.bottomAnchor),
            self.confirmButton.heightAnchor.constraint(equalToConstant: LoginConstants.buttonHeight),
            self.confirmButton.leadingAnchor.constraint(equalToSystemSpacingAfter: self.containerView.leadingAnchor, multiplier: 2),
            self.containerView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.confirmButton.trailingAnchor, multiplier: 2),
            self.containerView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.confirmButton.bottomAnchor, multiplier: 3)
            
        ])
    }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct HumpyBottomSheetViewController_Preview: PreviewProvider {
    static var previews: some View {
        
        HumpyBottomSheetViewController().toPreview()
    }
}
#endif
