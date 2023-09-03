//
//  LevelUpBottomSheetViewViewModel.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/29.
//

import Foundation
import Combine

final class LevelUpBottomSheetViewViewModel {
    
    // MARK: - Dependency
    private let firestoreManager = FirestoreManager.shared
    
    private var newLevel: Int {
        didSet {
            guard let level = UserLevel(rawValue: newLevel) else { return }
            self.level = level
        }
    }
    private let tokenId: String
    
    var level: UserLevel = .level2
//    var nft = PassthroughSubject<UPlusNft?, Never>()
    
    // MARK: - Init
    init(newLevel: Int, tokenId: String) {
        self.newLevel = newLevel
        self.tokenId = tokenId
        
        print("Newlevel of the user: \(self.newLevel)")
        
//        self.getNft()
    }
    
}

extension LevelUpBottomSheetViewViewModel {
    
//    private func getNft() {
//        Task {
//            nft.send(await firestoreManager.getNft(tokenId: tokenId))
//            UPlusLogger.logger.info("Get NFT for \(String(describing: self.tokenId)) is finished.")
//        }
//    }
    
}
