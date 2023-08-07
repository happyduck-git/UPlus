//
//  WalletViewViewModel.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/04.
//

import Foundation
import Combine

final class WalletViewViewModel {
    
    private let firestoreManager = FirestoreManager.shared
    
    var walletAddress: String = ""
    @Published var nfts: [UPlusNft] = []
    @Published var rewards: [Reward] = []
    
    init() {
        self.getNfts()
        self.getRewards()
    }
}

extension WalletViewViewModel {
    private func getNfts() {
      
            do {
                let user = try UPlusUser.getCurrentUser()
                guard let nftList = user.userNfts else { return }
                self.firestoreManager.getOwnedNfts(referenceList: nftList) { [weak self] result in
                    guard let `self` = self else { return }
                    switch result {
                    case .success(let nfts):
                        self.nfts = nfts
                        
                        for nft in nfts {
                            let type = nft.nftDetailType
                            let lastChar = type.last
                            let isNumber = lastChar?.isNumber ?? false

                            if isNumber {
                                print("type: \(self.replaceLastCharWithPercent(input: type))")
                                print(UPlusNftDetailType(rawValue: self.replaceLastCharWithPercent(input: type)))
                            } else {
                                print("type-non-number: \(type)")
                            }
                            
                        }
                    case .failure(let error):
                        print("Error fetching nfts -- \(error)")
                    }
                }
            }
            catch {
                
            }
        
    }
    
    private func getRewards() {
        do {
            let user = try UPlusUser.getCurrentUser()
            if let rewards = user.userRewards {
                self.firestoreManager.getOwnedRewards(referenceList: rewards) { [weak self] result in
                    guard let `self` = self else { return }
                    switch result {
                    case .success(let rewards):
                        self.rewards = rewards
                    case .failure(let error):
                        print("Error fetching user's rewards -- \(error)")
                    }
                }
            }
        }
        catch {
            print("Error get user info from UserDefaults -- \(error)")
        }
    }
}

extension WalletViewViewModel {
    private func replaceLastCharWithPercent(input: String) -> String {
        guard !input.isEmpty else {
            return input
        }
        
        let indexBeforeLast = input.index(before: input.endIndex)
        return input[..<indexBeforeLast] + "%"
    }
}
