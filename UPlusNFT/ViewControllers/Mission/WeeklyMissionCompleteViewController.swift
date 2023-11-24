//
//  MissionCompleteViewController.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/20.
//

import UIKit
import Combine

enum MissionAnswerState: String {
    case pending
    case succeeded
    case failed
}

protocol WeeklyMissionCompleteViewControllerDelegate: AnyObject {
    func redeemDidTap()
}

final class WeeklyMissionCompleteViewController: BaseMissionCompletedViewController {
    
    // MARK: - Dependency
    private let vm: MissionBaseModel
    
    // MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    // MARK: - Init
    init(vm: MissionBaseModel) {
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
        self.bind()
    }
    
}

extension WeeklyMissionCompleteViewController {
    private func bind() {
        self.confirmButton.tapPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let `self` = self else { return }
                
                self.addChildViewController(self.loadingVC)
                
                Task {
                    do {
                        // Save weekly mission participation.
                        try await self.vm.saveWeeklyMissionParticipationStatus()
                        
                        // Check level update.
                        try await self.vm.checkLevelUpdate()
                      
                        self.delegate?.redeemDidTap()
                        self.loadingVC.removeViewController()
                        
                        DispatchQueue.main.async {
                            guard let vcs = self.navigationController?.viewControllers else { return }
                            for vc in vcs where vc is WeeklyMissionOverViewViewController {
                                self.navigationController?.popToViewController(vc, animated: true)
                            }
                        }
                        
                        // Weekly mission 완료 상태 확인
                        try await self.vm.checkMissionCompletion()
 
                    }
                    catch {
                        print("Error saving mission and user data -- \(error)")
                    }
                }
            }
            .store(in: &bindings)

    }
}

// MARK: - Configure with View Model
extension WeeklyMissionCompleteViewController {
    private func configure() {
        self.confirmButton.setTitle(String(format: MissionConstants.redeemPoint, self.vm.mission.missionRewardPoint), for: .normal)
    }
}


