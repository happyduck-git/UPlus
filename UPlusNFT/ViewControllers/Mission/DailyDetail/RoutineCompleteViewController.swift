//
//  DailyMissionCompleteViewController.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/31.
//

import UIKit
import Combine
import OSLog

protocol RoutineCompleteViewControllerDelegate: AnyObject {
    func cancelButtonDidTap()
}

final class RoutineCompleteViewController: UIViewController {
    
    // MARK: - Logger
    private let logger = Logger()
    
    // MARK: - Dependency
    private let vm: RoutineMissionDetailViewViewModel
    
    //MARK: - Delegate
    weak var delegate: RoutineCompleteViewControllerDelegate?
     
    // MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    // MARK: - UI Elements
    private let certiTitle: UILabel = {
        let label = UILabel()
        label.text = MissionConstants.certificate
        label.textAlignment = .center
        label.textColor = .black
        label.font = .systemFont(ofSize: UPlusFont.h2, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let certificateImage: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .darkGray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let missionTypeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: UPlusFont.caption1, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let slackInfoLabel: UILabel = {
        let label = UILabel()
        label.text = MissionConstants.slackInfo
        label.textColor = UPlusColor.mint04
        label.textAlignment = .center
        label.font = .systemFont(ofSize: UPlusFont.body2, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var shareOnSlackButton: UIButton = {
        let button = UIButton()
        button.setTitle(MissionConstants.shareOnSlack, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Init
    init(vm: RoutineMissionDetailViewViewModel) {
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
        
        self.title = MissionConstants.missionCompleted
        self.view.backgroundColor = .white
        self.setUI()
        self.setLayout()
        self.setNavigationBar()
        self.bind()
    }
    
}

extension RoutineCompleteViewController {
    private func bind() {
        
        self.shareOnSlackButton.tapPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let `self` = self else { return }
                
                Task {
                    // Open Slack
                    if await self.shareOnSlack() {
                        // TODO: Slack 링크 공유 후 UPlus 앱 재진입 시 로직 추가.
                        
                        
                    } else {

                        let action = UIAlertAction(title: AlertConstants.confirm,
                                                   style: .cancel)
                        let alert = UIAlertController(title: AlertConstants.slackShareFail,
                                                      message: AlertConstants.retryMessage,
                                                      preferredStyle: .alert)
                        alert.addAction(action)
                        self.show(alert, sender: self)
                    }

                }
                
            }
            .store(in: &bindings)
        
    }
}

// MARK: - Configure with View Model
extension RoutineCompleteViewController {
    private func configure() {
        self.missionTypeLabel.text = "받은 경로: " + self.vm.missionType.rawValue
    }
}

// MARK: - Set UI & Layout
extension RoutineCompleteViewController {
    private func setUI() {
        self.view.addSubviews(self.certiTitle,
                              self.certificateImage,
                              self.missionTypeLabel,
                              self.slackInfoLabel,
                              self.shareOnSlackButton)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            self.certiTitle.topAnchor.constraint(equalToSystemSpacingBelow: self.view.safeAreaLayoutGuide.topAnchor, multiplier: 3),
            self.certiTitle.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.certificateImage.topAnchor.constraint(equalToSystemSpacingBelow: self.certiTitle.bottomAnchor, multiplier: 5),
            self.certificateImage.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.certificateImage.heightAnchor.constraint(equalToConstant: 300),
            self.certificateImage.widthAnchor.constraint(equalTo: self.certificateImage.heightAnchor),
            self.missionTypeLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.certificateImage.bottomAnchor, multiplier: 3),
            self.missionTypeLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            
            self.slackInfoLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.view.leadingAnchor, multiplier: 3),
            self.view.trailingAnchor.constraint(equalToSystemSpacingAfter: self.slackInfoLabel.trailingAnchor, multiplier: 3),
            
            self.shareOnSlackButton.topAnchor.constraint(equalToSystemSpacingBelow: self.slackInfoLabel.bottomAnchor, multiplier: 2),
            self.shareOnSlackButton.leadingAnchor.constraint(equalToSystemSpacingAfter: self.view.safeAreaLayoutGuide.leadingAnchor, multiplier: 3),
            self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: self.shareOnSlackButton.trailingAnchor, multiplier: 3),
            self.view.safeAreaLayoutGuide.bottomAnchor.constraint(equalToSystemSpacingBelow: self.shareOnSlackButton.bottomAnchor, multiplier: 3)
        ])
        
        self.certiTitle.setContentHuggingPriority(.defaultHigh, for: .vertical)
        self.slackInfoLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        self.shareOnSlackButton.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
    
    private func setNavigationBar() {
        self.navigationItem.hidesBackButton = true
        
        let cancelButton = UIBarButtonItem(image: UIImage(named: ImageAsset.xMarkBlack), style: .done, target: self, action: #selector(cancelDidTap))
        self.navigationItem.setRightBarButtonItems([cancelButton], animated: true)
    }
    
    @objc private func cancelDidTap() {
        //1. notify delegate -> 보상 수령 완료
        self.delegate?.cancelButtonDidTap()
        //2. dismiss vc
        self.dismiss(animated: true)
    }
}

extension RoutineCompleteViewController {
    
    private func shareOnSlack() async -> Bool {
        let urlString = MissionConstants.slackScheme
        guard let url = URL(string: urlString) else {
            self.logger.error("Wrong URL")
            return false
        }
        
        return await UIApplication.shared.open(url)
    }
    
}
