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
    let type: CommentCellType
    let postId: String
    let id: String
    let userId: String
    var isOpened: Bool = false
    let comment: String
    let imagePath: String?
    let likeUserCount: Int?
    let recomments: [Recomment]?
    let createdAt: Timestamp
    
    @Published var user: User?
    @Published var editedComment: String?
    @Published var selectedImageToEdit: UIImage?
    
    var isBinded: Bool = false
    
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

extension CommentTableViewCellModel {
    
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
  
    func editComment(postId: String,
                     commentId: String,
                     commentToEdit: String,
                     originalImagePath: String?,
                     imageToEdit: UIImage?) async throws {
        
        async let path = firestoreManager.saveCommentImage(to: postId, image: imageToEdit?.jpegData(compressionQuality: 0.75))
        async let _ = firestoreManager.deleteImageFromStorage(path: originalImagePath)
        
        try await firestoreManager.editComment(of: postId,
                                               commentId: commentId,
                                               commentToEdit: comment,
                                               imageToEdit: path)
        
    }
    
}
