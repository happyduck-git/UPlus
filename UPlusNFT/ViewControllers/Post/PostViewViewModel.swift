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
        print("Is liked? \(vm.isLiked)")
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
            comments: nil,
            isLiked: vm.isLiked
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
                var vms: [PostTableViewCellModel] = []
                for post in results.posts {
                    let vm = self.convertToCellViewModel(post: post)
                    vm.isLiked = try await firestoreManager.isPostLiked(postId: post.id)
                    vms.append(vm)
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
            var vms: [PostTableViewCellModel] = []
            for post in results.posts {
                let vm = self.convertToCellViewModel(post: post)
                vm.isLiked = try await firestoreManager.isPostLiked(postId: post.id)
                vms.append(vm)
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

extension PostViewViewModel {
    /// Update like counts.
    /// - Parameters:
    ///   - postId: Post id.
    ///   - isLiked: If the post is liked.
    func updatePostLike(postId: String,
                        isLiked: Bool) async throws {
        try await self.firestoreManager.updatePostLike(postId: postId,
                                                       isLiked: isLiked)
    }
}
