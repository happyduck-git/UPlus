//
//  WeeklyMissionCompleteBottomSheetViewController.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/16.
//

import UIKit
import Combine
import OSLog

final class WeeklyMissionCompleteBottomSheetViewController: BottomSheetViewController {
    
    // MARK: - Logger
    private let logger = Logger()
    
    // MARK: - Dependency
    private let vm: WeeklyMissionOverViewViewModel
    
    // MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    // MARK: - UI Elements
    private let stack: UIStackView = {
        let stack = UIStackView()
        stack.distribution = .fillProportionally
        stack.spacing = 10.0
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let greetingsLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.font = .systemFont(ofSize: UPlusFont.h2, weight: .bold)
        label.text = MissionConstants.congrats
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = MissionConstants.weeklyCompleted
        label.font = .systemFont(ofSize: UPlusFont.body2, weight: .regular)
        return label
    }()
    
    private let nftImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: ImageAsset.coloredNft)
        return image
    }()
    
    private let missionTypeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: UPlusFont.h1, weight: .bold)
        return label
    }()
    
    private let redeemButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.clipsToBounds = true
        button.layer.cornerRadius = 10
        button.setTitle(MissionConstants.redeemNft, for: .normal)
        return button
    }()
    
    // MARK: - Init
    init(vm: WeeklyMissionOverViewViewModel) {
        self.vm = vm
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
        
        self.bind()
    }
    
}

// MARK: - Configure
extension WeeklyMissionCompleteBottomSheetViewController {

    private func bind() {
        
        func bindViewToViewModel() {
            self.missionTypeLabel.text = vm.title
            
            self.redeemButton.tapPublisher
                .receive(on: DispatchQueue.global())
                .sink { [weak self] _ in
                    guard let `self` = self else { return }
                    self.vm.requestJourneyNft()
                    DispatchQueue.main.async {
                        self.dismiss(animated: true)
                    }
                }
                .store(in: &bindings)
        }
        
        func bindViewModelToView() {
            
            self.vm.nftIssueStatus
                .sink { [weak self] _ in
                    guard let `self` = self else { return }
                    self.logger.error("Error issueing nft")
                } receiveValue: { _ in
                    self.logger.info("Successfully request to issue nft to the server.")
                }
                .store(in: &bindings)

        }
        
        bindViewToViewModel()
        bindViewModelToView()
    }
}

// MARK: - Set UI & Layout
extension WeeklyMissionCompleteBottomSheetViewController {
    private func setUI() {
        self.containerView.addSubviews(self.stack,
                                      self.redeemButton)
        
        self.stack.addArrangedSubviews(self.greetingsLabel,
                                       self.titleLabel,
                                       self.nftImage,
                                       self.missionTypeLabel)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.stack.topAnchor.constraint(equalToSystemSpacingBelow: self.containerView.topAnchor, multiplier: 2),
            self.stack.leadingAnchor.constraint(equalToSystemSpacingAfter: self.containerView.leadingAnchor, multiplier: 3),
            self.containerView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.stack.trailingAnchor, multiplier: 3),
            self.containerView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.stack.bottomAnchor, multiplier: 5),
            
            self.redeemButton.topAnchor.constraint(equalToSystemSpacingBelow: self.stack.topAnchor, multiplier: 2),
            self.redeemButton.leadingAnchor.constraint(equalTo: self.stack.leadingAnchor),
            self.redeemButton.trailingAnchor.constraint(equalTo: self.stack.trailingAnchor),
            self.containerView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.redeemButton.bottomAnchor, multiplier: 2)
        ])
        
        self.redeemButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }
}
