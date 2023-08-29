//
//  ChoiceQuizMission.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/07/26.
//

import Foundation
import FirebaseFirestore

struct ChoiceQuizMission: Mission, Codable {
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
    
    var missionChoiceQuizExtraBundle: String?
    
    let missionChoiceQuizCaptions: [String]
    let missionChoiceQuizRightOrder: Int64
}
