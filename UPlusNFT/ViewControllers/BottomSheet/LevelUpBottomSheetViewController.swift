//
//  LevelUpBottomSheetViewController.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/16.
//

import UIKit
import Combine

final class LevelUpBottomSheetViewController: BottomSheetViewController {
    
    private let newLevel: Int
    
    // MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    // MARK: - UI Elements
    private let stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20.0
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
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
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let benefitContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UPlusColor.grayBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let benefitLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = MyPageConstants.benefit
        label.textColor = UPlusColor.blue03
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let couponView: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let eventView: UILabel = {
        let event = UILabel()
        event.text = MyPageConstants.eventOpened
        event.translatesAutoresizingMaskIntoConstraints = false
        return event
    }()
    
    private let redeemButton: UIButton = {
        let button = UIButton()
        button.setTitle(MissionConstants.redeemNft, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Init
    init(newLevel: Int) {
        self.newLevel = newLevel
        super.init(nibName: nil, bundle: nil)
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
    }
    
}

extension LevelUpBottomSheetViewController {
    private func configure() {
        guard let level = UserLevel(rawValue: newLevel) else { return }
        let coupon = level.coupon
        let raffle = level.raffle
        
        self.levelTitle.text = String(format: MyPageConstants.levelUp, level.rawValue)
        self.couponView.text = coupon
    }
    
    private func bind() {
        func bindViewToViewModel() {
            self.redeemButton.tapPublisher
                .receive(on: DispatchQueue.main)
                .sink { _ in
                    // TODO: Save rewards and raffle to Firestore
                    
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
        self.stack.addArrangedSubviews(self.levelTitle,
                                       self.nftImage,
                                       self.benefitContainerView,
                                       self.redeemButton)
        
        self.benefitContainerView.addSubviews(self.benefitLabel,
                                              self.couponView,
                                              self.eventView)
        
        self.containerView.addSubviews(self.stack)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.stack.topAnchor.constraint(equalToSystemSpacingBelow: self.containerView.topAnchor, multiplier: 2),
            self.stack.leadingAnchor.constraint(equalToSystemSpacingAfter: self.containerView.leadingAnchor, multiplier: 3),
            self.containerView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.stack.trailingAnchor, multiplier: 3),
            self.containerView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.stack.bottomAnchor, multiplier: 5)
        ])
        
        NSLayoutConstraint.activate([
            self.benefitLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.benefitContainerView.topAnchor, multiplier: 1),
            self.benefitLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.benefitContainerView.leadingAnchor, multiplier: 3),
            self.benefitContainerView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.benefitLabel.trailingAnchor, multiplier: 3),
            self.couponView.topAnchor.constraint(equalToSystemSpacingBelow: self.benefitLabel.bottomAnchor, multiplier: 1),
            self.couponView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.benefitContainerView.leadingAnchor, multiplier: 1),
            self.benefitContainerView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.couponView.bottomAnchor, multiplier: 1),
            
            self.eventView.topAnchor.constraint(equalTo: self.couponView.topAnchor),
            self.eventView.bottomAnchor.constraint(equalTo: self.couponView.bottomAnchor),
            self.benefitContainerView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.eventView.trailingAnchor, multiplier: 1)
        ])
    }
}
