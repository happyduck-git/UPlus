//
//  GovernanceMission.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/07.
//

import Foundation
import FirebaseFirestore

struct GovernanceMission: Mission, Codable {
    var missionId: String
    var missionTopicType: String
    var missionSubTopicType: String
    var missionFormatType: String
    var missionSubFormatType: String
    var missionContentTitle: String?
    var missionContentText: String?
    var missionContentImagePaths: [String]?
    var missionCreationTime: Timestamp
    var missionStartTime: Timestamp
    var missionUserStateMap: [String : String]?
    var missionRewardPoint: Int64
    var missionPermitAvatarLevel: Int64
    
    var governanceElectionCaptions: [String]
    var governanceElectionUserMap: [String: [DocumentReference]]?
}
