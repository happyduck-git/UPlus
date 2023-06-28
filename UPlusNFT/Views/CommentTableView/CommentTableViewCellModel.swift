//
//  CommentTableViewCellModel.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/06/27.
//

import Foundation
import Combine

final class CommentTableViewCellModel {
    let id: String
    var isOpened: Bool = false
    let comment: String
    let imagePath: String?
    let likeUserCount: Int?
    let recomments: [Recomment]?
    
    init(id: String, comment: String, imagePath: String?, likeUserCount: Int?, recomments: [Recomment]?) {
        self.id = id
        self.comment = comment
        self.imagePath = imagePath
        self.likeUserCount = likeUserCount
        self.recomments = recomments
    }
}
