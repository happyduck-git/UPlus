//
//  BaseMissionViewController.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/08/10.
//

import UIKit

class BaseMissionViewController: UIViewController {

    // MARK: - UI Elements
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = MissionConstants.quizMission
        label.textColor = .systemGray
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: UPlusFont.h1, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let quizLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: UPlusFont.head4, weight: .bold)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let quizContainer: UIView = {
       let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let answerInfoLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.clipsToBounds = true
        label.layer.cornerRadius = 5.0
        label.text = MissionConstants.reselect
        label.textAlignment = .center
        label.textColor = UPlusColor.orange01
        label.backgroundColor = UPlusColor.orange02
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var checkAnswerButton: UIButton = {
        let button = UIButton()
        button.setTitle(MissionConstants.checkAnswer, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGray
        button.isUserInteractionEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UPlusColor.grayBackground
        self.setUI()
        self.setLayout()

    }

}

//MARK: - Set UI & Layout
extension BaseMissionViewController {
    private func setUI() {
        self.view.addSubviews(self.titleLabel,
                              self.quizLabel,
                              self.quizContainer,
                              self.answerInfoLabel,
                              self.checkAnswerButton)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.titleLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.view.safeAreaLayoutGuide.topAnchor, multiplier: 3),
            self.titleLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            
            self.quizLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.titleLabel.bottomAnchor, multiplier: 3),
            self.quizLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            
            self.quizContainer.topAnchor.constraint(equalToSystemSpacingBelow: self.quizLabel.bottomAnchor, multiplier: 1),
            self.quizContainer.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            self.quizContainer.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            
            self.answerInfoLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.quizContainer.bottomAnchor, multiplier: 3),
            self.answerInfoLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.view.safeAreaLayoutGuide.leadingAnchor, multiplier: 5),
            self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: self.answerInfoLabel.trailingAnchor, multiplier: 5),
            
            self.checkAnswerButton.topAnchor.constraint(equalToSystemSpacingBelow: self.answerInfoLabel.bottomAnchor, multiplier: 2),
            self.checkAnswerButton.leadingAnchor.constraint(equalToSystemSpacingAfter: self.view.safeAreaLayoutGuide.leadingAnchor, multiplier: 5),
            self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: self.checkAnswerButton.trailingAnchor, multiplier: 5),
            self.checkAnswerButton.heightAnchor.constraint(equalToConstant: self.view.frame.height / 12),
            self.checkAnswerButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
            
        ])
        self.titleLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        self.quizLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        self.answerInfoLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        self.checkAnswerButton.setContentHuggingPriority(.defaultHigh, for: .vertical)
//        self.quizContainer.setContentHuggingPriority(.defaultLow, for: .vertical)
    }

}
