//
//  DailyRoutineMissionDetailViewViewModel.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/28.
//

import UIKit.UIImage
import Combine

protocol DailyRoutineMissionDetailViewViewModelDelegate: AnyObject {
    func didRecieveMission()
}

final class DailyRoutineMissionDetailViewViewModel {
    
    // MARK: - Dependency
    private let firestoreManager = FirestoreManager.shared
    
    //MARK: - Delegate
    weak var delegate: DailyRoutineMissionDetailViewViewModelDelegate?
    
    // MARK: - DataSource
    var missionType: MissionType
    @Published var selectedImage: UIImage?
    
    /* Routine Mission */
    @Published var daysLeft: String = ""
    @Published var athleteMissions: [AthleteMission] = [] {
        didSet {
            self.successedMissionsCount = athleteMissions.count
        }
    }
    @Published var isFinishedRoutines: Bool = false
    @Published var successedMissionsCount: Int = 0
    
    // MARK: - Init
    init(missionType: MissionType) {
        self.missionType = missionType
    }
    
}

extension DailyRoutineMissionDetailViewViewModel {
    
    func getAtheleteMissions() {
        Task {
            do {
                let user = try UPlusUser.getCurrentUser()

                let (daysLeft, missions) = try await self.firestoreManager.getRoutineMissionInfo(missionType: .dailyExpAthlete, userIndex: user.userIndex)
                self.daysLeft = daysLeft
                self.athleteMissions = missions
                
                if missions.count >= MissionConstants.routineMissionLimit {
                    
                    self.isFinishedRoutines = true
                    //TODO: isFinishedRoutines bind하여 true인 경우 참여 버튼 비활성화.
                }
                
                self.delegate?.didRecieveMission()
            }
            catch {
                print("Error fetching athelete missions -- \(error)")
            }
        }
    }
    
}
