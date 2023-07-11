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
    let isLiked: Bool
    var isPostOfCurrentUser: Bool {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return false }
        return self.userId == currentUserId ? true : false
    }
    
    @Published var commentsTableDatasource: [CommentTableViewCellModel] = [] {
        didSet {
            let recom: [[Recomment]] = self.commentsTableDatasource.compactMap { vm in
                vm.recomments
            }
            recomments = recom
        }
    }
    
    private var recomments: [[Recomment]] = []

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
        comments: [Comment]?,
        isLiked: Bool
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
        self.isLiked = isLiked
        
        self.fetchInitialPaginatedComments(of: postId)

        self.fetchUser(userId)
    }
    
}

extension PostDetailViewViewModel {
    
    func viewModelForRow(at row: Int) -> CommentTableViewCellModel? {
        if self.commentsTableDatasource.isEmpty {
            return nil
        }
        return self.commentsTableDatasource[row]
    }
    
    func numberOfSections() -> Int {
        return self.commentsTableDatasource.count
    }
    
    private func recommentsForSection(at section: Int) -> [Recomment] {
        switch postType {
        case .article:
            return self.recomments[section - 1]
        default:
            return self.recomments[section - 2]
        }
    }
    
    func numberOfRecommentsForSection(at section: Int) -> Int {
        return recommentsForSection(at: section).count + 2
    }
    
    func recommentsViewModelForItem(at item: Int, section: Int) -> CommentTableViewCellModel {
        let recomments = self.recommentsForSection(at: section)
        let recomment = recomments[item - 1]
        return CommentTableViewCellModel(
            type: .normal,
            postId: self.postId,
            id: recomment.recommentId,
            userId: recomment.recommentAuthorUid,
            comment: recomment.recommentContentText,
            imagePath: nil,
            likeUserCount: nil,
            recomments: nil,
            createdAt: recomment.recommentCreatedTime
        )
    }
    
}

// MARK: - Fetch Data from Firestore
extension PostDetailViewViewModel {
    
    func fetchInitialPaginatedComments(of postId: String) {
        Task {
            do {
                // Get Best Comments
                let bestComments = try await firestoreManager.getBestComments(of: postId)
                var dataSource: [CommentTableViewCellModel] = []
           
                for bestComment in bestComments {
                    dataSource.append(try await convertToViewModel(from: bestComment, commentType: .best))
                }

                // Get Normal Paginated Comments
                let normalCommentData = try await firestoreManager.getPaginatedComments(of: postId)
                
                for comment in normalCommentData.comments {
                    dataSource.append(try await convertToViewModel(from: comment, commentType: .normal))
                }

                self.commentsTableDatasource = dataSource
                self.queryDocumentSnapshot = normalCommentData.lastDoc
            }
            catch {
                print("Error fetching comments of Post ID \(postId) - \(error)")
            }
        }
    }
    
    func fetchAdditionalPaginatedComments(of postId: String) {
        Task {
            do {
                self.isLoading = true
                
                var comments: [CommentTableViewCellModel] = []
                let commentsData = try await firestoreManager.getAdditionalPaginatedComments(
                    of: postId,
                    after: self.queryDocumentSnapshot
                )
                
                for comment in commentsData.comments {
                    comments.append(try await convertToViewModel(from: comment, commentType: .normal))
                }
                
                self.commentsTableDatasource.append(contentsOf: comments)
                self.queryDocumentSnapshot = commentsData.lastDoc
                
                self.isLoading = false
            }
            catch {
                print("Error fetching additional comments of Post ID \(postId) - \(error.localizedDescription)")
            }
        }
    }
 
    func fetchRecomment(of commentId: String) async throws -> [Recomment] {
        return try await firestoreManager.getRecomments(postId: postId, commentId: commentId)
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

extension PostDetailViewViewModel {
    private func convertToViewModel(from comment: Comment, commentType: CommentCellType) async throws -> CommentTableViewCellModel {
        let recomments = try await fetchRecomment(of: comment.commentId)
        return CommentTableViewCellModel(
            type: commentType,
            postId: self.postId,
            id: comment.commentId,
            userId: comment.commentAuthorUid,
            comment: comment.commentContentText,
            imagePath: comment.commentContentImagePath,
            likeUserCount: comment.commentLikedUserUidList?.count,
            recomments: recomments,
            createdAt: comment.commentCreatedTime
        )
    }
}

/// Currently NOT IN USE
extension PostDetailViewViewModel {
    
    // TODO: Get recomments and map it to CommentTableViewCellModel
    func fetchRecommentOld(at section: Int, of commentId: String) {
        Task {
            do {
                let comments = try await firestoreManager.getRecomments(postId: postId, commentId: commentId)
               
            }
            catch {
                print("Error fetching recomments - \(error.localizedDescription)")
            }
        }
    }
    
}
