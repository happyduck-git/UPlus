//
//  CampaignPostViewViewModel.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/04.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

final class CampaignPostViewViewModel {
    // MARK: - Dependency
    private let firestoreManager = FirestoreManager.shared
    
    //MARK: - Property
    private let postId: String
    private(set) var postType: PostType
    let post: PostDetailViewViewModel
    var campaign: CampaignCollectionViewCellViewModel?
    var textInput: TextFieldCollectionVeiwCellViewModel?
    
    /// Pagination related.
    var queryDocumentSnapshot: QueryDocumentSnapshot?
    var isLoading: Bool = false
    
    // MARK: - Init
    init(
        postId: String,
        postType: PostType,
        post: PostDetailViewViewModel,
        campaign: CampaignCollectionViewCellViewModel?
    ) {
        self.postId = postId
        self.postType = postType
        self.post = post
        self.campaign = campaign
       
        switch postType {
        case .article:
            break
        default:
            self.campaignCellViewModel()
            self.fetchPostMetaData(postId)
        }
        
        self.textInputCellViewModel()
        
        // Fetch data
        self.fetchUser(post.userId)

    }

}

extension CampaignPostViewViewModel {
    
    func textInputCellViewModel() {
        self.textInput = TextFieldCollectionVeiwCellViewModel(postId: postId)
    }
    
    func campaignCellViewModel() {
        self.campaign = CampaignCollectionViewCellViewModel(postId: postId)
    }
    
    func postCellViewModel(at section: Int) -> CommentTableViewCellModel? {
        if post.tableDataSource.isEmpty {
            return nil
        }
        
        switch self.postType {
        case .article:
            return post.tableDataSource[section - 1]
        default:
            return post.tableDataSource[section - 2]
        }
    }
    
    func numberOfSections() -> Int {
        var defaultSections: Int = 0
        
        switch self.postType {
        case .article:
            defaultSections = 1
        default:
            defaultSections = 2
        }
        
        if  post.tableDataSource.isEmpty {
            return defaultSections
        } else {
            return post.tableDataSource.count + defaultSections
        }
    }
    
}

//MARK: - Fetch Post related data
extension CampaignPostViewViewModel {
    
    func fetchComments(of postId: String) {
        Task {
            do {
                let comments = try await firestoreManager.getBestComments(of: postId)
                
                var dataSource: [CommentTableViewCellModel] = []
                dataSource = comments.map({ comment in
                    return CommentTableViewCellModel(
                        type: .best,
                        id: comment.commentId,
                        userId: comment.commentAuthorUid,
                        comment: comment.commentContentText,
                        imagePath: comment.commentContentImagePath,
                        likeUserCount: comment.commentLikedUserUidList?.count,
                        recomments: nil,
                        createdAt: comment.commentCreatedTime
                    )
                })
     
                let normalComments = self.post.comments?.map({ comment in
                    return CommentTableViewCellModel(
                        type: .normal,
                        id: comment.commentId,
                        userId: comment.commentAuthorUid,
                        comment: comment.commentContentText,
                        imagePath: comment.commentContentImagePath,
                        likeUserCount: comment.commentLikedUserUidList?.count,
                        recomments: nil,
                        createdAt: comment.commentCreatedTime
                    )
                }) ?? []
            
                dataSource.append(contentsOf: normalComments)
                
                self.post.tableDataSource = dataSource
            }
            catch {
                print("Error fetching best 5 comments - \(error.localizedDescription)")
            }
        }
    }
    
    // TODO: Get recomments and map it to CommentTableViewCellModel
    func fetchRecomment(at section: Int, of commentId: String) {
        Task {
            do {
                let comments = try await firestoreManager.getRecomments(
                    postId: post.postId,
                    commentId: commentId
                )
                post.recomments[section] = comments
            }
            catch {
                print("Error fetching recomments - \(error.localizedDescription)")
            }
        }
    }

    func fetchUser(_ userId: String) {
        Task {
            do {
                post.user = try await firestoreManager.getUser(userId)
            }
            catch {
                print("Error fetching user - \(error)")
            }
        }
    }
    
}

// MARK: - Pagination Related
extension CampaignPostViewViewModel {
    func fetchInitialPaginatedComments(of postId: String) {
        Task {
            do {
                let comments = try await firestoreManager.getBestComments(of: postId)
                
                var dataSource: [CommentTableViewCellModel] = []
                dataSource = comments.map({ comment in
                    return CommentTableViewCellModel(
                        type: .best,
                        id: comment.commentId,
                        userId: comment.commentAuthorUid,
                        comment: comment.commentContentText,
                        imagePath: comment.commentContentImagePath,
                        likeUserCount: comment.commentLikedUserUidList?.count,
                        recomments: nil,
                        createdAt: comment.commentCreatedTime
                    )
                })
     
                let normalComments = self.post.comments?.map({ comment in
                    return CommentTableViewCellModel(
                        type: .normal,
                        id: comment.commentId,
                        userId: comment.commentAuthorUid,
                        comment: comment.commentContentText,
                        imagePath: comment.commentContentImagePath,
                        likeUserCount: comment.commentLikedUserUidList?.count,
                        recomments: nil,
                        createdAt: comment.commentCreatedTime
                    )
                }) ?? []
            
                dataSource.append(contentsOf: normalComments)
                
                self.post.tableDataSource = dataSource
            }
            catch {
                print("Error fetching best 5 comments - \(error.localizedDescription)")
            }
        }
    }
}

//MARK: - Fetch Campaign related data
extension CampaignPostViewViewModel {
    
    func fetchPostMetaData(_ postId: String) {
        Task {
            do {
                self.campaign?.campaignMetadata = try await firestoreManager.getMetadata(of: postId)
            }
            catch {
                print("Error fetching metadata - \(error)")
            }
        }
    }

    func createData() {
        
        guard let campaign = self.campaign,
              let metadata = campaign.campaignMetadata else { return }
        
        campaign.campaignPeriod = metadata.configuration.beginTime.dateValue().monthDayTimeFormat + " - " + metadata.configuration.endTime.dateValue().monthDayTimeFormat

        campaign.numberOfParticipants = String(describing: metadata.users?.count ?? 0)
        
        if metadata.configuration.endTime.dateValue().compare(Date()) == .orderedAscending {
            campaign.isExpired = false
        } else {
            campaign.isExpired = true
        }
        
        guard let users = metadata.users else { return }
        for user in users {
            if user.id == UserDefaults.standard.string(forKey: UserDefaultsConstants.userId) {
                campaign.hasJoined = true
                campaign.isRewarded = user.isRewared
                campaign.isEligable = user.isRightAnswer
            }
        }
        
    }

}
