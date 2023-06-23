//
//  Post.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/06/23.
//

import Foundation

struct Post {
    let id: String
    let url: String
    let cachedType: String // 게시물 타입별로 노출하는 정보 상이함.
    let title: String
    let contentText: String
    let contentImagePathList: [String]?
    let authorUid: String
    let createdTime: Date
    let likedUserIdList: [String]?
    let cachedBestCommentIdList: [String]? //사용자 댓글 전체에 대하여 추천 수로 내림차순, 작성 시간 순으로 오름차순 정렬하여 5개를 나열
}
