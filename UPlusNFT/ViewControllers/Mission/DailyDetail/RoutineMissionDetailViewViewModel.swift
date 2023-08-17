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
    
    // MARK: - Logger
    private let logger = Logger()
    
    //MARK: - Delegate
    weak var delegate: RoutineMissionDetailViewViewModelDelegate?
    
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
        let level = UserDefaults.value(forKey: UserDefaultsConstants.level) as? Int
        let user = try UPlusUser.getCurrentUser()
        
        let totalPoints = user.userTotalPoint ?? mission.missionRewardPoint
        
        let result = UserLevelPoint.checkLevelUpdate(
            currentLevel: level ?? UserLevelPoint.level(forPoints: totalPoints),
            newPoints: totalPoints
        )
        
        if result.update {
            let requestResult = try await nftServiceManager.requestSingleNft(userIndex: user.userIndex,
                                                                             nftType: .avatar,
                                                                             level: result.newLevel)
            self.logger.info("There is level update from \(String(describing: level)) to \(String(describing: result.newLevel)).")
        } else {
            self.logger.info("There is no level update.")
        }
    }

}

// MARK: - Firestore
extension RoutineMissionDetailViewViewModel {
    
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
                } else {
                    self.isFinishedRoutines = false
                }
                
                self.delegate?.didRecieveMission()
            }
            catch {
                self.logger.error("Error fetching athelete missions -- \(String(describing: error))")
            }
        }
    }
    
    func getTodayMissionInfo() async throws -> any Mission {
            return try await self.firestoreManager.getTodayMission(missionType: self.missionType)
    }
    
    func saveRoutineParticipationStatus() async throws {
        guard let imageData = self.selectedImage?.jpegData(compressionQuality: 0.75) else {
            return
        }
        try await self.firestoreManager.saveParticipatedDailyMission(
            missionType: self.missionType,
            image: imageData
        )
    }
}
