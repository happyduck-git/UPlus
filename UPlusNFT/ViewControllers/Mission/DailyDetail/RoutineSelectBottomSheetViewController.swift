//
//  RoutineSelectBottomSheetViewController.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/01.
//

import UIKit
import FirebaseFirestore
import Combine

protocol RoutineSelectBottomSheetViewControllerDelegate: AnyObject {
    func routineSelected()
}

final class RoutineSelectBottomSheetViewController: BottomSheetViewController {
    
    // MARK: - Dependency
    private let vm: MyPageViewViewModel
    
    // MARK: - Delegate
    weak var delegate: RoutineSelectBottomSheetViewControllerDelegate?
    
    // MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    // MARK: - UI Elements
    private let cancelButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.setImage(UIImage(named: ImageAsset.xMarkBlack), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.text = "루틴 미션 시작하기"
        label.font = .systemFont(ofSize: UPlusFont.head5, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemRed
        label.textAlignment = .center
        label.text = "선택 이후 변경이 불가합니다"
        label.font = .systemFont(ofSize: UPlusFont.subTitle2, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let buttonStack: UIStackView = {
        let stack = UIStackView()
        stack.distribution = .fillEqually
        stack.spacing = 10.0
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let topButton: UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.layer.borderWidth = MissionConstants.buttonBorderWidth
        button.layer.borderColor = UIColor.systemGray.cgColor
        button.titleLabel?.font = .systemFont(ofSize: UPlusFont.head5, weight: .bold)
        return button
    }()
    
    private let midButton: UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.layer.borderWidth = MissionConstants.buttonBorderWidth
        button.layer.borderColor = UIColor.systemGray.cgColor
        button.titleLabel?.font = .systemFont(ofSize: UPlusFont.head5, weight: .bold)
        return button
    }()
    
    private let bottomButton: UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.layer.borderWidth = MissionConstants.buttonBorderWidth
        button.layer.borderColor = UIColor.systemGray.cgColor
        button.titleLabel?.font = .systemFont(ofSize: UPlusFont.head5, weight: .bold)
        return button
    }()
    
    private let selectButton: UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.setTitleColor(.white, for: .normal)
        button.setTitle("선택 완료", for: .normal)
        button.backgroundColor = UPlusColor.greenMint
        button.titleLabel?.font = .systemFont(ofSize: UPlusFont.head5, weight: .bold)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Init
    init(vm: MyPageViewViewModel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUI()
        self.setLayout()
        self.configure()
        
        self.bind()
    }

}

// MARK: - Bind with View Model
extension RoutineSelectBottomSheetViewController {
    private func bind() {
        func bindViewToViewModel() {
            self.topButton.tapPublisher
                .receive(on: DispatchQueue.main)
                .sink {[weak self] _ in
                    guard let `self` = self else { return }
                    self.vm.bottomView.topButton.toggle()
                    self.topButton.layer.borderColor = UPlusColor.greenMint.cgColor
                    self.midButton.layer.borderColor = UIColor.systemGray.cgColor
                    self.bottomButton.layer.borderColor = UIColor.systemGray.cgColor
                }
                .store(in: &bindings)
            
            self.midButton.tapPublisher
                .receive(on: DispatchQueue.main)
                .sink {[weak self] _ in
                    guard let `self` = self else { return }
                    self.vm.bottomView.midButton.toggle()
                    self.topButton.layer.borderColor = UIColor.systemGray.cgColor
                    self.midButton.layer.borderColor = UPlusColor.greenMint.cgColor
                    self.bottomButton.layer.borderColor = UIColor.systemGray.cgColor
                }
                .store(in: &bindings)
            
            self.bottomButton.tapPublisher
                .receive(on: DispatchQueue.main)
                .sink {[weak self] _ in
                    guard let `self` = self else { return }
                    self.vm.bottomView.bottomButton.toggle()
                    self.topButton.layer.borderColor = UIColor.systemGray.cgColor
                    self.midButton.layer.borderColor = UIColor.systemGray.cgColor
                    self.bottomButton.layer.borderColor = UPlusColor.greenMint.cgColor
                }
                .store(in: &bindings)
            
            self.selectButton.tapPublisher
                .receive(on: DispatchQueue.global())
                .sink { [weak self] _ in
                    guard let `self` = self,
                          let selectedMission = self.vm.bottomView.selectedMission
                    else { return }
                    
                    Task {
                        await self.vm.saveSelectedMission(selectedMission)
                        self.dismiss(animated: true)
                        self.delegate?.routineSelected()
                    }
                    
                }
                .store(in: &bindings)
        }
        func bindViewModelToView() {
            let keys = Array(self.vm.mission.dailyMissions.keys)
    
            self.vm.bottomView.$topButton
                .receive(on: DispatchQueue.main)
                .removeDuplicates()
                .sink { [weak self] in
                    guard let `self` = self else { return }
                    if $0 {
                        self.vm.bottomView.midButton = !$0
                        self.vm.bottomView.bottomButton = !$0
                        self.vm.bottomView.selectedMission = MissionType(rawValue: keys[0].replacingOccurrences(of: "__mission_set", with: ""))
                    }
                }
                .store(in: &bindings)
            
            self.vm.bottomView.$midButton
                .receive(on: DispatchQueue.main)
                .removeDuplicates()
                .sink { [weak self] in
                    guard let `self` = self else { return }
                    if $0 {
                        self.vm.bottomView.topButton = !$0
                        self.vm.bottomView.bottomButton = !$0
                        self.vm.bottomView.selectedMission = MissionType(rawValue: keys[1].replacingOccurrences(of: "__mission_set", with: ""))
                    }
                }
                .store(in: &bindings)
            
            self.vm.bottomView.$bottomButton
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    guard let `self` = self else { return }
                    if $0 {
                        self.vm.bottomView.topButton = !$0
                        self.vm.bottomView.midButton = !$0
                        self.vm.bottomView.selectedMission = MissionType(rawValue: keys[2].replacingOccurrences(of: "__mission_set", with: ""))
                    }
                }
                .store(in: &bindings)
        }
        
