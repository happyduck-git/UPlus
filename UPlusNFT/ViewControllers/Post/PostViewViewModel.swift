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
        print("\(#function) -- \(self.tableDataSource.count)")
        return self.tableDataSource.count
    }
    
    func cellForRow(at row: Int) -> PostTableViewCellModel {
        return self.tableDataSource[row]
    }
    
    func postDetailViewModel(at row: Int) -> PostDetailViewViewModel {
        let vm = self.tableDataSource[row]
        
        return PostDetailViewViewModel(
            postId: vm.postId,
            postTitle: vm.postTitle,
            postContent: vm.postContent,
            imageList: vm.imageList,
            likeUserCount: vm.likeUserCount,
            comments: vm.comments
        )
    }
    
    func fetchAllPosts() {
        Task {
            do {
                let posts = try await FirestoreManager.shared.getAllPostContent()
                let vms = posts.map { post in
                    return PostTableViewCellModel(
                        postId: post.post.id,
                        postTitle: post.post.title,
                        postContent: post.post.contentText,
                        imageList: post.post.contentImagePathList,
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
