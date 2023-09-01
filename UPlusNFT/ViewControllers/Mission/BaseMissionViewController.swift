//
//  BaseMissionViewController.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/08/10.
//

import UIKit

protocol BaseMissionViewControllerDelegate: AnyObject {
    func redeemDidTap(vc: BaseMissionViewController)
}

class BaseMissionViewController: UIViewController {

    weak var delegate: BaseMissionViewControllerDelegate?
    
    // MARK: - UI Elements
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: ImageAssets.eventBackground)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = MissionConstants.quizMission
        label.textColor = .systemGray
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: UPlusFont.h1, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let quizLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: UPlusFont.head4, weight: .bold)
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
        label.font = .systemFont(ofSize: UPlusFont.caption1, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var checkAnswerButton: UIButton = {
        let button = UIButton()
        button.setTitle(MissionConstants.checkAnswer, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: UPlusFont.body1, weight: .bold)
        button.backgroundColor = .systemGray
        button.clipsToBounds = true
        button.layer.cornerRadius = 8.0
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
        self.view.addSubviews(self.backgroundImageView,
                              self.titleLabel,
                              self.quizLabel,
                              self.quizContainer,
                              self.answerInfoLabel,
                              self.checkAnswerButton)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.backgroundImageView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.backgroundImageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.backgroundImageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.backgroundImageView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
            self.titleLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.view.safeAreaLayoutGuide.topAnchor, multiplier: 1),
            self.titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.view.safeAreaLayoutGuide.leadingAnchor, multiplier: 1),
            self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: self.titleLabel.trailingAnchor, multiplier: 1),
            
            self.quizLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.titleLabel.bottomAnchor, multiplier: 3),
            self.quizLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.view.safeAreaLayoutGuide.leadingAnchor, multiplier: 1),
            self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: self.quizLabel.trailingAnchor, multiplier: 1),
            
            self.quizContainer.topAnchor.constraint(equalToSystemSpacingBelow: self.quizLabel.bottomAnchor, multiplier: 1),
            self.quizContainer.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            self.quizContainer.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            
            self.answerInfoLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.quizContainer.bottomAnchor, multiplier: 3),
            self.answerInfoLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.view.safeAreaLayoutGuide.leadingAnchor, multiplier: 7),
            self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: self.answerInfoLabel.trailingAnchor, multiplier: 7),
            
            self.checkAnswerButton.topAnchor.constraint(equalToSystemSpacingBelow: self.answerInfoLabel.bottomAnchor, multiplier: 2),
            self.checkAnswerButton.leadingAnchor.constraint(equalToSystemSpacingAfter: self.view.safeAreaLayoutGuide.leadingAnchor, multiplier: 5),
            self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: self.checkAnswerButton.trailingAnchor, multiplier: 5),
            self.checkAnswerButton.heightAnchor.constraint(equalToConstant: LoginConstants.buttonHeight),
            self.checkAnswerButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
            
        ])
        
        self.titleLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        self.quizLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
//        self.answerInfoLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }

}
