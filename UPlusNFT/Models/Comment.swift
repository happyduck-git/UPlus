//
//  Comment.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/06/23.
//

import Foundation

struct Comment: Decodable {
//    let postId: String
    let commentAuthorUid: String
    let commentContentImagePath: String?
    let commentContentText: String
    let commentCreatedTime: Date
    let commentId: String
    let commentLikedUserUidList: [String]?
}
