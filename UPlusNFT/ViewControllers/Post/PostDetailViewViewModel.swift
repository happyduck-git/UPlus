//
//  PostDetailViewViewModel.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/06/27.
//

import Foundation
import Combine

final class PostDetailViewViewModel {
    
    // MARK: - Dependency
    private let firestoreManager = FirestoreManager.shared
    
    // MARK: - Properties
    let postId: String
    let postTitle: String
    let postContent: String
    let imageList: [String]?
    let likeUserCount: Int
    let comments: [Comment]?
    
    @Published var tableDataSource: [CommentTableViewCellModel] = []
    @Published var metaData: CampaignMetaData?
    
    // MARK: - Init
    init(postId: String, postTitle: String, postContent: String, imageList: [String]?, likeUserCount: Int, comments: [Comment]?) {
        self.postId = postId
        self.postTitle = postTitle
        self.postContent = postContent
        self.imageList = imageList
        self.likeUserCount = likeUserCount
        self.comments = comments
    }
    
}

extension PostDetailViewViewModel {
    
    func viewModelForRow(at row: Int) -> CommentTableViewCellModel {
        return self.tableDataSource[row]
    }
    
}

// MARK: - Fetch Data from Firestore
extension PostDetailViewViewModel {
    
    // TODO: Get recomments and map it to CommentTableViewCellModel
    func fetchRecomment(of commentId: String) {
        
    }
    
    func fetchPostMetaData(_ postId: String) {
        Task {
            do {
                metaData = try await FirestoreManager.shared.getMetadata(of: postId)
            }
            catch {
                print("Error fetching metadata - \(error)")
            }
        }
    }
    
    
}