        bindViewToViewModel()
        bindViewModelToView()
    }
    
    private func differingIndices<T: Equatable>(arr1: [T], arr2: [T]) -> [Int] {
        guard arr1.count == arr2.count else {
            fatalError("Arrays must be of the same length.")
        }

        let indices = arr1.enumerated().filter { $0.element != arr2[$0.offset] }.map { $0.offset }
        return indices
    }
}

// MARK: - Set UI & Layout
extension RoutineSelectBottomSheetViewController {
    func configure() {
        let keys = Array(self.vm.mission.dailyMissions.keys)
        self.topButton.setTitle(keys[0], for: .normal)
        self.midButton.setTitle(keys[1], for: .normal)
        self.bottomButton.setTitle(keys[2], for: .normal)
    }
}

// MARK: - Set UI & Layout
extension RoutineSelectBottomSheetViewController {
    private func setUI() {
        self.containerView.addSubviews(self.cancelButton,
                                       self.titleLabel,
                                       self.infoLabel,
                                       self.buttonStack,
                                       self.selectButton)
        self.buttonStack.addArrangedSubviews(self.topButton,
                                             self.midButton,
                                             self.bottomButton)
    }
    
    private func setLayout() {
        let labelHeight = 30.0
        
        NSLayoutConstraint.activate([
            self.cancelButton.topAnchor.constraint(equalToSystemSpacingBelow: self.containerView.topAnchor, multiplier: 2),
            self.containerView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.cancelButton.trailingAnchor, multiplier: 2),
            self.titleLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.cancelButton.bottomAnchor, multiplier: 3),
            self.cancelButton.widthAnchor.constraint(equalToConstant: labelHeight),
            self.cancelButton.heightAnchor.constraint(equalToConstant: labelHeight),
            
            self.titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.containerView.leadingAnchor, multiplier: 2),
            self.containerView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.titleLabel.trailingAnchor, multiplier: 2),
            self.titleLabel.heightAnchor.constraint(equalToConstant: labelHeight),
            self.infoLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.titleLabel.bottomAnchor, multiplier: 1),
            self.infoLabel.leadingAnchor.constraint(equalTo: self.titleLabel.leadingAnchor),
            self.infoLabel.trailingAnchor.constraint(equalTo: self.titleLabel.trailingAnchor),
            self.infoLabel.heightAnchor.constraint(equalToConstant: labelHeight),
            
            self.buttonStack.topAnchor.constraint(equalToSystemSpacingBelow: self.infoLabel.bottomAnchor, multiplier: 1),
            self.buttonStack.leadingAnchor.constraint(equalTo: self.titleLabel.leadingAnchor),
            self.buttonStack.trailingAnchor.constraint(equalTo: self.titleLabel.trailingAnchor),
            self.buttonStack.bottomAnchor.constraint(equalTo: self.selectButton.topAnchor),
            
            self.selectButton.heightAnchor.constraint(equalToConstant: 50),
            self.selectButton.leadingAnchor.constraint(equalTo: self.titleLabel.leadingAnchor),
            self.selectButton.trailingAnchor.constraint(equalTo: self.titleLabel.trailingAnchor),
            self.containerView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.selectButton.bottomAnchor, multiplier: 3)
        ])
    }
}
