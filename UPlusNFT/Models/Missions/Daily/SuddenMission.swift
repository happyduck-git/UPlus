//
//  SuddenMission.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/20.
//

import Foundation
import FirebaseFirestore

struct SuddenMission: Codable, Hashable {
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
    let missionAnswerQuizCaption: String?
    let missionAnswerQuizRightAnswer: Int64
}
