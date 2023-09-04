//
//  PopGameConstants.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/09/04.
//

import Foundation

struct PopGameConstants {
    static let alpha = 0.3
    
    // Firestore
    static let topLevelCollection: String = "dev_threads2"
    static let topLevelDoc: String = "nft_score_system"
    static let secondLevelCollection: String = "nft_collection_set"
    static let nftScoreSet: String = "nft_score_set"
    
    static let cachedTotalActionCountSet: String = "cached_total_action_count_set"
    static let cachedTotalNftScoreSet: String = "cached_total_nft_score_set"
    static let walletAccountSet: String = "wallet_account_set"
    static let actionCountSet: String = "action_count_set"
    static let profileImageUrl: String = "profile_image_url"
    static let popgame: String = "popgame"
    static let totalCount: String = "total_count"
    static let totalScore: String = "total_score"
    static let count: String = "count"
    static let score: String = "score"
}
