//
//  DailyQuizMissionDetailViewController.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/20.
//

import UIKit

class DailyQuizMissionDetailViewController: UIViewController {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = MissionConstants.quizMission
        label.textColor = .systemGray
        label.font = .systemFont(ofSize: UPlusFont.head3, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let quizLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = "무너의 모티브는 오징어이다."
        label.font = .systemFont(ofSize: UPlusFont.head4, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.spacing = 10
        stack.distribution = .fillEqually
        stack.axis = .horizontal
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var circleMarkView: UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(circleMarkDidTap), for: .touchUpInside)
        return button
    }()
    
    private let xMarkView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private let checkAnswerButton: UIButton = {
        let button = UIButton()
        button.setTitle(MissionConstants.checkAnswer, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGray
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .systemGray6
        
        self.setUI()
        self.setLayout()

    }
    
}

extension DailyQuizMissionDetailViewController {
    @objc private func circleMarkDidTap() {
        print("Circle did tap.")
    }
}

extension DailyQuizMissionDetailViewController {
    func configure(with vm: DailyAttendanceMission) {
        self.quizLabel.text = vm.missionContentTitle
    }
}

// MARK: - Set UI & Layout
extension DailyQuizMissionDetailViewController {
    
    private func setUI() {
        self.view.addSubviews(titleLabel,
                              quizLabel,
                              stackView,
                              checkAnswerButton)
        
        self.stackView.addArrangedSubviews(circleMarkView,
                                           xMarkView)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.titleLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.view.safeAreaLayoutGuide.topAnchor, multiplier: 2),
            self.titleLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            
            self.quizLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.titleLabel.bottomAnchor, multiplier: 8),
            self.quizLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            
            self.stackView.topAnchor.constraint(equalToSystemSpacingBelow: self.quizLabel.bottomAnchor, multiplier: 10),
            self.stackView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.view.leadingAnchor, multiplier: 2),
            self.view.trailingAnchor.constraint(equalToSystemSpacingAfter: self.stackView.trailingAnchor, multiplier: 2),
            self.stackView.heightAnchor.constraint(equalToConstant: self.view.frame.height / 5),
            
            self.checkAnswerButton.topAnchor.constraint(equalToSystemSpacingBelow: self.stackView.bottomAnchor, multiplier: 10),
            self.checkAnswerButton.leadingAnchor.constraint(equalTo: self.stackView.leadingAnchor),
            self.checkAnswerButton.trailingAnchor.constraint(equalTo: self.stackView.trailingAnchor),
            self.checkAnswerButton.heightAnchor.constraint(equalToConstant: self.view.frame.height / 12),
            
        ])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        DispatchQueue.main.async {
            self.drawCircleMark()
            self.circleMarkView.layer.cornerRadius = self.circleMarkView.frame.height / 15
            self.xMarkView.layer.cornerRadius = self.xMarkView.frame.height / 15
        }
    }
    
    private func drawCircleMark() {
        let shapeLayer = CAShapeLayer()
        
        let path = UIBezierPath(arcCenter: self.circleMarkView.center,
                                radius: 50,
                                startAngle: 0,
                                endAngle: .pi * 2,
                                clockwise: true)
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = UIColor.black.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 10
        self.circleMarkView.layer.addSublayer(shapeLayer)
    }
    
    private func drawXMark() {
        
    }
    
}
