//
//  MissionCompleteViewController.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/20.
//

import UIKit
import Combine

enum MissionAnswerState: String {
    case pending
    case successed
    case failed
}

class WeeklyMissionCompleteViewController: UIViewController {
    
    // MARK: - Dependency
    private let vm: WeeklyMissionDetailViewViewModel
    private let firestoreManager = FirestoreManager.shared
    
    // MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    // MARK: - UI Elements
    private let resultLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 40, weight: .bold)
        let attributedString = NSMutableAttributedString(string: MissionConstants.missionSuccess)
        attributedString.addAttributes([.font: UIFont.systemFont(ofSize: 82)], range: NSRange(location: 6, length: 2))
        label.attributedText = attributedString
        label.textAlignment = .center
        label.textColor = .black
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let missionCompleteIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .darkGray
        imageView.transform = CGAffineTransform(rotationAngle: .pi / 4)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let pointLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var confirmButton: UIButton = {
        let button = UIButton()
        button.setTitle(MissionConstants.confirm, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(confirmButtonDidTap), for: .touchUpInside)
        button.backgroundColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Init
    init(vm: WeeklyMissionDetailViewViewModel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
        self.configure()
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
        self.bind()
    }
    
}

extension WeeklyMissionCompleteViewController {
    private func bind() {
        self.confirmButton.tapPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let `self` = self else { return }
                
                let dataSource = self.vm.dataSource
                guard let questionId = dataSource.postId,
                      let missionType = MissionType(rawValue: dataSource.missionSubTopicType) else {
                    return
                }
                // TODO: 정답인 경우 firestore 저장
                Task {
                    do {
                        let user = try UPlusUser.getCurrentUser()
  
                        try await self.firestoreManager
                            .saveParticipatedMission(userIndex: user.userIndex,
                                                     questionId: questionId,
                                                     week: self.vm.numberOfWeek,
                                                     date: Date().yearMonthDateFormat,
                                                     missionType: missionType,
                                                     point: dataSource.missionRewardPoint,
                                                     state: .successed)
                    }
                    catch {
                        print("Error saving mission and user data -- \(error)")
                    }
                }
            }
            .store(in: &bindings)
    }
}

// MARK: - Configure with View Model
extension WeeklyMissionCompleteViewController {
    private func configure() {
        self.pointLabel.text = String(describing: self.vm.dataSource.missionRewardPoint) + MissionConstants.redeemPointSuffix
    }
}

// MARK: - Button Action
extension WeeklyMissionCompleteViewController {
    @objc private func confirmButtonDidTap() {
        
        guard let vcs = self.navigationController?.viewControllers else { return }
        for vc in vcs where vc is MissionMainViewController {
            self.navigationController?.popToViewController(vc, animated: true)
        }
        
        // TODO: 수령한 Point DB에 저장.
    }
}

// MARK: - Set UI & Layout
extension WeeklyMissionCompleteViewController {
    private func setUI() {
        self.view.addSubviews(resultLabel,
                              missionCompleteIcon,
                              pointLabel,
                              confirmButton)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.resultLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.view.safeAreaLayoutGuide.topAnchor, multiplier: 3),
            self.resultLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.missionCompleteIcon.topAnchor.constraint(equalToSystemSpacingBelow: self.resultLabel.bottomAnchor, multiplier: 5),
            self.missionCompleteIcon.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.missionCompleteIcon.heightAnchor.constraint(equalToConstant: 100),
            self.missionCompleteIcon.widthAnchor.constraint(equalTo: self.missionCompleteIcon.heightAnchor),
            self.pointLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.missionCompleteIcon.bottomAnchor, multiplier: 3),
            self.pointLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            
            self.confirmButton.leadingAnchor.constraint(equalToSystemSpacingAfter: self.view.safeAreaLayoutGuide.leadingAnchor, multiplier: 3),
            self.confirmButton.heightAnchor.constraint(equalToConstant: self.view.frame.height / 15),
            self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: self.confirmButton.trailingAnchor, multiplier: 3),
            self.view.safeAreaLayoutGuide.bottomAnchor.constraint(equalToSystemSpacingBelow: self.confirmButton.bottomAnchor, multiplier: 3)
        ])
    }
    
    private func setNavigationBar() {
        self.navigationItem.hidesBackButton = true
    }
}
