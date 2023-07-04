//
//  MultipleQuizCollectionViewCellViewModel.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/04.
//

import Foundation
import Combine

final class CampaignCollectionViewCellViewModel {
    // MARK: - Dependency
    private let firestoreManager = FirestoreManager.shared
    
    // MARK: - Property
    
    // Basic post data.
    var postId: String
    
    @Published var campaignMetadata: CampaignMetaData?
    var campaignPeriod: String = ""
    var numberOfParticipants: String = ""
    var hasJoined: Bool = false
    var isRewarded: Bool = false
    var isEligable: Bool = false
    var isExpired: Bool = false
    
    // UI interaction related.
    @Published var isTextFieldEmpty: Bool = true
    
    // MARK: - Init
    init(postId: String) {
        self.postId = postId
    }
    
}

// MARK: - Internal Functions
extension CampaignCollectionViewCellViewModel {
    
    func fetchPostMetaData(_ postId: String) {
        Task {
            do {
                self.campaignMetadata = try await firestoreManager.getMetadata(of: postId)
            }
            catch {
                print("Error fetching metadata - \(error)")
            }
        }
    }
}

// MARK: - Private
extension CampaignCollectionViewCellViewModel {
    func createData() {
        
        guard let metadata = campaignMetadata else { return }
        
        self.campaignPeriod = metadata.configuration.beginTime.dateValue().monthDayTimeFormat + " - " + metadata.configuration.endTime.dateValue().monthDayTimeFormat

        self.numberOfParticipants = String(describing: metadata.users?.count ?? 0)
        
        if metadata.configuration.endTime.dateValue().compare(Date()) == .orderedAscending {
            self.isExpired = false
        } else {
            self.isExpired = true
        }
        
        guard let users = metadata.users else { return }
        for user in users {
            if user.id == UserDefaults.standard.string(forKey: UserDefaultsConstants.userId) {
                self.hasJoined = true
                self.isRewarded = user.isRewared
                self.isEligable = user.isRightAnswer
            }
        }
        
    }
}
