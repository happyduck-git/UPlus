//
//  GiftSentBottomSheetViewController.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/18.
//

import UIKit

final class GiftSentBottomSheetViewController: BottomSheetViewController {
    
    // MARK: - UI Elements
    private let giftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: ImageAsset.giftColored)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = GiftConstants.giftSentDescription
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: UPlusFont.h2, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let giftContainerView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 8.0
        view.backgroundColor = UPlusColor.gray01
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 5.0
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let toLabel: UILabel = {
        let label = UILabel()
        label.text = GiftConstants.sendTo
        label.textColor = UPlusColor.gray06
        label.font = .systemFont(ofSize: UPlusFont.body2, weight: .regular)
        return label
    }()
    
    private let sentNftLabel: UILabel = {
        let label = UILabel()
        label.text = GiftConstants.sentNft
        label.textColor = UPlusColor.gray06
        label.font = .systemFont(ofSize: UPlusFont.body2, weight: .regular)
        return label
    }()
    
    private let containerStack: UIStackView = {
       let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let nameStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 5.0
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let toNameLabel: UILabel = {
        let label = UILabel()
        label.text = "받는 사람"
        label.textColor = .black
        label.font = .systemFont(ofSize: UPlusFont.body2, weight: .bold)
        return label
    }()
    
    private let sentNftNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = "선물한 NFT"
        label.font = .systemFont(ofSize: UPlusFont.body2, weight: .bold)
        return label
    }()
    
    private let sendInfoLabel: UILabel = {
        let label = UILabel()
        label.text = GiftConstants.sendInfo
        label.textColor = UPlusColor.gray06
        label.textAlignment = .center
        label.font = .systemFont(ofSize: UPlusFont.caption1, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let confirmButton: UIButton = {
        let button = UIButton()
        button.setTitle(GiftConstants.confirm, for: .normal)
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUI()
        self.setLayout()
    }
    
    override init(defaultHeight: CGFloat = 500) {
        super.init(defaultHeight: defaultHeight)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Set UI & Layout
extension GiftSentBottomSheetViewController {
    private func setUI() {
        
        self.view.addSubview(self.giftImageView)
        
        self.containerView.addSubviews(
            self.titleLabel,
            self.giftContainerView,
            self.sendInfoLabel,
            self.confirmButton
        )
        self.giftContainerView.addSubviews(self.containerStack)

        self.containerStack.addArrangedSubviews(self.titleStack,
                                                self.nameStack)
        
        self.titleStack.addArrangedSubviews(self.toLabel,
                                            self.sentNftLabel)
        self.nameStack.addArrangedSubviews(self.toNameLabel,
                                            self.sentNftNameLabel)
        
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.giftImageView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.containerView.topAnchor, multiplier: 2),
            self.giftImageView.centerXAnchor.constraint(equalTo: self.containerView.centerXAnchor),
            self.giftImageView.heightAnchor.constraint(equalToConstant: 82),
            self.giftImageView.widthAnchor.constraint(equalToConstant: 56),
            
            self.titleLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.containerView.topAnchor, multiplier: 10),
            self.titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.containerView.leadingAnchor, multiplier: 2),
            self.containerView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.titleLabel.trailingAnchor, multiplier: 2),

            self.giftContainerView.topAnchor.constraint(equalToSystemSpacingBelow: self.titleLabel.bottomAnchor, multiplier: 6),
            self.giftContainerView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.containerView.leadingAnchor, multiplier: 2),
            self.containerView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.giftContainerView.trailingAnchor, multiplier: 2),

            self.sendInfoLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.giftContainerView.bottomAnchor, multiplier: 5),
            self.sendInfoLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.containerView.leadingAnchor, multiplier: 2),
            self.containerView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.sendInfoLabel.trailingAnchor, multiplier: 2),

            self.confirmButton.topAnchor.constraint(equalToSystemSpacingBelow: self.sendInfoLabel.bottomAnchor, multiplier: 5),
            self.confirmButton.leadingAnchor.constraint(equalTo: self.giftContainerView.leadingAnchor),
            self.confirmButton.trailingAnchor.constraint(equalTo: self.giftContainerView.trailingAnchor),
            self.containerView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.confirmButton.bottomAnchor, multiplier: 5)
        ])
        
        NSLayoutConstraint.activate([
            self.containerStack.topAnchor.constraint(equalToSystemSpacingBelow: self.giftContainerView.topAnchor, multiplier: 2),
            self.containerStack.leadingAnchor.constraint(equalToSystemSpacingAfter: self.giftContainerView.leadingAnchor, multiplier: 2),
            self.giftContainerView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.containerStack.trailingAnchor, multiplier: 2),
            self.giftContainerView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.containerStack.bottomAnchor, multiplier: 2)
        ])
        self.titleLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        self.sendInfoLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        self.confirmButton.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct GiftSentBottomSheetViewController_Preview: PreviewProvider {
    static var previews: some View {
        GiftSentBottomSheetViewController().toPreview()
    }
}
#endif
