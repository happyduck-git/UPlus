//
//  AnswerQuizSingularViewController.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/08/10.
//

import UIKit
import Combine

//ShortAnswerQuizMission
final class AnswerQuizSingularViewController: BaseMissionViewController {

    //MARK: - Dependency
    private let vm: AnswerQuizSingularViewViewModel
    
    //MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    //MARK: - UI Elements
    private let answerTextField: UITextField = {
        let txtField = UITextField()
        txtField.borderStyle = .none
        txtField.translatesAutoresizingMaskIntoConstraints = false
        return txtField
    }()
    
    private let numberOfTextLabel: UILabel = {
        let label = UILabel()
        label.textColor = UPlusColor.mint05
        label.font = .systemFont(ofSize: UPlusFont.body2)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = UPlusColor.gray04
        label.font = .systemFont(ofSize: UPlusFont.body2)
        label.text = MissionConstants.hintDescription
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //MARK: - Init
    init(vm: AnswerQuizSingularViewViewModel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let underline = CALayer()
        underline.frame = CGRect(x: 0, y: answerTextField.frame.size.height-1, width: answerTextField.frame.width, height: 1)
        underline.backgroundColor = UPlusColor.gray05.cgColor
        answerTextField.layer.addSublayer(underline)
    }
}

extension AnswerQuizSingularViewController {
    private func setUI() {
        self.quizContainer.addSubviews(self.answerTextField,
                                       self.numberOfTextLabel,
                                       self.descriptionLabel)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.answerTextField.centerYAnchor.constraint(equalTo: self.quizContainer.centerYAnchor),
            self.answerTextField.leadingAnchor.constraint(equalToSystemSpacingAfter: self.quizContainer.leadingAnchor, multiplier: 3),
            self.quizContainer.trailingAnchor.constraint(equalToSystemSpacingAfter: self.answerTextField.trailingAnchor, multiplier: 3),
            self.answerTextField.heightAnchor.constraint(equalToConstant: 60),
            
            self.numberOfTextLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.answerTextField.bottomAnchor, multiplier: 1),
            self.numberOfTextLabel.leadingAnchor.constraint(equalTo: self.answerTextField.leadingAnchor),
            
            self.descriptionLabel.topAnchor.constraint(equalTo: self.numberOfTextLabel.topAnchor),
            self.descriptionLabel.trailingAnchor.constraint(equalTo: self.answerTextField.trailingAnchor)
        ])
    }
}

extension AnswerQuizSingularViewController {
    private func configure() {
        guard let mission = self.vm.mission as? ShortAnswerQuizMission,
        let hint = mission.missionAnswerQuizzes.first
        else { return }
        
        self.titleLabel.text = mission.missionContentTitle
        self.quizLabel.text = mission.missionContentText
        self.answerTextField.placeholder = hint
        self.numberOfTextLabel.text = String(format: MissionConstants.numberOfTexts, hint.count)
        
    }
  
    private func bind() {
        guard let mission = self.vm.mission as? ShortAnswerQuizMission,
              let hint = mission.missionAnswerQuizzes.first,
              let answer = mission.missionAnswerQuizzes.last
        else { return }
        
        self.answerTextField.textPublisher
            .removeDuplicates()
            .debounce(for: 0.1, scheduler: RunLoop.main)
            .sink {
                self.answerInfoLabel.isHidden = true
                
                if $0.count == hint.count {
                    self.checkAnswerButton.isUserInteractionEnabled = true
                    self.checkAnswerButton.backgroundColor = .black
                } else {
                    self.checkAnswerButton.isUserInteractionEnabled = false
                    self.checkAnswerButton.backgroundColor = UPlusColor.gray03
                }
            }
            .store(in: &bindings)
        
        self.checkAnswerButton.tapPublisher
            .receive(on: DispatchQueue.main)
            .sink {
                if (self.answerTextField.text ?? "") == answer {
                    
                    let vc = WeeklyMissionCompleteViewController(vm: self.vm)
                    self.show(vc, sender: self)
                    
                } else {
                    self.answerInfoLabel.isHidden = false
                    self.checkAnswerButton.isUserInteractionEnabled = false
                    self.checkAnswerButton.backgroundColor = UPlusColor.gray03
                }
            }
            .store(in: &bindings)
    }
}
