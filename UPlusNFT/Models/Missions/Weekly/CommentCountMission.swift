//
//  CommentCountMission.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/07.
//

import Foundation
import FirebaseFirestore

struct CommentCountMission: Mission, Codable {
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

    var userCommentListVisible: Bool
    var userCommentLikeEnabled: Bool
    var userCommentMultipleEnabled: Bool

    var userCommnetSet: [UserCommentSet]?
}

struct UserCommentSet: Codable {
    var commentId: String
    var commentUser: DocumentReference
    var commentText: String?
    var commentImagePath: String?
    var commentTime: Timestamp
    var commentLikeUsers: [DocumentReference]?
}
