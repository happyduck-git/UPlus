//
//  PostDetailViewViewModel.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/06/27.
//

import Foundation
import FirebaseAuth
import Combine
import FirebaseFirestore

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
    
    @Published var recomments: [Int: [Recomment]] = [:]
    @Published var user: User?
    
    /// Pagination related.
    var queryDocumentSnapshot: QueryDocumentSnapshot?
    var isLoading: Bool = false
    
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
        return self.tableDataSource.count
    }
    
}

// MARK: - Fetch Data from Firestore
extension PostDetailViewViewModel {
    
    func fetchComments(of postId: String) {
        Task {
            do {
                let bestComments = try await firestoreManager.getBestComments(of: postId)
                
                var dataSource: [CommentTableViewCellModel] = []
                dataSource = bestComments.map({ comment in
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
     
                let normalCommentData = try await firestoreManager.getPaginatedComments(of: postId)
                
                self.queryDocumentSnapshot = normalCommentData.lastDoc
                
                let normalComments = normalCommentData.comments.map({ comment in
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
                })
            
                dataSource.append(contentsOf: normalComments)
                
                self.tableDataSource = dataSource
            }
            catch {
                print("Error fetching comments of Post ID \(postId) - \(error.localizedDescription)")
            }
        }
    }
    
    // TODO: Get recomments and map it to CommentTableViewCellModel
    func fetchRecomment(at section: Int, of commentId: String) {
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
