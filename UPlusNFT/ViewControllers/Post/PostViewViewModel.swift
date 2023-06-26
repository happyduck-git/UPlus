//
//  PostViewViewModel.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/06/26.
//

import Foundation
import Combine

final class PostViewViewModel {
    
    // MARK: - Dependency
    private let firestoreManager = FirestoreManager.shared
    
    @Published var tableDataSource: [PostTableViewCellModel] = []

    var numberOfRows: Int {
        self.tableDataSource.count
    }
    
    func cellForRow(at row: Int) -> PostTableViewCellModel {
        return self.tableDataSource[row]
    }
    
    func fetchAllPosts() {
        Task {
            do {
                let posts = try await FirestoreManager.shared.getAllPostContent()
                let vms = posts.map { post in
                    print("Post comments ")
                    return PostTableViewCellModel(
                        postTitle: post.post.title,
                        postContent: post.post.contentText,
                        likeUserCount: post.post.likedUserIdList?.count ?? 0,
                        comments: post.comments
                    )
                }
                self.tableDataSource = vms
            }
            catch {
                print("Error getting all posts from Firestore -- \(error)")
            }
        }
    }
    
}
