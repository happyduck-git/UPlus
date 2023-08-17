//
//  EventBaseModel.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/17.
//

import Foundation
import OSLog

class EventBaseModel {
    
    // MARK: - Logger
    private let logger = Logger()
    
    // MARK: - Dependency
    let firestoreManager = FirestoreManager.shared
    let nftServiceManager = NFTServiceManager.shared
    
    let mission: any Mission
    
    init(mission: any Mission) {
        self.mission = mission
    }
    
}

extension EventBaseModel {
    
    func saveEventParticipationStatus(selectedIndex: Int?,
                                      recentComments: [String]?,
                                      comment: String?) async throws {
        
        guard let missionFormatType = MissionFormatType(rawValue: self.mission.missionFormatType) else {
             return
         }
        
        try await self.firestoreManager
            .saveParticipatedEventMission(
                type: missionFormatType,
                eventId: self.mission.missionId,
                selectedIndex: selectedIndex,
                recentComments: recentComments ?? [],
                comment: comment,
                point: self.mission.missionRewardPoint
            )

    }
}

extension EventBaseModel {
    
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
