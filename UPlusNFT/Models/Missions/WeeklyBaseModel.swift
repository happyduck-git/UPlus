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
        let level = UserDefaults.standard.value(forKey: UserDefaultsConstants.level) as? Int
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
                state: .successed
            )
    }

    func checkMissionCompletion() async throws {
        self.weeklyMissionCompletion = try await self.firestoreManager.checkWeeklyMissionSetCompletion(week: self.numberOfWeek)
    }
    
}

