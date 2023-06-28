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
    var comments: [Comment]?
    
    @Published var tableDataSource: [CommentTableViewCellModel] = []
    @Published var metaData: CampaignMetaData?
    @Published var recomments: [Int: [Recomment]] = [:]
    
    // MARK: - Init
    init(postId: String, postTitle: String, postContent: String, imageList: [String]?, likeUserCount: Int, comments: [Comment]?) {
        self.postId = postId
        self.postTitle = postTitle
        self.postContent = postContent
        self.imageList = imageList
        self.likeUserCount = likeUserCount
        self.comments = comments
        
        self.tableDataSource = comments?.map({ comment in
            return CommentTableViewCellModel(
                id: comment.commentId,
                comment: comment.commentContentText,
                imagePath: comment.commentContentImagePath,
                likeUserCount: comment.commentLikedUserUidList?.count,
                recomments: nil
            )
        }) ?? []
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
                metaData = try await FirestoreManager.shared.getMetadata(of: postId)
            }
            catch {
                print("Error fetching metadata - \(error)")
            }
        }
    }
    
    
}
