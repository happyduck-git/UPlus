//
//  DailyMissionCompleteViewController.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/31.
//

import UIKit
import Combine

protocol DailyMissionCompleteViewControllerDelegate: AnyObject {
    func confirmButtonDidTap()
}

final class DailyMissionCompleteViewController: UIViewController {
    
    // MARK: - Dependency
    private let vm: DailyRoutineMissionDetailViewViewModel
    private let firestoreManager = FirestoreManager.shared
    
    //MARK: - Delegate
    weak var delegate: DailyMissionCompleteViewControllerDelegate?
     
    // MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    // MARK: - UI Elements
    private let resultLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 40, weight: .bold)
        let attributedString = NSMutableAttributedString(string: MissionConstants.missionComplete)
        attributedString.addAttributes([.font: UIFont.systemFont(ofSize: 82)], range: NSRange(location: 6, length: 2))
        label.attributedText = attributedString
        label.textAlignment = .center
        label.textColor = .black
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let missionCompleteIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .darkGray
        imageView.transform = CGAffineTransform(rotationAngle: .pi / 4)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let pointLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var confirmButton: UIButton = {
        let button = UIButton()
        button.setTitle(MissionConstants.confirm, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Init
    init(vm: DailyRoutineMissionDetailViewViewModel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
        self.configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.setUI()
        self.setLayout()
        self.setNavigationBar()
        self.bind()
    }
    
}

extension DailyMissionCompleteViewController {
    private func bind() {
        self.confirmButton.tapPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let `self` = self else { return }
                
                Task {
                    do {
                        
                        // 1. user 참여 document array item append
                    
                        // 2. mission 내 mission_user_state_map에 저장
                        
                        // 3. Notify delegate and back to DailyRoutineMissionDetailVC
                        self.delegate?.confirmButtonDidTap()
                        guard let vcs = self.navigationController?.viewControllers else { return }
                        for vc in vcs where vc is DailyRoutineMissionDetailViewController {
                            self.navigationController?.popToViewController(vc, animated: true)
                        }
                    }
                    catch {
                        print("")
                    }
                }
            }
            .store(in: &bindings)
    }
}

// MARK: - Configure with View Model
extension DailyMissionCompleteViewController {
    private func configure() {
        self.pointLabel.text = "10" + MissionConstants.pointUnit
    }
}

// MARK: - Set UI & Layout
extension DailyMissionCompleteViewController {
    private func setUI() {
        self.view.addSubviews(resultLabel,
                              missionCompleteIcon,
                              pointLabel,
                              confirmButton)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.resultLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.view.safeAreaLayoutGuide.topAnchor, multiplier: 3),
            self.resultLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.missionCompleteIcon.topAnchor.constraint(equalToSystemSpacingBelow: self.resultLabel.bottomAnchor, multiplier: 5),
            self.missionCompleteIcon.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.missionCompleteIcon.heightAnchor.constraint(equalToConstant: 100),
            self.missionCompleteIcon.widthAnchor.constraint(equalTo: self.missionCompleteIcon.heightAnchor),
            self.pointLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.missionCompleteIcon.bottomAnchor, multiplier: 3),
            self.pointLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            
            self.confirmButton.leadingAnchor.constraint(equalToSystemSpacingAfter: self.view.safeAreaLayoutGuide.leadingAnchor, multiplier: 3),
            self.confirmButton.heightAnchor.constraint(equalToConstant: self.view.frame.height / 15),
            self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: self.confirmButton.trailingAnchor, multiplier: 3),
            self.view.safeAreaLayoutGuide.bottomAnchor.constraint(equalToSystemSpacingBelow: self.confirmButton.bottomAnchor, multiplier: 3)
        ])
    }
    
    private func setNavigationBar() {
        self.navigationItem.hidesBackButton = true
    }
}
