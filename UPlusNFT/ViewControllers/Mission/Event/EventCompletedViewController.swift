//
//  EventCompletedViewController.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/17.
//

import UIKit
import Combine
import OSLog

final class EventCompletedViewController: BaseMissionCompletedViewController {

    // MARK: - Logger
    private let logger = Logger()
    
    // MARK: - Dependency
    let vm: MissionBaseModel
    
    // MARK: - Combine
    private var bindings = Set<AnyCancellable>()
    
    
    // MARK: - Init
    init(vm: MissionBaseModel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.bind()
        self.view.backgroundColor = .white
        self.resultLabel.text = MissionConstants.eventCompleted
        self.confirmButton.setTitle(String(format: MissionConstants.redeemPoint, self.vm.mission.missionRewardPoint), for: .normal)
    }

}

extension EventCompletedViewController {
    
    private func bind() {
        
        self.confirmButton.tapPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let `self` = self else { return }
                
                self.addChildViewController(self.loadingVC)
                
                // switch type
                let mission = self.vm.mission
                guard let subFormatType = MissionSubFormatType(rawValue: mission.missionSubFormatType) else { return }
                
                switch subFormatType {
                    
                case .choiceQuizOX,
                        .choiceQuizMore,
                        .contentReadOnly,
                        .shareMediaOnSlack,
                        .choiceQuizVideo,
                        .photoAuthManagement,
                        .photoAuthNoManagement:

                    Task {
                        do {
                            try await self.vm.saveEventParticipationStatus(selectedIndex: nil,
                                                                           recentComments: nil,
                                                                           comment: nil)
                        }
                        catch {
                            self.logger.error("Error saving event participation -- \(String(describing: error))")
                        }
                    }
                    
                    
                    break
         
                case .governanceElection:
                    guard let vm = self.vm as? GovernanceElectionMissionViewViewModel else { return }
                    
                    Task {
                        do {
                            try await self.vm.saveEventParticipationStatus(selectedIndex: vm.selectedButton,
                                                                           recentComments: nil,
                                                                           comment: nil)
                        }
                        catch {
                            self.logger.error("Error saving event participation -- \(String(describing: error))")
                        }
                    }
                    
                
                case .userComment:
                    guard let vm = self.vm as? CommentCountMissionViewViewModel,
                          let mission = self.vm.mission as? CommentCountMission
                    else { return }
                    
                    Task {
                        do {
                            try await self.vm.saveEventParticipationStatus(selectedIndex: nil,
                                                                           recentComments: mission.commentUserRecents,
                                                                           comment: vm.comment)
                        }
                        catch {
                            self.logger.error("Error saving event participation -- \(String(describing: error))")
                        }
                    }
                
                default:
                    print("No action defined for this event")
                }
                
                
                Task {
                    do {
                        // Check level update.
                        try await self.vm.checkLevelUpdate()

                        self.delegate?.redeemDidTap()
                        
                        DispatchQueue.main.async {
                            self.loadingVC.removeViewController()
                            
                            guard let vcs = self.navigationController?.viewControllers else { return }
                            for vc in vcs where vc is MyPageViewController {
                                DispatchQueue.main.async {
                                    self.navigationController?.popToViewController(vc, animated: true)
                                }
                            }
                        }
                    }
                    catch {
                        print("Error saving mission and user data -- \(error)")
                    }
                }
            }
            .store(in: &bindings)
    }
    
}
