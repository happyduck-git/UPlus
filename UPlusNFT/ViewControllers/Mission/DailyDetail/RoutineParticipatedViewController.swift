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
        imageView.image = UIImage(named: ImageAssets.confettiBackground)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let resultLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: UPlusFont.missionTitle, weight: .bold)
        label.text = MissionConstants.questCompleted
        label.textAlignment = .center
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let pointLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: UPlusFont.h2, weight: .semibold)
        label.textColor = UPlusColor.blue04
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let pointIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: ImageAssets.pointBig)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let shadowIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: ImageAssets.pointShadow)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var confirmButton: UIButton = {
        let button = UIButton()
        button.setTitle(MissionConstants.confirm, for: .normal)
        button.setTitleColor(UPlusColor.gray08, for: .normal)
        button.backgroundColor = UPlusColor.mint03
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
        
        self.view.backgroundColor = .white
        
        self.setUI()
        self.setLayout()
        self.setNavigationBar()
        
        self.configure()
        self.bind()
    }
    
}

// MARK: - Configure
extension RoutineParticipatedViewController {
    
    private func configure() {
        
        self.pointLabel.text = String(format: MissionConstants.missionSubmissionNotice, self.vm.mission.missionRewardPoint)
        
    }
    
    private func bind() {
        self.confirmButton.tapPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let `self` = self else { return }
                
                guard let vcs = self.navigationController?.viewControllers else { return }
                for vc in vcs where vc is MyPageViewController {
                    DispatchQueue.main.async {
                        self.navigationController?.popToViewController(vc, animated: true)
                    }
                }
              
            }
            .store(in: &bindings)
    }
    
}

// MARK: - Set UI & Layout
extension RoutineParticipatedViewController {
    private func setUI() {
        self.view.addSubviews(self.backgroundConfetti,
                              self.resultLabel,
                              self.pointLabel,
                              self.pointIcon,
                              self.shadowIcon,
                              self.confirmButton)
    }
    
    private func setLayout() {
        self.backgroundConfetti.frame = view.bounds
        
        NSLayoutConstraint.activate([
            self.resultLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.view.safeAreaLayoutGuide.topAnchor, multiplier: 10),
            self.resultLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            
            self.pointLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.resultLabel.bottomAnchor, multiplier: 2),
            self.pointLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.view.safeAreaLayoutGuide.leadingAnchor, multiplier: 2),
            self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: self.pointLabel.trailingAnchor, multiplier: 2),
            
            self.pointIcon.topAnchor.constraint(equalToSystemSpacingBelow: self.pointLabel.bottomAnchor, multiplier: 2),
            self.pointIcon.leadingAnchor.constraint(equalToSystemSpacingAfter: self.view.safeAreaLayoutGuide.leadingAnchor, multiplier: 6),
            self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: self.pointIcon.trailingAnchor, multiplier: 6),
            
            self.shadowIcon.topAnchor.constraint(equalToSystemSpacingBelow: self.pointIcon.bottomAnchor, multiplier: 1),
            self.shadowIcon.leadingAnchor.constraint(equalTo: self.pointIcon.leadingAnchor),
            self.shadowIcon.trailingAnchor.constraint(equalTo: self.pointIcon.trailingAnchor),
            
            self.confirmButton.topAnchor.constraint(equalToSystemSpacingBelow: self.shadowIcon.bottomAnchor, multiplier: 3),
            self.confirmButton.leadingAnchor.constraint(equalToSystemSpacingAfter: self.view.safeAreaLayoutGuide.leadingAnchor, multiplier: 3),
            self.confirmButton.heightAnchor.constraint(equalToConstant: LoginConstants.buttonHeight),
            self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: self.confirmButton.trailingAnchor, multiplier: 3),
            self.view.safeAreaLayoutGuide.bottomAnchor.constraint(equalToSystemSpacingBelow: self.confirmButton.bottomAnchor, multiplier: 3)
        ])
        self.resultLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        self.pointLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
    
    private func setNavigationBar() {
        self.navigationItem.hidesBackButton = true
    }
}
