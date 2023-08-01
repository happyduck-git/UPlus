//
//  RoutineSelectBottomSheetViewController.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/01.
//

import UIKit
import FirebaseFirestore

final class RoutineSelectBottomSheetViewController: BottomSheetViewController {
    
    private let vm: MyPageViewViewModel
    
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
        label.text = "루틴 선택하기"
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
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let topButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: UPlusFont.head5, weight: .bold)
        return button
    }()
    
    private let midButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: UPlusFont.head5, weight: .bold)
        return button
    }()
    
    private let bottomButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: UPlusFont.head5, weight: .bold)
        return button
    }()
    
    private let retrieveRewardButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.white, for: .normal)
        button.setTitle("리워드 NFT 받기", for: .normal)
        button.backgroundColor = .black
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
    }

}

// MARK: - Set UI & Layout
extension RoutineSelectBottomSheetViewController {
    func configure() {
        let keys = Array(self.vm.dailyMissions.keys)
        print("Keys: \(keys)")
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
                                       self.retrieveRewardButton)
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
            self.buttonStack.bottomAnchor.constraint(equalTo: self.retrieveRewardButton.topAnchor),
            
            self.retrieveRewardButton.heightAnchor.constraint(equalToConstant: 50),
            self.retrieveRewardButton.leadingAnchor.constraint(equalTo: self.titleLabel.leadingAnchor),
            self.retrieveRewardButton.trailingAnchor.constraint(equalTo: self.titleLabel.trailingAnchor),
            self.containerView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.retrieveRewardButton.bottomAnchor, multiplier: 3)
        ])
    }
}
