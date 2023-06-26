//
//  PostTableViewCellModel.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/06/26.
//

import Foundation

struct PostTableViewCellModel {
    let postTitle: String
    let postContent: String
    let likeUserCount: Int
    let comments: [Comment]?
}
