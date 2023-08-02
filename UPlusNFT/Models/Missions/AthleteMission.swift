//
//  AthleteMission.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/20.
//

import Foundation
import FirebaseFirestore

struct AthleteMission: Codable, Mission, DailyMission {
    var missionId: String
    var missionTopicType: String
    var missionSubTopicType: String
    var missionFormatType: String
    var missionContentTitle: String?
    var missionContentText: String?
    var missionContentImagePaths: [String]?
    var missionCreationTime: Timestamp
    var missionBeginTime: Timestamp?
    var missionUserStateMap: [String : String]?
    var missionRewardPoint: Int64
}
