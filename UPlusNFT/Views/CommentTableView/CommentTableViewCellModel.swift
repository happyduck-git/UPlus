//
//  CommentTableViewCellModel.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/06/27.
//

import Foundation
import Combine

struct CommentTableViewCellModel {
    var isOpened: Bool = false
    let comment: String
    let imagePath: String?
    let likeUserCount: Int?
    let recomments: [Recomment]? 
}
