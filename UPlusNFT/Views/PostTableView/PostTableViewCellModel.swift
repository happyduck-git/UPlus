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
    let postUrl: String
    let postType: PostType
    let postTitle: String
    let postContent: String
    let imageList: [String]?
    let likeUserCount: Int
    let createdTime: Date
    let comments: [Comment]?
    
    @Published var metaData: CampaignMetaData?
    
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
