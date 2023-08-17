//
//  RoutineParticipationViewController.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/16.
//

import UIKit
import Combine

final class RoutineParticipatedViewController: UIViewController {
    
    private let vm: RoutineParticipationViewViewModel
    
    // MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    // MARK: - UI Elements
    private let loadingVC = LoadingViewController()
    
    private let backgroundConfetti: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: ImageAsset.confetti)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let resultLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: UPlusFont.missionTitle, weight: .bold)
        label.text = MissionConstants.missionParticipated
        label.textAlignment = .center
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let missionCompleteIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: ImageAsset.pointShadow)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var confirmButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.titleLabel?.font = .systemFont(ofSize: UPlusFont.body1, weight: .bold)
        button.clipsToBounds = true
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Init
    init(vm: RoutineParticipationViewViewModel) {
        self.vm = vm
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
        self.setNavigationBar()
        self.configure()
    }
    
}

// MARK: - Configure
extension RoutineParticipatedViewController {
    
    private func configure() {
        self.confirmButton.setTitle(String(format: MissionConstants.redeemPoint, self.vm.mission.missionRewardPoint),
                                    for: .normal)
    }
    
    private func bind() {
        self.confirmButton.tapPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let `self` = self else { return }
                //TODO: 어느 VC로 돌아갈 지 결정 필요.
                self.dismiss(animated: true)
            }
            .store(in: &bindings)
    }
    
}

// MARK: - Set UI & Layout
extension RoutineParticipatedViewController {
    private func setUI() {
        self.view.addSubviews(self.backgroundConfetti,
                              self.resultLabel,
                              self.missionCompleteIcon,
                              self.confirmButton)
    }
    
    private func setLayout() {
        self.backgroundConfetti.frame = view.bounds
        
        NSLayoutConstraint.activate([
            self.resultLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.view.safeAreaLayoutGuide.topAnchor, multiplier: 10),
            self.resultLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            
            self.missionCompleteIcon.topAnchor.constraint(equalToSystemSpacingBelow: self.resultLabel.bottomAnchor, multiplier: 5),
            self.missionCompleteIcon.leadingAnchor.constraint(equalToSystemSpacingAfter: self.view.safeAreaLayoutGuide.leadingAnchor, multiplier: 10),
            self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: self.missionCompleteIcon.trailingAnchor, multiplier: 10),
            
            self.confirmButton.topAnchor.constraint(equalToSystemSpacingBelow: self.missionCompleteIcon.bottomAnchor, multiplier: 5),
            self.confirmButton.leadingAnchor.constraint(equalToSystemSpacingAfter: self.view.safeAreaLayoutGuide.leadingAnchor, multiplier: 3),
            self.confirmButton.heightAnchor.constraint(equalToConstant: self.view.frame.height / 15),
            self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: self.confirmButton.trailingAnchor, multiplier: 3),
            self.view.safeAreaLayoutGuide.bottomAnchor.constraint(equalToSystemSpacingBelow: self.confirmButton.bottomAnchor, multiplier: 3)
        ])
        self.resultLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
    
    private func setNavigationBar() {
        self.navigationItem.hidesBackButton = true
    }
}
