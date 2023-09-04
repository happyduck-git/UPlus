//
//  GameViewViewModel.swift
//  Aftermint
//
//  Created by HappyDuck on 2023/05/26.
//

import Foundation
import Combine

protocol GameViewViewModelDelegate: AnyObject {
    func dataSaved()
}

protocol GameViewViewModelProtocol {
    func getOwnedNfts()
    func saveScoreCache(of gameType: GameType, popScore: Int64, actionCount: Int64, ownerAddress: String) async throws
}

final class GameViewViewModel: GameViewViewModelProtocol {
    
    weak var delegate: GameViewViewModelDelegate?
    
    private let firestoreRepository = FirestoreManager.shared
    
    @Published var ownedNftTokenIds: [String] = []
//    public private(set) var ownedNftTokenIds: Box<[String]> = Box([])
    
    init() {
        self.getOwnedNfts()
    }

}

// MARK: - Private
extension GameViewViewModel {
    func getOwnedNfts() {
        do {
            let user = try UPlusUser.getCurrentUser()
            let tokenIds = user.userNfts?.compactMap({ docRef in
                return self.getTokenId(from: docRef.path)
            })
            self.ownedNftTokenIds = tokenIds ?? []
        }
        catch {
            
        }
        /*
        _ = KlaytnNftRequester
            .requestToGetMoonoNfts(walletAddress: mockUser.address)
        { [weak self] nfts in
            guard let `self` = self else { return }
            self.ownedNftTokenIds = nfts.compactMap { nft in
                let tokenId = nft.tokenId
                let convertedId = String(tokenId.convertToDecimal() ?? 0)
           
                return convertedId
            }
        }
         */
    }
    
    private func getTokenId(from path: String) -> String? {
        let components = path.components(separatedBy: "/")
        return components.last
    }
}

// MARK: - Save Game Scores to Firestore
extension GameViewViewModel {
    
    /// Save game scores during the game.
    /// - Parameters:
    ///   - popScore: Numbers of touch counted multiplied by numbers of nfts that the owner holds.
    ///   - actionCount: Numbers of touch counted.
    ///   - ownerAddress: The owner's wallet address.
    func saveScoreCache(
        of gameType: GameType,
        popScore: Int64,
        actionCount: Int64,
        ownerAddress: String
    ) async throws {
        
        try await self.firestoreRepository
            .saveScoreCache(
                of: gameType,
                popScore: popScore,
                actionCount: actionCount,
                ownerAddress: ownerAddress
            )
        
    }
    
    /// Save touch count to each of NFT that an owner holds.
    /// Especially when the game ends.
    /// - Parameters:
    ///   - actionCount: Numbers of touch counted during the game.
    ///   - nftTokenId: NFT token ids that the owner holds.
    ///   - ownerAddress: The owner's wallet address.
    func saveNFTScores(
        of gameType: GameType,
        actionCount: Int64,
        nftTokenId: [String],
        ownerAddress: String
    ) async throws {
        
        try await firestoreRepository.saveNFTScores(
            of: gameType,
            actionCount: actionCount,
            nftTokenId: nftTokenId,
            ownerAddress: ownerAddress
        )
        
    }
}
