//
//  WelcomeBottomSheetViewViewModel.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/07/19.
//

import Foundation
import Combine

final class WelcomeBottomSheetViewViewModel {
    
    //MARK: - Dependency
    private let firestoreManger = FirestoreManager.shared
    
    private(set) var saveStatus = PassthroughSubject<Bool, Never>()
    
    
}

extension WelcomeBottomSheetViewViewModel {
    
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
