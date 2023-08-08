//
//  ShortAnswerQuizMission.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/07/26.
//

import Foundation
import FirebaseFirestore

struct ShortAnswerQuizMission: Mission, Codable {
    var missionId: String
    var missionTopicType: String
    var missionSubTopicType: String
    var missionFormatType: String
    var missionSubFormatType: String?
    var missionContentTitle: String?
    var missionContentText: String?
    var missionContentImagePaths: [String]?
    var missionCreationTime: Timestamp
    var missionStartTime: Timestamp?
    var missionUserStateMap: [String : String]?
    var missionRewardPoint: Int64
    var missionPermitAvatarLevel: Int64
    
    var missionAnswerQuizzes: [String] //  0번째 원소는 힌트 캡션 텍스트를, 1번째 원소는 정답 문구 텍스트
}
