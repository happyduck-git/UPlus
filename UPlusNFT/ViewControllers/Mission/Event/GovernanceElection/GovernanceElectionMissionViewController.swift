//
//  GovernanceElectionMissionViewController.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/08/09.
//

import UIKit
import Combine
import OSLog

final class GovernanceElectionMissionViewController: BaseMissionViewController {
    
    //MARK: - Dependency
    private let vm: GovernanceElectionMissionViewViewModel
    
    // MARK: - Logger
    private let logger = Logger()
    
    //MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    //MARK: - UI Elements
    private let loadingVC = LoadingViewController()

    private let stack: UIStackView = {
       let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 5.0
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private var choiceButtons: [ChoiceMultipleQuizButton] = []

    //MARK: - Init
    init(vm: GovernanceElectionMissionViewViewModel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white
        self.setUI()
        self.setLayout()
        self.createChart()
        
        self.configure()
        self.bind()
    }

}

extension GovernanceElectionMissionViewController {
    
    private func createChart() {
        guard let mission = self.vm.mission as? GovernanceMission else { return }
        
        let captions = mission.governanceElectionCaptions
        for i in 0..<captions.count {
            let button = ChoiceMultipleQuizButton()
            button.tag = i
            button.setQuizTitle(text: captions[i])
            button.clipsToBounds = true
            button.layer.cornerRadius = 8.0
            self.choiceButtons.append(button)
            self.stack.addArrangedSubview(button)
        }
        self.vm.buttonStatus = Array(repeating: false, count: captions.count)
    }
    
}

// MARK: - Configure
extension GovernanceElectionMissionViewController {
    
    private func configure() {
        self.titleLabel.text = self.vm.mission.missionContentTitle
        self.quizLabel.text = self.vm.mission.missionContentText
    }
    
}

// MARK: - Bind
extension GovernanceElectionMissionViewController {
 
    private func bind() {
        func bindViewToViewModel() {
            
            for button in self.choiceButtons {
                button.tapPublisher
                    .receive(on: DispatchQueue.main)
                    .sink { _ in
                        self.answerInfoLabel.isHidden = true
                        self.checkAnswerButton.isUserInteractionEnabled = true
                        self.checkAnswerButton.setTitleColor(UPlusColor.gray08, for: .normal)
                        self.checkAnswerButton.backgroundColor = UPlusColor.mint03
                        
                        let tag = button.tag
                        if !self.vm.buttonStatus[tag] {
                            if let prev = self.vm.selectedButton {
                                self.vm.buttonStatus[prev].toggle()
                                self.choiceButtons[prev].layer.borderColor = UIColor.clear.cgColor
                                self.choiceButtons[prev].toggleImage(hidden: true)
                            }
                            self.choiceButtons[tag].layer.borderColor = UPlusColor.mint03.cgColor
                            self.choiceButtons[tag].layer.borderWidth = 3.0
                            
                            self.vm.buttonStatus[tag].toggle()
                            self.choiceButtons[tag].toggleImage(hidden: false)
                            self.vm.selectedButton = tag
                        }
                    }
                    .store(in: &bindings)
            }
            
            self.vm.$screenType
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    guard let `self` = self else { return }
                    if $0 == .result {
                        self.vm.calculateAnswerRatio()
                        self.checkAnswerButton.setTitle(MissionConstants.resultDidCheck, for: .normal)
                        
                        for button in self.choiceButtons {
                            let progress = self.vm.answerRatioMap[String(describing: button.tag)] ?? 0.0
                            button.setProgress(progress: progress)
                        }
                        
                    }
                }
                .store(in: &bindings)
            
            self.checkAnswerButton.tapPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    guard let `self` = self else { return }
                    if self.vm.screenType == .vote {
                        self.vm.screenType = .result
                    } else {
                        
                        var vc: BaseMissionCompletedViewController?
                        
                        switch self.vm.type {
                        case .event:
                            vc = EventCompletedViewController(vm: self.vm)
                            vc?.delegate = self
                        case .weekly:
                            vc = WeeklyMissionCompleteViewController(vm: self.vm)
                            vc?.delegate = self
                        }
                        
                        guard let vc = vc else { return }
                        self.navigationController?.modalPresentationStyle = .fullScreen
                        self.show(vc, sender: self)
                        
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

//MARK: - Set UI & Layout
extension GovernanceElectionMissionViewController {
    private func setUI() {
        self.checkAnswerButton.setTitle(MissionConstants.vote, for: .normal)
        
        self.view.addSubviews(self.stack)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.stack.topAnchor.constraint(equalToSystemSpacingBelow: self.quizContainer.topAnchor, multiplier: 2),
            self.stack.leadingAnchor.constraint(equalToSystemSpacingAfter: self.quizContainer.leadingAnchor, multiplier: 3),
            self.quizContainer.trailingAnchor.constraint(equalToSystemSpacingAfter: self.stack.trailingAnchor, multiplier: 3),
            self.quizContainer.bottomAnchor.constraint(equalToSystemSpacingBelow: self.stack.bottomAnchor, multiplier: 3)
        ])
        
        self.titleLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
}

extension GovernanceElectionMissionViewController: BaseMissionCompletedViewControllerDelegate {
    func redeemDidTap() {
        self.delegate?.redeemDidTap(vc: self)
    }
}
