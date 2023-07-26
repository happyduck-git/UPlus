//
//  Post.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/06/23.
//

import Foundation
import FirebaseFirestore

enum PostType: String {
    case article
    case multipleChoice = "campaign_quiz_choice"
    case shortForm = "campaign_quiz_answer"
    case bestComment = "campaign_best_comment"
    
    var displayName: String {
        switch self {
        case .article:
            return "일반 게시물"
        case .multipleChoice:
            return "객관식 퀴즈"
        case .shortForm:
            return "주관식 퀴즈"
        case .bestComment:
            return "댓글 캠페인"
        }
    }
}

struct Post: Codable {
    let id: String
    let url: String
    let cachedType: String // 게시물 타입별로 노출하는 정보 상이함.
    let title: String
    let contentText: String
    let contentImagePathList: [String]?
    let authorUid: String
    let createdTime: Timestamp
    let likedUserIdList: [String]?
    let cachedLikedCount: Int64?
    let campaignMetadataBundle: [CampaignMetaData]?
    let cachedCommentCount: Int64?
    let cachedBestCommentIdList: [String]? //사용자 댓글 전체에 대하여 추천 수로 내림차순, 작성 시간 순으로 오름차순 정렬하여 5개를 나열
    
}

struct PostContent {
    let post: Post
    let comments: [Comment]?
}

struct CommentContent {
    
    let comment: Comment
    let recomments: [Recomment]?

}

extension CommentContent: Hashable {
    static func == (lhs: CommentContent, rhs: CommentContent) -> Bool {
        return lhs.comment.commentId == rhs.comment.commentId
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(comment)
        hasher.combine(recomments)
    }
}
