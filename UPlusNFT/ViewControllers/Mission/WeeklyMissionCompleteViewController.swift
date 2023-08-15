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

protocol WeeklyMissionCompleteViewControllerDelegate: AnyObject {
    func answerDidSaved()
}

final class WeeklyMissionCompleteViewController: UIViewController {
    
    // MARK: - Dependency
    private let vm: WeeklyQuizBaseModel
    private let firestoreManager = FirestoreManager.shared
    
    //MARK: - Delegate
    weak var delegate: WeeklyMissionCompleteViewControllerDelegate?
    
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
        label.text = MissionConstants.missionComplete
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
    init(vm: WeeklyQuizBaseModel) {
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
                
                self.addChildViewController(self.loadingVC)
                
                let dataSource = self.vm.mission
               
               guard let missionType = MissionType(rawValue: dataSource.missionSubTopicType) else {
                    return
                }
                
                Task {
                    do {
                        try await self.firestoreManager
                            .saveParticipatedWeeklyMission(
                                questionId: dataSource.missionId,
                                week: self.vm.numberOfWeek,
                                today: Date().yearMonthDateFormat,
                                missionType: missionType,
                                point: dataSource.missionRewardPoint,
                                state: .successed
                            )
                        self.delegate?.answerDidSaved()
                        self.loadingVC.removeViewController()
                        
                        guard let vcs = self.navigationController?.viewControllers else { return }
                        
                        for vc in vcs where vc is WeeklyMissionOverViewViewController {
                            self.navigationController?.popToViewController(vc, animated: true)
                        }
                        
                        // Weekly mission 완료 상태 확인
                        self.vm.weeklyMissionCompletion = try await self.firestoreManager
                            .checkWeeklyMissionSetCompletion(
                                week: self.vm.numberOfWeek
                            )
 
                    }
                    catch {
                        print("Error saving mission and user data -- \(error)")
                    }
                }
            }
            .store(in: &bindings)
        
        self.vm.$weeklyMissionCompletion
            .receive(on: RunLoop.current)
            .sink {
                if $0 {
                    // TODO: 여정인증서 NFT 발급 요청(NFT 서비스 인프라).
                    
                } else {
                    print("아직 주간 여정을 모두 마치지 않았습니다.")
                }
            }
            .store(in: &bindings)
    }
}

// MARK: - Configure with View Model
extension WeeklyMissionCompleteViewController {
    private func configure() {
        self.confirmButton.setTitle(String(format: MissionConstants.redeemPoint, self.vm.mission.missionRewardPoint), for: .normal)
    }
}

// MARK: - Set UI & Layout
extension WeeklyMissionCompleteViewController {
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
