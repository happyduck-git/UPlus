//
//  Post.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/06/23.
//

import Foundation

struct Post: Codable {
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
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case url = "url"
        case cachedType = "cached_type"
        case title = "title"
        case contentText = "content_text"
        case contentImagePathList = "content_image_path_list"
        case authorUid = "author_uid"
        case createdTime = "created_time"
        case likedUserIdList = "liked_user_id_list"
        case cachedBestCommentIdList = "cached_best_comment_id_list"
    }
    
}

struct PostContent {
    let post: Post
//    let comments: [CommnetContent]?
    let comments: [Comment]?
}

struct CommentContent {
    let comment: Comment
    let recomments: [Recomment]?
}
