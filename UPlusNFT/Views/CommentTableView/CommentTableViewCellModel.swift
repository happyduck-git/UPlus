//
//  CommentTableViewCellModel.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/06/27.
//

import UIKit.UIImage
import Combine
import FirebaseFirestore

final class CommentTableViewCellModel {
    // MARK: - Dependency
    private let firestoreManager = FirestoreManager.shared
    
    // MARK: - Property
    private(set) var type: CommentCellType
    let postId: String
    let id: String
    let userId: String
    var isOpened: Bool = false
    let comment: String
    let imagePath: String?
    var likeUserCount: Int?
    let recomments: [Recomment]?
    let createdAt: Timestamp
    
    @Published var isLiked: Bool = false
    @Published var user: User?
    @Published var editedComment: String?
    @Published var selectedImageToEdit: UIImage?
    
    var isBound: Bool = false
    
    //MARK: - Init
    init(
        type: CommentCellType,
        postId: String,
        id: String,
        userId: String,
        comment: String,
        imagePath: String?,
        likeUserCount: Int?,
        recomments: [Recomment]?,
        createdAt: Timestamp
    ) {
        self.type = type
        self.postId = postId
        self.id = id
        self.userId = userId
        self.comment = comment
        self.imagePath = imagePath
        self.likeUserCount = likeUserCount
        self.recomments = recomments
        self.createdAt = createdAt
        
        self.fetchUser(userId)
    }

}

// MARK: - Fetch Data from Firestore
extension CommentTableViewCellModel {
    
    /// Fetch user information from Firestore.
    /// - Parameter userId: User Uid.
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
  
    
    /// Update like counts.
    /// - Parameters:
    ///   - postId: Post id.
    ///   - isLiked: If the post is liked.
    func likeComment(isLiked: Bool) async throws {
        Task {
            do {
                try await self.firestoreManager.updateCommentLike(postId: postId,
                                                                  commentId: id,
                                                                  isLiked: isLiked)
            }
            catch {
                print("Error like comment - \(error.localizedDescription)")
            }
        }
    }
    
    /// Edit texts or image of  a comment.
    /// - Parameters:
    ///   - postId: Post id of the comment is belonged to.
    ///   - commentId: Comment id.
    ///   - commentToEdit: New texts to be saved.
    ///   - originalImagePath: Original image path, if any.
    ///   - imageToEdit: New image, if any.
    func editComment(postId: String,
                     commentId: String,
                     commentToEdit: String,
                     originalImagePath: String?,
                     imageToEdit: UIImage?) async throws {
        
        let path = try await firestoreManager.saveCommentImage(
            to: postId,
            image: imageToEdit?.jpegData(compressionQuality: 0.75)
        )
        
        if path != nil {
            try await firestoreManager.deleteImageFromStorage(path: originalImagePath)
        }
        
        try await firestoreManager.editComment(of: postId,
                                               commentId: commentId,
                                               commentToEdit: commentToEdit,
                                               imageToEdit: path)
    }
    
    /// Delete a comment.
    /// - Parameters:
    ///   - postId: Post id of the comment is belonged to.
    ///   - commentId: Comment id.
    func deleteComment(postId: String,
                       commentId: String) async throws {
        try await firestoreManager.deleteComment(postId: postId,
                                                 commentId: commentId)
    }
}

extension CommentTableViewCellModel {
    func changeCellType(to cellType: CommentCellType) {
        self.type = cellType
    }
}
