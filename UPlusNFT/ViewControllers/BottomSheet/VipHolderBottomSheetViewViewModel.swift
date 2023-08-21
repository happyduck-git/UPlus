//
//  VipHolderBottomSheetViewViewModel.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/07/19.
//

import Foundation
import Combine

final class VipHolderBottomSheetViewViewModel {
    
    // MARK: - Managers
    private let firestoreManger = FirestoreManager.shared
    private let nftServiceManger = NFTServiceManager.shared
    
    //MARK: - Dependency
    let user: UPlusUser
    private(set) var saveStatus = PassthroughSubject<Bool, Never>()
    
    init(user: UPlusUser) {
        self.user = user
    }
    
}

extension VipHolderBottomSheetViewViewModel {
    
    func requestVipNft() {
        Task {
            do {
                let result = try await self.nftServiceManger.requestSingleNft(userIndex: user.userIndex,
                                                                 nftType: .avatar,
                                                                 level: 2)
                print("Result of requesting nft: \(result)")
            }
            catch {
                print("Error requesting level 2 nft.")
            }
        }
    }
    
}

extension VipHolderBottomSheetViewViewModel {
    
    func saveVipInitialPoint() async {
        
        do {
            let user = try UPlusUser.getCurrentUser()
            try await self.firestoreManger.saveVipUserInitialPoint(userIndex: user.userIndex)
            self.saveStatus.send(true)
            print("VIP user point saved.")
        }
        catch {
            self.saveStatus.send(false)
            print("Error saving vip user -- \(error)")
        }
        
    }
    
}
