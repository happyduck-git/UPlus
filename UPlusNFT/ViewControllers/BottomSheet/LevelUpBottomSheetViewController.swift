//
//  LevelUpBottomSheetViewController.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/16.
//

import UIKit
import Combine

protocol NftBottomSheetDelegate: AnyObject {
    func redeemButtonDidTap()
}

final class LevelUpBottomSheetViewController: BottomSheetViewController {
    
    private let newLevel: Int
    
    //MARK: - Delegate
    weak var delegate: NftBottomSheetDelegate?
    
    // MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    // MARK: - UI Elements

    private let levelTitle: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: UPlusFont.h2, weight: .bold)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nftImage: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .systemGray
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let levelBackgroudView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: ImageAsset.titleBackground)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let levelLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.text = MissionConstants.levelUpTitle
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let benefitContainerView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 10.0
        view.backgroundColor = UPlusColor.grayBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let benefitLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = MyPageConstants.benefit
        label.textColor = UPlusColor.blue03
        label.font = .systemFont(ofSize: UPlusFont.h5, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let couponView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: ImageAsset.couponFrame)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let couponLabel: UILabel = {
        let label = UILabel()
        label.text = MyPageConstants.coffee
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let raffleView: UILabel = {
        let label = UILabel()
        label.text = MyPageConstants.raffle
        label.textAlignment = .center
        label.textColor = UPlusColor.gray05
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let eventView: UILabel = {
        let label = UILabel()
        label.text = MyPageConstants.eventOpened
        label.textColor = UPlusColor.gray05
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let redeemButton: UIButton = {
        let button = UIButton()
        button.setTitle(MissionConstants.redeemNft, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.clipsToBounds = true
        button.layer.cornerRadius = 10.0
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Init
    init(newLevel: Int) {
        self.newLevel = newLevel
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUI()
        self.setLayout()
        
        self.configure()
        self.bind()
    }
    
}

extension LevelUpBottomSheetViewController {
    private func configure() {
        guard let level = UserLevel(rawValue: newLevel) else { return }
        let coupon = level.coupon
        let raffle = level.raffle
        
        self.levelTitle.text = String(format: MyPageConstants.levelUp, level.rawValue)
        self.couponLabel.text = coupon
        self.raffleView.text = raffle
    }
    
    private func bind() {
        func bindViewToViewModel() {
            self.redeemButton.tapPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    guard let `self` = self else { return }
                    
                    self.dismissView {
                        self.delegate?.redeemButtonDidTap()
                    }
                    
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
extension LevelUpBottomSheetViewController {
    private func setUI() {
        
        self.containerView.addSubviews(self.levelTitle,
                                       self.nftImage,
                                       self.levelBackgroudView,
                                       self.levelLabel,
                                       self.benefitContainerView,
                                       self.redeemButton)
        
        self.benefitContainerView.addSubviews(self.couponView,
                                              self.couponLabel,
                                              self.benefitLabel,
                                              self.raffleView,
                                              self.eventView)
        
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.levelTitle.topAnchor.constraint(equalToSystemSpacingBelow: self.containerView.topAnchor, multiplier: 3),
            self.levelTitle.leadingAnchor.constraint(equalToSystemSpacingAfter: self.containerView.leadingAnchor, multiplier: 2),
            self.containerView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.levelTitle.trailingAnchor, multiplier: 2),
            
            self.nftImage.topAnchor.constraint(equalToSystemSpacingBelow: self.levelTitle.bottomAnchor, multiplier: 3),
            self.nftImage.widthAnchor.constraint(equalToConstant: self.view.frame.width / 2),
            self.nftImage.heightAnchor.constraint(equalTo: self.nftImage.widthAnchor),
            self.nftImage.centerXAnchor.constraint(equalTo: self.containerView.centerXAnchor),
            
            self.levelBackgroudView.centerYAnchor.constraint(equalTo: self.nftImage.bottomAnchor),
            self.levelBackgroudView.centerXAnchor.constraint(equalTo: self.nftImage.centerXAnchor),
            
            self.levelLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.levelBackgroudView.leadingAnchor, multiplier: 1),
            self.levelLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.levelBackgroudView.topAnchor, multiplier: 1),
            self.levelBackgroudView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.levelLabel.trailingAnchor, multiplier: 1),
            self.levelBackgroudView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.levelLabel.bottomAnchor, multiplier: 1),
            
            self.benefitContainerView.topAnchor.constraint(equalToSystemSpacingBelow: self.levelBackgroudView.bottomAnchor, multiplier: 1),
            self.benefitContainerView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.containerView.leadingAnchor, multiplier: 2),
            self.containerView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.benefitContainerView.trailingAnchor, multiplier: 2),
            
            self.redeemButton.topAnchor.constraint(equalToSystemSpacingBelow: self.benefitContainerView.bottomAnchor, multiplier: 1),
            self.redeemButton.leadingAnchor.constraint(equalTo: self.benefitContainerView.leadingAnchor),
            self.redeemButton.trailingAnchor.constraint(equalTo: self.benefitContainerView.trailingAnchor),
            self.redeemButton.heightAnchor.constraint(equalToConstant: 60),
            self.containerView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.redeemButton.bottomAnchor, multiplier: 1)
            
        ])
        
        NSLayoutConstraint.activate([
            self.benefitLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.benefitContainerView.topAnchor, multiplier: 2),
            self.benefitLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.benefitContainerView.leadingAnchor, multiplier: 3),
            self.benefitContainerView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.benefitLabel.trailingAnchor, multiplier: 3),

            self.couponView.topAnchor.constraint(equalToSystemSpacingBelow: self.benefitLabel.bottomAnchor, multiplier: 1),
            self.couponView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.benefitContainerView.leadingAnchor, multiplier: 2),
            self.benefitContainerView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.couponView.bottomAnchor, multiplier: 2),
            self.couponView.widthAnchor.constraint(equalToConstant: self.view.frame.width / 3.5),

            self.couponLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.couponView.topAnchor, multiplier: 1),
            self.couponLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.couponView.leadingAnchor, multiplier: 1),
            self.couponView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.couponLabel.trailingAnchor, multiplier: 1),
            self.couponView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.couponLabel.bottomAnchor, multiplier: 1),
            
            self.raffleView.topAnchor.constraint(equalTo: self.couponView.topAnchor),
            self.raffleView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.couponView.trailingAnchor, multiplier: 1),
            self.raffleView.bottomAnchor.constraint(equalTo: self.couponView.bottomAnchor),

            self.eventView.topAnchor.constraint(equalTo: self.couponView.topAnchor),
            self.eventView.bottomAnchor.constraint(equalTo: self.couponView.bottomAnchor),
            self.eventView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.raffleView.trailingAnchor, multiplier: 1),
            self.benefitContainerView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.eventView.trailingAnchor, multiplier: 2)
        ])
        
        self.levelTitle.setContentHuggingPriority(.defaultHigh, for: .vertical)
        self.redeemButton.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct LevelUpBottomSheetViewController_Preview: PreviewProvider {
    static var previews: some View {
        LevelUpBottomSheetViewController(newLevel: 1).toPreview()
    }
}
#endif
