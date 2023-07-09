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
    
    var itemsMode: [Bool] = []
    
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
        if post.commentsTableDatasource.isEmpty {
            return nil
        }
        
        switch self.postType {
        case .article:
            return post.commentsTableDatasource[section - 1]
        default:
            return post.commentsTableDatasource[section - 2]
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
        
        if  post.commentsTableDatasource.isEmpty {
            return defaultSections
        } else {
            return post.commentsTableDatasource.count + defaultSections
        }
    }
    
}

//MARK: - Fetch User related data
extension CampaignPostViewViewModel {

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
