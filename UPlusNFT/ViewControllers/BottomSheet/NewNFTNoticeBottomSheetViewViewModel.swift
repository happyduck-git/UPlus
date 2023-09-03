//
//  NewNFTNoticeBottomSheetViewViewModel.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/16.
//

import Foundation
import Combine

final class NewNFTNoticeBottomSheetViewViewModel {
    
    // MARK: - Dependency
    private let firestoreManager = FirestoreManager.shared
    
    let tokenId: String
    
//    var nft = PassthroughSubject<UPlusNft?, Never>()
    
    // MARK: - Init
    init(tokenId: String) {
        self.tokenId = tokenId
//        self.getNft()
    }
    
}

extension NewNFTNoticeBottomSheetViewViewModel {
    
//    private func getNft() {
//        UPlusLogger.logger.debug("Get NFT info called...")
//        Task {
//            nft.send(await firestoreManager.getNft(tokenId: tokenId))
//            UPlusLogger.logger.debug("Get NFT for \(String(describing: self.tokenId)) is finished.")
//        }
//    }
    
}
