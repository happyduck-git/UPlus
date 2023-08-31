//
//  CommentSharingMissionViewController.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/31.
//

import UIKit
import Combine

final class CommentSharingMissionViewController: BaseMissionViewController {
    
    //MARK: - Dependency
    private let vm: CommentSharingMissionViewViewModel
    
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
        label.textColor = UPlusColor.mint04
        label.font = .systemFont(ofSize: UPlusFont.body2, weight: .regular)
        label.text = MissionConstants.pasteUrl
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
 
    //MARK: - Init
    init(vm: CommentSharingMissionViewViewModel) {
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
        self.setDelegate()
        
        self.configure()
        self.bind()
        
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            self.setTextFieldUnderline(color: UPlusColor.gray05)
        }
        
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

    }
}

// MARK: - Set UI & Layout
extension CommentSharingMissionViewController {
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
            self.descriptionLabel.leadingAnchor.constraint(equalTo: self.answerTextField.leadingAnchor)
        ])
    }
    
    private func setDelegate() {
        self.answerTextField.delegate = self
    }
}

// MARK: - Configure & Bind
extension CommentSharingMissionViewController {
  
    private func configure() {
        self.checkAnswerButton.setTitle(MissionConstants.checkAnswer, for: .normal)
    }
    
    private func bind() {
        guard let mission = self.vm.mission as? CommentCountMission
        else { return }
        
        func bindViewToViewModel() {
            
            self.answerTextField.textPublisher
                .removeDuplicates()
                .receive(on: DispatchQueue.main)
                .sink { [weak self] text in
                    guard let `self` = self else { return }
                        self.vm.comment = text
                }
                .store(in: &bindings)
            
            self.checkAnswerButton.tapPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    guard let `self` = self else { return }
                    
                    self.showMissionCompletionVC()
                }
                .store(in: &bindings)
        }
        
        func bindViewModelToView() {

            self.vm.$comment
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    guard let `self` = self,
                    let comment = $0
                    else { return }
                    
                    let commentEmpty = comment.isEmpty
                    let bgColor: UIColor = commentEmpty ? UPlusColor.buttonDeactivated : UPlusColor.buttonActivated
                    let lineColor: UIColor = commentEmpty ? UPlusColor.gray05 : UPlusColor.mint04
                    let txtColor: UIColor = commentEmpty ? .white : UPlusColor.gray08
                    let isActivated: Bool = commentEmpty ? false : true
                    
                    self.checkAnswerButton.backgroundColor = bgColor
                    self.checkAnswerButton.setTitleColor(txtColor, for: .normal)
                    self.checkAnswerButton.isUserInteractionEnabled = isActivated
                    self.setTextFieldUnderline(color: lineColor)
                    
                }
                .store(in: &bindings)
        }
        
        bindViewToViewModel()
        bindViewModelToView()
    }

}

extension CommentSharingMissionViewController {
    private func saveComment(_ comment: String, completion: @escaping () -> ()) {
        
        self.checkAnswerButton.isUserInteractionEnabled = false
        self.checkAnswerButton.backgroundColor = .systemGray
        
        Task {
            // Update to Weekly Missioin Status
            try await self.vm.saveWeeklyMissionParticipationStatus()
            // Check level update.
            try await self.vm.checkLevelUpdate()
            completion()
        }
        
        self.delegate?.redeemDidTap(vc: self)
        
    }
}

extension CommentSharingMissionViewController {
    
    private func showMissionCompletionVC() {
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

// MARK: - Set TextField Underline
extension CommentSharingMissionViewController {
    private func setTextFieldUnderline(color: UIColor) {
        let underline = CALayer()
        underline.frame = CGRect(x: 0, y: self.answerTextField.frame.size.height-1, width: self.answerTextField.frame.width, height: 2)
        underline.backgroundColor = color.cgColor
        self.answerTextField.layer.addSublayer(underline)
    }
}

// MARK: - BaseMissionCompletedViewControllerDelegate
extension CommentSharingMissionViewController: BaseMissionCompletedViewControllerDelegate {
    func redeemDidTap() {
        self.delegate?.redeemDidTap(vc: self)
    }
}

// MARK: - UITextFieldDelegate
extension CommentSharingMissionViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.setTextFieldUnderline(color: UPlusColor.mint04)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if self.answerTextField.text == nil {
            self.setTextFieldUnderline(color: UPlusColor.gray05)
        }
    }
}
