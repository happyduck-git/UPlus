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
                
                var selectedIndex: Int?
                var recentComments: [String]?
                var comment: String?
                
                switch subFormatType {
                    
                case .choiceQuizOX,
                        .choiceQuizMore,
                        .contentReadOnly,
                        .choiceQuizVideo,
                        .photoAuthManagement,
                        .photoAuthNoManagement:
                    
                    selectedIndex = nil
                    recentComments = nil
                    comment = nil
                    
                case .governanceElection:
                    guard let vm = self.vm as? GovernanceElectionMissionViewViewModel else { return }
                    
                    selectedIndex = vm.selectedButton
                    recentComments = nil
                    comment = nil
                    
                case .shareMediaOnSlack:
                    selectedIndex = nil
                    recentComments = nil
                    comment = comment

                default:
                    print("No action defined for this event")
                }
                  
                Task {
                    do {
                        // Save event participant
                        try await self.vm.saveEventParticipationStatus(selectedIndex: selectedIndex,
                                                                       recentComments: recentComments,
                                                                       comment: comment)
                        
                        
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
