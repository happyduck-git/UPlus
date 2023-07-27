//
//  PhotoAuthMission.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/07/26.
//

import Foundation
import FirebaseFirestore

struct PhotoAuthMission: Mission {
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
    
    let missionPhotoTaskSet: [MissionPhotoTask]?
    let missionAdminUserEmail: String? //미션 검토자의 이메일
    let missionAdminConfirmTime: Timestamp? //관리자의 최종 검토 완료 시각
}

struct MissionPhotoTask {
    let mission_photo_task_user: String //미션 참여자의 사용자 다큐먼트를 가리킨다.
    let mission_photo_task_image_path: String //미션 참여자가 제출한 사진 이미지의 경로
    let mission_photo_task_time: Timestamp //미션 참여 일자를 가리킨다.
}
