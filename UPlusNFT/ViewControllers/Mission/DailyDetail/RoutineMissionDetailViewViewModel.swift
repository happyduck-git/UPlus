//
//  RoutineMissionDetailViewViewModel.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/28.
//

import UIKit.UIImage
import Combine
import OSLog

protocol RoutineMissionDetailViewViewModelDelegate: AnyObject {
    func didRecieveMission()
}

final class RoutineMissionDetailViewViewModel {
    
    // MARK: - Dependency
    private let firestoreManager = FirestoreManager.shared
    private let nftServiceManager = NFTServiceManager.shared
 
    //MARK: - Delegate
    weak var delegate: RoutineMissionDetailViewViewModelDelegate?
    
    // MARK: - DataSource
    var missionType: MissionType
    @Published var selectedImage: UIImage?
    
    /* Routine Mission */
    @Published var daysLeft: String = ""
    @Published var goodWorkerMissions: [GoodWorkerMission] = [] {
        didSet {
            self.successedMissionsCount = goodWorkerMissions.count
        }
    }
    @Published var isFinishedRoutines: Bool?
    @Published var successedMissionsCount: Int = 0
    
    // MARK: - Init
    init(missionType: MissionType) {
        self.missionType = missionType
    }
    
}

// MARK: - NFT Service
extension RoutineMissionDetailViewViewModel {
    
    func checkLevelUpdate(mission: any Mission) async throws {
        do {
            try await UserLevelPoint.userLevelUpdate(mission: mission,
                                                     nftType: .avatar,
                                                     firestoreManager: self.firestoreManager,
                                                     nftServiceManager: self.nftServiceManager)
        }
        catch {
            UPlusLogger.logger.error("Error updating user level -- \(String(describing: error))")
        }
       
    }

}

// MARK: - Firestore
extension RoutineMissionDetailViewViewModel {
    
    func getGoodWorkerMissions() {
        Task {
            do {
                let user = try UPlusUser.getCurrentUser()

                let (daysLeft, missions) = try await self.firestoreManager.getRoutineMissionInfo(missionType: .dailyExpGoodWorker, userIndex: user.userIndex)
                self.daysLeft = daysLeft
                self.goodWorkerMissions = missions
                
                if missions.count >= MissionConstants.routineMissionLimit {
                    
                    self.isFinishedRoutines = true
                    //TODO: isFinishedRoutines bind하여 true인 경우 참여 버튼 비활성화.
                } else {
                    self.isFinishedRoutines = false
                }
                
                self.delegate?.didRecieveMission()
            }
            catch {
                UPlusLogger.logger.error("Error fetching athelete missions -- \(String(describing: error))")
            }
        }
    }
    
    func getTodayMissionInfo() async throws -> any Mission {
            return try await self.firestoreManager.getTodayMission(missionType: self.missionType)
    }
    
    func saveRoutineParticipationStatus(point: Int64) async throws {
        guard let imageData = self.selectedImage?.jpegData(compressionQuality: 0.75) else {
            return
        }
        try await self.firestoreManager.saveParticipatedDailyMission(
            missionType: self.missionType,
            point: point,
            image: imageData
        )
    }
}
