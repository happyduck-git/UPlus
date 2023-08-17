//
//  GovernanceElectionMissionViewController.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/08/09.
//

import UIKit
import Combine
import OSLog

final class GovernanceElectionMissionViewController: BaseMissionViewController, EventCompletedViewControllerDelegate {
    func redeemDidTap() {
        <#code#>
    }
    

    //MARK: - Dependency
    private let vm: GovernanceElectionMissionViewViewModel

    // MARK: - Logger
    private let logger = Logger()
    
    //MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    //MARK: - UI Elements
    private let loadingVC = LoadingViewController()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray3
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
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
            self.choiceButtons.append(button)
            self.stack.addArrangedSubview(button)
        }
        self.vm.buttonStatus = Array(repeating: false, count: captions.count)
    }
    
}

extension GovernanceElectionMissionViewController {
 
    private func bind() {
        func bindViewToViewModel() {
            
            for button in self.choiceButtons {
                button.tapPublisher
                    .receive(on: DispatchQueue.main)
                    .sink { _ in
                        self.answerInfoLabel.isHidden = true
                        self.checkAnswerButton.isUserInteractionEnabled = true
                        self.checkAnswerButton.backgroundColor = UPlusColor.gray09
                        
                        let tag = button.tag
                        if !self.vm.buttonStatus[tag] {
                            if let prev = self.vm.selectedButton {
                                self.vm.buttonStatus[prev].toggle()
                                self.choiceButtons[prev].layer.borderColor = UIColor.clear.cgColor
                                self.choiceButtons[prev].toggleImage(hidden: true)
                            }
                            self.choiceButtons[tag].layer.borderColor = UPlusColor.gray05.cgColor
                            
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
                        let vc = EventCompletedViewController(vm: self.vm)
                        vc.delegate?.redeemDidTap()
                        vc.delegate = self
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
        self.view.addSubviews(
            self.imageView,
            self.stack
        )
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.imageView.topAnchor.constraint(equalToSystemSpacingBelow: self.quizContainer.topAnchor, multiplier: 2),
            self.imageView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.quizContainer.leadingAnchor, multiplier: 5),
            self.quizContainer.trailingAnchor.constraint(equalToSystemSpacingAfter: self.imageView.trailingAnchor, multiplier: 5),
            self.imageView.heightAnchor.constraint(equalTo: self.imageView.widthAnchor),
            
            self.stack.topAnchor.constraint(equalToSystemSpacingBelow: self.imageView.bottomAnchor, multiplier: 2),
            self.stack.leadingAnchor.constraint(equalToSystemSpacingAfter: self.quizContainer.leadingAnchor, multiplier: 3),
            self.quizContainer.trailingAnchor.constraint(equalToSystemSpacingAfter: self.stack.trailingAnchor, multiplier: 3),
            self.quizContainer.bottomAnchor.constraint(equalToSystemSpacingBelow: self.stack.bottomAnchor, multiplier: 3)
        ])
    }
}

extension GovernanceElectionMissionViewController: EventCompletedViewControllerDelegate {
    func redeemDidTap() {
        
    }
}
