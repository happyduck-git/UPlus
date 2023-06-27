//
//  CommentTableViewCellModel.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/06/27.
//

import Foundation
import Combine

struct CommentTableViewCellModel {
    let comment: String
    let imageList: [String]?
    let likeUserCount: Int?
    let recomments: [Recomment]? 
}
