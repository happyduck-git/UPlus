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
    private let vm: ChoiceQuizzesViewViewModel
    private let firestoreManager = FirestoreManager.shared
    
    //MARK: - Delegate
    weak var delegate: WeeklyMissionCompleteViewControllerDelegate?
    
    // MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    // MARK: - UI Elements
    private let loadingVC = LoadingViewController()
    
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
        button.backgroundColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Init
    init(vm: ChoiceQuizzesViewViewModel) {
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
        self.pointLabel.text = String(describing: self.vm.mission.missionRewardPoint) + MissionConstants.redeemPointSuffix
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
