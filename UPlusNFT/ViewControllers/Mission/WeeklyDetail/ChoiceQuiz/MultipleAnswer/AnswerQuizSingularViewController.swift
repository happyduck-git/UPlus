//
//  AnswerQuizSingularViewController.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/08/10.
//

import UIKit
import Combine
import Nuke

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
        label.textColor = UPlusColor.mint04
        label.font = .systemFont(ofSize: UPlusFont.body2, weight: .regular)
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
        self.setBaseVM(vm: vm)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.hideKeyboardWhenTappedAround()
        self.setUI()
        self.setLayout()
        self.configure()
        self.bind()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            
            self.setTextFieldUnderline(color: UPlusColor.gray05)
            
        }
    }
}

// MARK: - Set UI & Layout
extension AnswerQuizSingularViewController {
    private func setUI() {
        self.quizContainer.addSubviews(self.answerTextField,
                                       self.numberOfTextLabel,
                                       self.descriptionLabel)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([            
            self.answerTextField.topAnchor.constraint(equalTo: self.quizContainer.topAnchor),
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

// MARK: - Configure & Bind
extension AnswerQuizSingularViewController {
    private func configure() {
        guard let mission = self.vm.mission as? ShortAnswerQuizMission,
              let hint = mission.missionAnswerQuizzes.first,
              let answer = mission.missionAnswerQuizzes.last
        else { return }
        
        self.answerTextField.placeholder = hint
        self.numberOfTextLabel.text = String(format: MissionConstants.numberOfTexts, answer.count)
        
    }
  
    private func bind() {
        guard let mission = self.vm.mission as? ShortAnswerQuizMission,
              let answer = mission.missionAnswerQuizzes.last
        else { return }
        
        func bindViewToViewModel() {
            self.answerTextField.textPublisher
                .removeDuplicates()
                .debounce(for: 0.1, scheduler: RunLoop.main)
                .sink { [weak self] in
                    guard let `self` = self else { return }
                    
                    self.answerInfoLabel.isHidden = true
                    
                    if $0.count == answer.count {
                        self.checkAnswerButton.isUserInteractionEnabled = true
                        self.checkAnswerButton.setTitleColor(UPlusColor.gray08, for: .normal)
                        self.checkAnswerButton.backgroundColor = UPlusColor.mint03
                        self.setTextFieldUnderline(color: UPlusColor.mint03)
                    } else {
                        self.checkAnswerButton.isUserInteractionEnabled = false
                        self.checkAnswerButton.setTitleColor(.white, for: .normal)
                        self.checkAnswerButton.backgroundColor = UPlusColor.gray03
                        self.setTextFieldUnderline(color: UPlusColor.gray03)
                    }
                }
                .store(in: &bindings)
            
            self.checkAnswerButton.tapPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    guard let `self` = self else { return }
                    
                    if (self.answerTextField.text ?? "") == answer {
                        
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
                        self.answerInfoLabel.isHidden = false
                        self.checkAnswerButton.isUserInteractionEnabled = false
                        self.checkAnswerButton.backgroundColor = UPlusColor.gray03
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

extension AnswerQuizSingularViewController {
    private func setTextFieldUnderline(color: UIColor) {
        let underline = CALayer()
        underline.frame = CGRect(x: 0, y: self.answerTextField.frame.size.height-1, width: self.answerTextField.frame.width, height: 2)
        underline.backgroundColor = color.cgColor
        self.answerTextField.layer.addSublayer(underline)
    }
}

// MARK: - BaseMissionCompletedViewControllerDelegate
extension AnswerQuizSingularViewController: BaseMissionCompletedViewControllerDelegate {
    func redeemDidTap() {
        self.delegate?.redeemDidTap(vc: self)
    }
}
