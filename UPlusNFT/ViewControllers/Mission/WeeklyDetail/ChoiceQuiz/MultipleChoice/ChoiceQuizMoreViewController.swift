//
//  ChoiceQuizMoreViewController.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/08/10.
//

import UIKit
import Combine

final class ChoiceQuizMoreViewController: BaseMissionViewController {
    
    //MARK: - Dependency
    private let vm: ChoiceQuizMoreViewViewModel

    //MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    //MARK: - UI Elements
    private let buttonStack: UIStackView = {
        let stack = UIStackView()
        stack.backgroundColor = .clear
        stack.distribution = .fillEqually
        stack.axis = .vertical
        stack.spacing = 10.0
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private var choiceButtons: [ChoiceMultipleQuizButton] = []
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.createChoiceButtons()
        self.setUI()
        self.setLayout()
        
        self.bind()
    }
    
    //MARK: - Init
    init(vm: ChoiceQuizMoreViewViewModel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
        self.setBaseVM(vm: vm)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
}

extension ChoiceQuizMoreViewController {
    
    private func bind() {
        
        guard let mission = self.vm.mission as? ChoiceQuizMission else { return }
        
        for button in choiceButtons {
            button.tapPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    guard let `self` = self else { return }
                    
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

        self.checkAnswerButton.tapPublisher
            .receive(on: RunLoop.current)
            .sink { [weak self] _ in
                guard let `self` = self else { return }
                
                if let selected = self.vm.selectedButton {
                    if mission.missionChoiceQuizRightOrder == selected {
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
                        
                    } else {
                        
                        let button = self.vm.selectedButton ?? 0
                        self.choiceButtons[button].layer.borderColor = UPlusColor.orange01.cgColor
                        self.answerInfoLabel.isHidden = false
                    }
                }
                self.checkAnswerButton.isUserInteractionEnabled = false
                self.checkAnswerButton.backgroundColor = UPlusColor.gray03

            }.store(in: &bindings)

    }
    
}

extension ChoiceQuizMoreViewController {
    private func createChoiceButtons() {
        guard let mission = self.vm.mission as? ChoiceQuizMission else { return }
        let captions = mission.missionChoiceQuizCaptions
        for i in 0..<captions.count {
            let button = ChoiceMultipleQuizButton()
            button.tag = i
            button.layer.cornerRadius = 10
            button.clipsToBounds = true
            button.backgroundColor = .white
            button.layer.borderWidth = 2.0
            button.layer.borderColor = UIColor.clear.cgColor
            button.frame.size.height = 48.0
            button.setQuizTitle(text: captions[i])
            self.choiceButtons.append(button)
        }
        self.vm.buttonStatus = Array(repeating: false, count: captions.count)
    }
}

//MARK: - Set UI & Layout
extension ChoiceQuizMoreViewController {
    private func setUI() {
        for i in 0..<self.choiceButtons.count {
            self.buttonStack.addArrangedSubview(self.choiceButtons[i])
        }
        self.quizContainer.addSubview(self.buttonStack)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
//            self.buttonStack.topAnchor.constraint(equalToSystemSpacingBelow: self.quizContainer.topAnchor, multiplier: 5),
            self.buttonStack.leadingAnchor.constraint(equalToSystemSpacingAfter: self.quizContainer.leadingAnchor, multiplier: 2),
            self.quizContainer.trailingAnchor.constraint(equalToSystemSpacingAfter: self.buttonStack.trailingAnchor, multiplier: 2),
//            self.quizContainer.bottomAnchor.constraint(equalToSystemSpacingBelow: self.buttonStack.bottomAnchor, multiplier: 5),
            self.buttonStack.centerYAnchor.constraint(equalTo: self.quizContainer.centerYAnchor)
        ])
    }
}

extension ChoiceQuizMoreViewController: BaseMissionCompletedViewControllerDelegate {
    func redeemDidTap() {
        self.delegate?.redeemDidTap(vc: self)
    }
}
