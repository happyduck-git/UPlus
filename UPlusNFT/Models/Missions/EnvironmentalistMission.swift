//
//  EnvironmentalistMission.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/20.
//

import Foundation
import FirebaseFirestore

struct EnvironmentalistMission: Codable {
    var missionIndex: Int64
    var missionTopicType: String
    var missionFormatType: String
    var missionContentTitle: String?
    var missionContentText: String?
    var missionContentImagePath: [String]?
    var missionCreationTime: Timestamp
    var missionBeginTime: Timestamp?
    var missionEndTime: Timestamp?
    var missionRewardPoint: Int64
}
