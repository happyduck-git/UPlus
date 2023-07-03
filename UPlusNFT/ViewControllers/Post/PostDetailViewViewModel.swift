//
//  PostDetailViewViewModel.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/06/27.
//

import Foundation
import FirebaseAuth
import Combine

final class PostDetailViewViewModel {
    
    // MARK: - Dependency
    private let firestoreManager = FirestoreManager.shared
    
    // MARK: - Properties
    let userId: String
    let postId: String
    let postUrl: String
    let postType: PostType
    let postTitle: String
    let postContent: String
    let imageList: [String]?
    let likeUserCount: Int
    let createdTime: Date
    var comments: [Comment]?
    var isPostOfCurrentUser: Bool {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return false }
        return self.userId == currentUserId ? true : false
    }
    
    @Published var tableDataSource: [CommentTableViewCellModel] = []
    @Published var metaData: CampaignMetaData?
    @Published var recomments: [Int: [Recomment]] = [:]
    @Published var user: User?
    
    // MARK: - Init
    init(
        userId: String,
        postId: String,
        postUrl: String,
        postType: PostType,
        postTitle: String,
        postContent: String,
        imageList: [String]?,
        likeUserCount: Int,
        createdTime: Date,
        comments: [Comment]?
    ) {
        self.userId = userId
        self.postId = postId
        self.postUrl = postUrl
        self.postType = postType
        self.postTitle = postTitle
        self.postContent = postContent
        self.imageList = imageList
        self.likeUserCount = likeUserCount
        self.createdTime = createdTime
        self.comments = comments
        
        // TODO: Fetch Best comment and then append normal comments at the end.
        
        self.fetchComments(of: postId)

        self.fetchUser(userId)
    }
    
}

extension PostDetailViewViewModel {
    
    func viewModelForRow(at row: Int) -> CommentTableViewCellModel? {
        if self.tableDataSource.isEmpty {
            return nil
        }
        return self.tableDataSource[row]
    }
    
    func numberOfSections() -> Int {
        return self.tableDataSource.count + 1
    }
    
}

// MARK: - Fetch Data from Firestore
extension PostDetailViewViewModel {
    
    func fetchComments(of postId: String) {
        Task {
            do {
                let comments = try await firestoreManager.getBestComments(of: postId)
                tableDataSource = comments.map({ comment in
                    return CommentTableViewCellModel(
                        type: .best,
                        id: comment.commentId,
                        userId: comment.commentAuthorUid,
                        comment: comment.commentContentText,
                        imagePath: comment.commentContentImagePath,
                        likeUserCount: comment.commentLikedUserUidList?.count,
                        recomments: nil,
                        createdAt: comment.commentCreatedTime
                    )
                })
                
                let normalComments = self.comments?.map({ comment in
                    return CommentTableViewCellModel(
                        type: .normal,
                        id: comment.commentId,
                        userId: comment.commentAuthorUid,
                        comment: comment.commentContentText,
                        imagePath: comment.commentContentImagePath,
                        likeUserCount: comment.commentLikedUserUidList?.count,
                        recomments: nil,
                        createdAt: comment.commentCreatedTime
                    )
                }) ?? []
                tableDataSource.append(contentsOf: normalComments)
            }
            catch {
                print("Error fetching best 5 comments - \(error.localizedDescription)")
            }
        }
    }
    
    // TODO: Get recomments and map it to CommentTableViewCellModel
    func fetchRecomment(at section: Int, of commentId: String) {
//        return try await firestoreManager.getRecomments(postId: postId, commentId: commentId)
        Task {
            do {
                let comments = try await firestoreManager.getRecomments(postId: postId, commentId: commentId)
                recomments[section] = comments
            }
            catch {
                print("Error fetching recomments - \(error.localizedDescription)")
            }
        }
    }
    
    func fetchPostMetaData(_ postId: String) {
        Task {
            do {
                metaData = try await firestoreManager.getMetadata(of: postId)
            }
            catch {
                print("Error fetching metadata - \(error)")
            }
        }
    }
    
    func fetchUser(_ userId: String) {
        Task {
            do {
                user = try await firestoreManager.getUser(userId)
            }
            catch {
                print("Error fetching user - \(error)")
            }
        }
    }
    
}
