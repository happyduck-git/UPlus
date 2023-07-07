//
//  Comment.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/06/23.
//

import Foundation
import FirebaseFirestore

struct Comment: Codable, Hashable {
    let commentAuthorUid: String
    let commentContentImagePath: String?
    let commentContentText: String
    let commentCreatedTime: Timestamp
    let commentId: String
    let commentLikedUserUidList: [String]?
}
