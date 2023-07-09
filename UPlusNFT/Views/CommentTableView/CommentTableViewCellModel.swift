//
//  CommentTableViewCellModel.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/06/27.
//

import Foundation
import Combine
import FirebaseFirestore

final class CommentTableViewCellModel {
    // MARK: - Dependency
    private let firestoreManager = FirestoreManager.shared
    
    // MARK: - Property
    let type: CommentCellType
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
    
    //MARK: - Init
    init(
        type: CommentCellType,
        id: String,
        userId: String,
        comment: String,
        imagePath: String?,
        likeUserCount: Int?,
        recomments: [Recomment]?,
        createdAt: Timestamp
    ) {
        self.type = type
        self.id = id
        self.userId = userId
        self.comment = comment
        self.imagePath = imagePath
        self.likeUserCount = likeUserCount
        self.recomments = recomments
        self.createdAt = createdAt
        
        self.fetchUser(userId)
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
