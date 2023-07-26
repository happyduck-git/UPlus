//
//  ShortAnswerQuizMission.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/07/26.
//

import Foundation
import FirebaseFirestore

struct ShortAnswerQuizMission: Mission {
    var missionId: String
    
    var missionTopicType: String
    
    var missionSubTopicType: String
    
    var missionFormatType: String
    
    var missionContentTitle: String?
    
    var missionContentText: String?
    
    var missionContentImagePaths: [String]?
    
    var missionCreationTime: Timestamp
    
    var missionBeginTime: Timestamp?
    
    var missionUserStateMap: [String : String]
    
    var missionRewardPoint: Int64
    
    let missionAnswerQuizCaption: String? //주관식 퀴즈의 힌트 캡션
    let missionAnswerQuizRightAnswer: String
}
