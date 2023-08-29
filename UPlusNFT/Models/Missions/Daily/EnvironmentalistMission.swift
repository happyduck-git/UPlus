//
//  EnvironmentalistMission.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/20.
//

import Foundation
import FirebaseFirestore

struct EnvironmentalistMission: Codable, Mission {
    var missionContentExtraMap: [String : String]?
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
    var missionRewardPoint: Int64
    var missionUserStateMap: [String : String]?
    var missionPermitAvatarLevel: Int64
}
