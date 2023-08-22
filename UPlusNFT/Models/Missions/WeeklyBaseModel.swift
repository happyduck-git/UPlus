//
//  MissionBaseModel.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/17.
//

import Foundation
import Combine
import OSLog

class WeeklyBaseModel {
    
    // MARK: - Dependency
    private let firestoreManager = FirestoreManager.shared
    private let nftServiceManager = NFTServiceManager.shared
    
    // MARK: - Logger
    private let logger = Logger()
    
    // MARK: - Data
    let mission: any Mission
    let numberOfWeek: Int
    
    /* WeeklyMission Completion */
    @Published var weeklyMissionCompletion: Bool = false
    
    init(mission: any Mission, numberOfWeek: Int) {
        self.mission = mission
        self.numberOfWeek = numberOfWeek
    }
    
}

// MARK: - NFT Service
extension WeeklyBaseModel {
    
    func checkLevelUpdate() async throws {
        do {
            try await UserLevelPoint.userLevelUpdate(mission: self.mission,
                                                     nftType: .avatar,
                                                     firestoreManager: self.firestoreManager,
                                                     nftServiceManager: self.nftServiceManager)
        }
        catch {
            self.logger.error("Error updating user level -- \(String(describing: error))")
        }
  
    }
    
}

// MARK: - Firestore
extension WeeklyBaseModel {
    func saveWeeklyMissionParticipationStatus() async throws {
        guard let missionType = MissionType(rawValue: self.mission.missionSubTopicType) else {
             return
         }
        
        try await self.firestoreManager
            .saveParticipatedWeeklyMission(
                questionId: self.mission.missionId,
                week: self.numberOfWeek,
                today: Date().yearMonthDateFormat,
                missionType: missionType,
                point: self.mission.missionRewardPoint,
                state: .succeeded
            )
    }

    func checkMissionCompletion() async throws {
        self.weeklyMissionCompletion = try await self.firestoreManager.checkWeeklyMissionSetCompletion(week: self.numberOfWeek)
    }
    
}

