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
        
        guard let missionFormatType = MissionFormatType(rawValue: self.mission.missionFormatType),
        let missionType = MissionType(rawValue: self.mission.missionTopicType)
        else {
            return
        }
        
        try await self.firestoreManager
            .saveParticipatedEventMission(
                formatType: missionFormatType,
                missionType: missionType,
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
