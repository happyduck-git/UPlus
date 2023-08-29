//
//  DailyAttendanceMission.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/20.
//

import Foundation
import FirebaseFirestore

struct WeeklyQuizMission: Codable, Mission {
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
    var missionUserStateMap: [String : String]?
    var missionRewardPoint: Int64
    var missionPermitAvatarLevel: Int64
    
    // 객관식
    let missionChoiceQuizCaptions: [String]?
    let missionChoiceQuizRightOrder: Int64?
    // 주관식
    let missionAnswerQuizCaption: String?
    let missionAnswerQuizRightAnswer: String?
    
}
