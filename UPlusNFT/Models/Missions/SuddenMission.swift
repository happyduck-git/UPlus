//
//  SuddenMission.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/20.
//

import Foundation
import FirebaseFirestore

struct SuddenMission: Codable {
    let missionIndex: Int64
    let missionTopicType: String
    let missionFormatType: String
    let missionContentTitle: String?
    let missionContentText: String?
    let missionContentImagePath: [String]?
    let missionCreationTime: Timestamp
    let missionBeginTime: Timestamp?
    let missionEndTime: Timestamp?
    let missionRewardPoint: Int64
    let missionAnswerQuizCaption: String?
    let missionAnswerQuizRightAnswer: Int64
}