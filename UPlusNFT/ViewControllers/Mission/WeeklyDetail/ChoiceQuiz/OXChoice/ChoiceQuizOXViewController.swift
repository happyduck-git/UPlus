//
//  ChoiceQuizOXViewController.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/20.
//

import UIKit
import Combine

final class ChoiceQuizOXViewController: BaseMissionViewController {
    
    // MARK: - Dependency
    private let vm: ChoiceQuizzOXViewViewModel
    
    // MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    // MARK: - UI Elements
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.spacing = 10
        stack.distribution = .fillEqually
        stack.axis = .horizontal
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var circleMarkButton: UIButton = {
        let button = UIButton()
        button.tag = 0
        button.clipsToBounds = true
        button.setTitleColor(UPlusColor.mint03, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 90, weight: .bold)
        button.backgroundColor = .white
        return button
    }()
    
    private lazy var xMarkButton: UIButton = {
        let button = UIButton()
        button.tag = 1
        button.clipsToBounds = true
        button.setTitleColor(UPlusColor.orange01, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 90, weight: .bold)
        button.backgroundColor = .white
        return button
    }()

    // MARK: - Init
    init(vm: ChoiceQuizzOXViewViewModel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
        self.setBaseVM(vm: vm)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .systemGray6
        
        self.setUI()
        self.setLayout()
        self.configure()
        self.bind()

    }
    
}

// MARK: - Bind
extension ChoiceQuizOXViewController {

    private func bind() {
        func bindViewToViewModel() {
            self.circleMarkButton.tapPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    guard let `self` = self else { return }
                    
                    if !self.vm.circleButtonDidTap {
                        self.answerInfoLabel.isHidden = true
                        self.vm.circleButtonDidTap = !self.vm.circleButtonDidTap
                        self.vm.xButtonDidTap = !self.vm.circleButtonDidTap
                        self.vm.selectedAnswer = Int64(self.circleMarkButton.tag)
                        self.checkAnswerButton.isUserInteractionEnabled = true
                        self.checkAnswerButton.backgroundColor = .black
                    }
                   
                }
                .store(in: &bindings)
            
            self.xMarkButton.tapPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    guard let `self` = self else { return }
                    
                    if !self.vm.xButtonDidTap {
                        self.answerInfoLabel.isHidden = true
                        self.vm.xButtonDidTap = !self.vm.xButtonDidTap
                        self.vm.circleButtonDidTap = !self.vm.xButtonDidTap
                        self.vm.selectedAnswer = Int64(self.xMarkButton.tag)
                        self.checkAnswerButton.isUserInteractionEnabled = true
                        self.checkAnswerButton.backgroundColor = .black
                    }
                    
                }
                .store(in: &bindings)
            
            self.checkAnswerButton.tapPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    guard let `self` = self else { return }
                    
                    if checkUserAnswer() {
                        print("Right answer submitted.")
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
                        navigationController?.modalPresentationStyle = .fullScreen
                        self.show(vc, sender: self)
                    } else {
                        print("Wrong answer submitted.")
                        self.answerInfoLabel.isHidden = false
                    }
                    
                }
                .store(in: &bindings)
        }
        
        func bindViewModelToView() {
            self.vm.$circleButtonDidTap
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    guard let `self` = self else { return }
                    let color: CGColor = $0 ? UPlusColor.pointGagePink.cgColor : UIColor.clear.cgColor
                    let width: CGFloat = $0 ? 10.0 : 0.0
                    
                    self.circleMarkButton.layer.borderColor = color
                    self.circleMarkButton.layer.borderWidth = width
                }
                .store(in: &bindings)
            
            self.vm.$xButtonDidTap
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    guard let `self` = self else { return }
                    
                    let color: CGColor = $0 ? UPlusColor.pointGagePink.cgColor : UIColor.clear.cgColor
                    let width: CGFloat = $0 ? 10.0 : 0.0
                    self.xMarkButton.layer.borderColor = color
                    self.xMarkButton.layer.borderWidth = width
                }
                .store(in: &bindings)
        }
        
        bindViewToViewModel()
        bindViewModelToView()
    }
    
}

// MARK: - Private
extension ChoiceQuizOXViewController {

    private func checkUserAnswer() -> Bool {
        let dataSource = self.vm.mission as! ChoiceQuizMission
        
        return dataSource.missionChoiceQuizRightOrder == self.vm.selectedAnswer ? true : false
    }
    
}

extension ChoiceQuizOXViewController {
    private func configure() {
        self.titleLabel.text = self.vm.mission.missionContentTitle
        
        let dataSource = self.vm.mission as! ChoiceQuizMission
        self.circleMarkButton.setTitle(dataSource.missionChoiceQuizCaptions[0], for: .normal)
        self.xMarkButton.setTitle(dataSource.missionChoiceQuizCaptions[1], for: .normal)
        
    }
}

// MARK: - Set UI & Layout
extension ChoiceQuizOXViewController {
    
    private func setUI() {
        self.quizContainer.addSubviews(self.stackView)
        
        self.stackView.addArrangedSubviews(self.circleMarkButton,
                                           self.xMarkButton)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.stackView.topAnchor.constraint(equalToSystemSpacingBelow: self.quizContainer.topAnchor, multiplier: 5),
            self.stackView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.quizContainer.leadingAnchor, multiplier: 2),
            self.quizContainer.trailingAnchor.constraint(equalToSystemSpacingAfter: self.stackView.trailingAnchor, multiplier: 2),
            self.quizContainer.bottomAnchor.constraint(equalToSystemSpacingBelow: self.stackView.bottomAnchor, multiplier: 5)
        ])
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        DispatchQueue.main.async {
            self.circleMarkButton.layer.cornerRadius = self.circleMarkButton.frame.height / 15
            self.xMarkButton.layer.cornerRadius = self.xMarkButton.frame.height / 15
        }
    }
    
}

extension ChoiceQuizOXViewController: BaseMissionCompletedViewControllerDelegate {
    func redeemDidTap() {
        self.delegate?.redeemDidTap(vc: self)
    }
}

