//
//  GoodWorkerMission.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/20.
//

import Foundation
import FirebaseFirestore

struct GoodWorkerMission: Codable, Hashable, Mission {
    var missionId: String
    var missionTopicType: String
    var missionFormatType: String
    var missionContentTitle: String?
    var missionContentText: String?
    var missionContentImagePath: [String]?
    var missionCreationTime: Timestamp
    var missionStartTime: Timestamp
    var missionEndTime: Timestamp?
    var missionRewardPoint: Int64
    var missionSubTopicType: String
    var missionSubFormatType: String
    var missionContentImagePaths: [String]?
    var missionUserStateMap: [String : String]?
    var missionPermitAvatarLevel: Int64
}
