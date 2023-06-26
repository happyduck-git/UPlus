//
//  CampaignMetaData.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/06/26.
//

import Foundation

struct CampaignMetaData {
    let configuration: CampaignConfiguration
    let items: [CampaignItem]
    let users: [CampaignUser]
    let bestComments: [BestComment]
}

struct CampaignConfiguration {
    let beginTime: Date
    let endTime: Date
}

struct CampaignItem {
    let id: String
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
    let rewardCategory: String // Reward enum 처리 고려.
    let rewaredUser: String
}
