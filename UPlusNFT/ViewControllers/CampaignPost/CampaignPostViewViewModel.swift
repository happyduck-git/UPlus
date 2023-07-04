//
//  CampaignPostViewViewModel.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/04.
//

import Foundation

final class CampaignPostViewViewModel {
    
    private let postType: PostType
    
    enum SectionType: CaseIterable {
        case campaignBoard
        case post
        case comment
    }
    
    var sections: [SectionType] = SectionType.allCases
    
    // MARK: - Init
    init(postType: PostType) {
        self.postType = postType
    }
    
}
