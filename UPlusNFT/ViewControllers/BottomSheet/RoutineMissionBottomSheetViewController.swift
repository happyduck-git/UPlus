//
//  RoutineMissionBottomSheetViewController.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/28.
//

import UIKit
import Combine

final class RoutineMissionBottomSheetViewController: BottomSheetViewController {

    //MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    

    //MARK: - UI Elements
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.text = MyPageConstants.vipBenefitTitle
        label.font = .systemFont(ofSize: UPlusFont.h2, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: ImageAsset.vipPoint)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let missionCompleteLabel: UILabel = {
        let label = UILabel()
        label.text = " "
        label.numberOfLines = 2
        label.textAlignment = .center
        label.textColor = UPlusColor.mint04
        label.font = .systemFont(ofSize: UPlusFont.h2, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var receiveButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UPlusColor.mint03
        button.clipsToBounds = true
        button.layer.cornerRadius = 8.0
        button.setTitleColor(UPlusColor.gray08, for: .normal)
        button.setTitle(MissionConstants.receive, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    //MARK: - Init
    init() {
        super.init(defaultHeight: 480)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUI()
        self.setLayout()
        
        self.configure()
        self.bind()
    }
    
}

// MARK: - Configure
extension RoutineMissionBottomSheetViewController {
    
    private func configure() {
        
    }
    
}

// MARK: - Bind
extension RoutineMissionBottomSheetViewController {
    
    private func bind() {
        
        func bindViewToViewModel() {
            
            self.receiveButton.tapPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    guard let `self` = self else { return }
                    
                }
                .store(in: &bindings)
            
        }
        
        func bindViewModelToView() {
            
            
            
        }
        
        bindViewToViewModel()
        bindViewModelToView()
    }
    
}

extension RoutineMissionBottomSheetViewController {
    
    private func setUI() {
        self.containerView.addSubviews(self.titleLabel,
                                       self.nftImageView,
                                       self.missionCompleteLabel,
                                       self.receiveButton)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.titleLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.containerView.topAnchor, multiplier: 3),
            self.titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.containerView.leadingAnchor, multiplier: 2),
            self.containerView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.titleLabel.trailingAnchor, multiplier: 2),
            
            self.nftImageView.topAnchor.constraint(equalToSystemSpacingBelow: self.titleLabel.bottomAnchor, multiplier: 4),
            self.nftImageView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.containerView.leadingAnchor, multiplier: 3),
            self.containerView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.nftImageView.trailingAnchor, multiplier: 3),
            self.nftImageView.centerXAnchor.constraint(equalTo: self.containerView.centerXAnchor),
            
            self.missionCompleteLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.nftImageView.bottomAnchor, multiplier: 4),
            self.missionCompleteLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.containerView.leadingAnchor, multiplier: 1),
            self.containerView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.missionCompleteLabel.trailingAnchor, multiplier: 1),
            
            self.receiveButton.topAnchor.constraint(equalToSystemSpacingBelow: self.missionCompleteLabel.bottomAnchor, multiplier: 3),
            self.receiveButton.heightAnchor.constraint(equalToConstant: LoginConstants.buttonHeight),
            self.receiveButton.leadingAnchor.constraint(equalToSystemSpacingAfter: self.containerView.leadingAnchor, multiplier: 2),
            self.containerView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.receiveButton.trailingAnchor, multiplier: 2),
            self.containerView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.receiveButton.bottomAnchor, multiplier: 3)
        ])
        
        self.titleLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        self.missionCompleteLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
        self.receiveButton.setContentHuggingPriority(.defaultHigh, for: .vertical)
        
    }
    
}
