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
    var isOnlyAvatar: Bool = true
    
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
                        
                        var highestAvatar: UPlusNft?
                        var highestRaffle: UPlusNft?
                        var nftsToShow: [UPlusNft?] = []
                        
                        for nft in nfts {
                            
                            // find avatar or journey nft
                            let numberedNft = nft.nftDetailType.contains {
                                $0.isNumber
                            }
                            
                            var detailType: String = ""
                            
                            if numberedNft {
                                detailType = self.replaceLastCharWithPercent(input: nft.nftDetailType)
                            } else {
                                detailType = nft.nftDetailType
                            }
                            
                            let nftType = UPlusNftDetailType(rawValue: detailType) ?? .avatar
                            
                            if nftType != .avatar {
                                self.isOnlyAvatar.toggle()
                            }
 
                            switch nftType {
                            case .avatar:
                                let currentHighest = highestAvatar?.nftTokenId ?? 0
                                if currentHighest < nft.nftTokenId {
                                    highestAvatar = nft
                                }
                              
                            case .raffleBronze, .raffleSilver, .raffleGold:
                                let currentHighest = highestRaffle?.nftTokenId ?? 0
                                if currentHighest < nft.nftTokenId {
                                    highestRaffle = nft
                                }
                                
                            default:
                                nftsToShow.append(nft)
                                
                            }
                            
                        }
                        
                        nftsToShow.append(highestAvatar)
                        nftsToShow.append(highestRaffle)
                        
                        let compactMappedNfts = nftsToShow.compactMap { $0 }
                        self.nfts = compactMappedNfts
                        
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
        return input[..<indexBeforeLast] + "%d"
    }
}
