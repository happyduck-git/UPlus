//
//  Comment.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/06/23.
//

import Foundation

struct Comment: Codable, Hashable {
    let commentAuthorUid: String
    let commentContentImagePath: String?
    let commentContentText: String
    let commentCreatedTime: Date
    let commentId: String
    let commentLikedUserUidList: [String]?
    
    enum CodingKeys: String, CodingKey {
        case commentAuthorUid = "comment_author_uid"
        case commentContentImagePath = "comment_content_image_path"
        case commentContentText = "comment_content_text"
        case commentCreatedTime = "comment_created_time"
        case commentId = "comment_id"
        case commentLikedUserUidList = "comment_liked_user_uid_list"
    }
}
