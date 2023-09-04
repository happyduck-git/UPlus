//
//  LeaderBoardFirstSectionCellViewModel.swift
//  Aftermint
//
//  Created by HappyDuck on 2023/04/06.
//

import Foundation
import Combine
import DifferenceKit

enum LeaderBoardError: Error {
    case FirstSectionFetchError
    case CollectionDataNotFound
    case AddressFetchError
    case NftFetchError
    case CollectionFetchError
}

final class LeaderBoardFirstSectionCellListViewModel {
    private let fireStoreRepository = FirestoreManager.shared
//    var leaderBoardFirstSectionVMList: Box<[LeaderBoardFirstSectionCellViewModel]> = Box([])
    @Published var leaderBoardFirstSectionVMList: [LeaderBoardFirstSectionCellViewModel] = []
    var typeErasedVMList: [AnyDifferentiable] = []
    var firstSection: ArraySection<SectionID, AnyDifferentiable> = ArraySection(model: .first, elements: [])
    
    //MARK: - Internal
    func numberOfRowsInSection() -> Int {
        return self.leaderBoardFirstSectionVMList.count
    }
    
    func modelAt(_ indexPath: IndexPath) -> LeaderBoardFirstSectionCellViewModel? {
        return self.leaderBoardFirstSectionVMList[indexPath.row]
    }
    
    /// For using DifferenceKit
    func getFirstSectionVM(of collectionType: CollectionType, gameType: GameType) async throws -> LeaderBoardFirstSectionCellViewModel? {
        
        let collection = try await self.fireStoreRepository.getCurrentNftCollection(gameType: gameType)
        
//        if collection.address == collectionType.address {
            let viewModel = LeaderBoardFirstSectionCellViewModel(
                nftImage: collection.imageUrl,
                nftCollectionName: collection.name,
                totalActionCount: collection.totalActionCount,
                totalPopScore: collection.totalPopCount
            )
            if !self.leaderBoardFirstSectionVMList.isEmpty {
                self.leaderBoardFirstSectionVMList.removeFirst()
            }
            self.leaderBoardFirstSectionVMList.append(viewModel)

            return viewModel
//        }
//        return nil
    }
    
}

final class LeaderBoardFirstSectionCellViewModel {
    
    var nftImage: String
    var nftCollectionName: String
    var totalActionCount: Int64
    var totalPopScore: Int64
    
    init(nftImage: String, nftCollectionName: String, totalActionCount: Int64, totalPopScore: Int64) {
        self.nftImage = nftImage
        self.nftCollectionName = nftCollectionName
        self.totalActionCount = totalActionCount
        self.totalPopScore = totalPopScore
    }
}

extension LeaderBoardFirstSectionCellViewModel: Differentiable {
    var differenceIdentifier: String {
        return self.nftCollectionName
    }
    
    func isContentEqual(to source: LeaderBoardFirstSectionCellViewModel) -> Bool {
        return self.totalActionCount == source.totalActionCount
    }
}
