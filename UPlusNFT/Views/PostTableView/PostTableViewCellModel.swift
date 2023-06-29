//
//  PostTableViewCellModel.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/06/26.
//

import Foundation
import Combine

final class PostTableViewCellModel {
    
    // MARK: - Dependency
    private let firestoreManager = FirestoreManager.shared
    
    // MARK: - Properties
    let userId: String
    let postId: String
    let postTitle: String
    let postContent: String
    let imageList: [String]?
    let likeUserCount: Int
    let comments: [Comment]?
    
    @Published var metaData: CampaignMetaData?
    
    // MARK: - Init
    init(userId: String, postId: String, postTitle: String, postContent: String, imageList: [String]?, likeUserCount: Int, comments: [Comment]?) {
        self.userId = userId
        self.postId = postId
        self.postTitle = postTitle
        self.postContent = postContent
        self.imageList = imageList
        self.likeUserCount = likeUserCount
        self.comments = comments
    }
    
    // MARK: - Internal
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
}
