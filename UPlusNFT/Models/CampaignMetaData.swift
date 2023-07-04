//
//  CampaignMetaData.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/06/26.
//

import Foundation
import FirebaseFirestore

struct CampaignMetaData {
    let configuration: CampaignConfiguration
    let items: [CampaignItem]? // {campaign_items}/campaign_item_set/{0} => fields
    let users: [CampaignUser]? //{campaign_users}/campaign_user_set/{doc-id} => fields
    let bestComments: [BestComment]? // {campaign_best_comment_items}/campaign_best_comment_item_set/{0} => fields
}

struct CampaignConfiguration {
    let beginTime: Timestamp
    let endTime: Timestamp
}

struct CampaignItem {
    let id: Int64
    let caption: String
    let isRight: Bool
    let rewardCategoryId: String?
    let participantsCount: Int64?
}

struct CampaignUser {
    let id: String
    let selectedItemId: Int64
    let answerSubmitted: String?
    let isRightAnswer: Bool
    let isRewared: Bool
}

struct BestComment {
    let order: Int64
    let rewardCategory: String? // Reward enum 처리 고려.
    let rewaredUser: String?
}
