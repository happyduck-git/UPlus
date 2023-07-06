//
//  PostViewViewModel.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/06/26.
//

import Foundation
import Combine
import FirebaseFirestore

final class PostViewViewModel {
    
    // MARK: - Dependency
    private let firestoreManager = FirestoreManager.shared
    
    // MARK: - Property
    
    /// Pagination related.
    var queryDocumentSnapshot: QueryDocumentSnapshot?
    var isLoading: Bool = false
    
    @Published var tableDataSource: [PostTableViewCellModel] = []
    @Published var didLoadAdditionalPosts: Bool = false
    
    var numberOfRows: Int {
        return self.tableDataSource.count
    }
    
    func cellForRow(at row: Int) -> PostTableViewCellModel {
        return self.tableDataSource[row]
    }
    
    func postDetailViewModel(at row: Int) -> PostDetailViewViewModel {
        let vm = self.tableDataSource[row]
        
        return PostDetailViewViewModel(
            userId: vm.userId,
            postId: vm.postId,
            postUrl: vm.postUrl,
            postType: vm.postType,
            postTitle: vm.postTitle,
            postContent: vm.postContent,
            imageList: vm.imageList,
            likeUserCount: vm.likeUserCount,
            createdTime: vm.createdTime,
            comments: nil
        )
    }
    
    func campaignCellViewModel(postId: String) -> CampaignCollectionViewCellViewModel {
        return CampaignCollectionViewCellViewModel(postId: postId)
    }
    
}

// MARK: - Fetch data

extension PostViewViewModel {
    func fetchAllInitialPosts() {
        Task {
            do {
                let results = try await firestoreManager.getPaginatedPosts()
                let vms = results.posts.map { post in
                    return self.convertToCellViewModel(post: post)
                }
                self.tableDataSource = vms
                self.queryDocumentSnapshot = results.lastDoc
            }
            catch {
                print("Error getting all posts from Firestore -- \(error)")
            }
        }
    }
    
    func fetchAdditionalPosts() {
        Task {
                self.isLoading = true
                
                let results = try await firestoreManager.getAdditionalPaginatedPosts(after: self.queryDocumentSnapshot)
                let vms = results.posts.map { post in
                    return self.convertToCellViewModel(post: post)
                }
                
                self.didLoadAdditionalPosts = true
                self.isLoading = false
                
                self.tableDataSource.append(contentsOf: vms)
                self.queryDocumentSnapshot = results.lastDoc
            }
    }
    
    private func convertToCellViewModel(post: Post) -> PostTableViewCellModel {
        return PostTableViewCellModel(
            userId: post.authorUid,
            postId: post.id,
            postUrl: post.url,
            postType: PostType(rawValue: post.cachedType) ?? .article,
            postTitle: post.title,
            postContent: post.contentText,
            imageList: post.contentImagePathList,
            likeUserCount: post.likedUserIdList?.count ?? 0,
            createdTime: post.createdTime.dateValue(),
            commentCount: post.cachedCommentCount ?? 0
        )
    }
}
