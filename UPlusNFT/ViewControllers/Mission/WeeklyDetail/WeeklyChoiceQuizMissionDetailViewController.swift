//
//  DailyQuizMissionDetailViewController.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/20.
//

import UIKit
import Combine

final class WeeklyChoiceQuizMissionDetailViewController: UIViewController {
    
    // MARK: - Dependency
    private let vm: WeeklyMissionDetailViewViewModel
    
    // MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    // MARK: - UI Elements
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
    
    private lazy var circleMarkButton: UIButton = {
        let button = UIButton()
        button.tag = 0
        button.clipsToBounds = true
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 90, weight: .bold)
        button.backgroundColor = .white
        return button
    }()
    
    private lazy var xMarkButton: UIButton = {
        let button = UIButton()
        button.tag = 1
        button.clipsToBounds = true
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 90, weight: .bold)
        button.backgroundColor = .white
        return button
    }()
    
    private lazy var checkAnswerButton: UIButton = {
        let button = UIButton()
        button.setTitle(MissionConstants.checkAnswer, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGray
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Init
    init(vm: WeeklyMissionDetailViewViewModel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
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
extension WeeklyChoiceQuizMissionDetailViewController {

    private func bind() {
        func bindViewToViewModel() {
            self.circleMarkButton.tapPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    guard let `self` = self else { return }
                    
                    if !self.vm.circleButtonDidTap {
                        self.vm.circleButtonDidTap = !self.vm.circleButtonDidTap
                        self.vm.xButtonDidTap = !self.vm.circleButtonDidTap
                        self.vm.selectedAnswer = Int64(self.circleMarkButton.tag)
                    }
                   
                }
                .store(in: &bindings)
            
            self.xMarkButton.tapPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    guard let `self` = self else { return }
                    
                    if !self.vm.xButtonDidTap {
                        self.vm.xButtonDidTap = !self.vm.xButtonDidTap
                        self.vm.circleButtonDidTap = !self.vm.xButtonDidTap
                        self.vm.selectedAnswer = Int64(self.xMarkButton.tag)
                    }
                    
                }
                .store(in: &bindings)
            
            self.checkAnswerButton.tapPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    guard let `self` = self else { return }
                    
                    if checkUserAnswer() {
                        print("Right answer submitted.")
                        let vc = MissionCompleteViewController(vm: self.vm)
                        navigationController?.modalPresentationStyle = .fullScreen
                        self.show(vc, sender: self)
                    } else {
                        // TODO: 오답인 경우 로직 추가 필요.
                        print("Wrong answer submitted.")
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
extension WeeklyChoiceQuizMissionDetailViewController {

    private func checkUserAnswer() -> Bool {
        return self.vm.dataSource.missionChoiceQuizRightOrder == self.vm.selectedAnswer ? true : false
    }
    
}

extension WeeklyChoiceQuizMissionDetailViewController {
    private func configure() {
        self.quizLabel.text = vm.dataSource.missionContentTitle
        
        self.xMarkButton.setTitle(vm.dataSource.missionChoiceQuizCaptions?[0] ?? "X", for: .normal)
        self.circleMarkButton.setTitle(vm.dataSource.missionChoiceQuizCaptions?[1] ?? "O", for: .normal)
    }
}

// MARK: - Set UI & Layout
extension WeeklyChoiceQuizMissionDetailViewController {
    
    private func setUI() {
        self.view.addSubviews(titleLabel,
                              quizLabel,
                              stackView,
                              checkAnswerButton)
        
        self.stackView.addArrangedSubviews(circleMarkButton,
                                           xMarkButton)
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
            self.circleMarkButton.layer.cornerRadius = self.circleMarkButton.frame.height / 15
            self.xMarkButton.layer.cornerRadius = self.xMarkButton.frame.height / 15
        }
    }
    
}
