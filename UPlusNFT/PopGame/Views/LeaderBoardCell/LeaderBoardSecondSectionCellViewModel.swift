//
//  LeaderBoardTableViewCellViewModel.swift
//  Aftermint
//
//  Created by Platfarm on 2023/03/17.
//

import UIKit.UIImage
import Combine
import DifferenceKit

protocol LeaderBoardSecondSectionCellListViewModelDelegate: AnyObject {
    func currentUserDataFetched(_ vm: LeaderBoardSecondSectionCellViewModel)
    func differentFunction()
}

final class LeaderBoardSecondSectionCellListViewModel {
    
    weak var delegate: LeaderBoardSecondSectionCellListViewModelDelegate?
    
    private let fireStoreManager = FirestoreManager.shared
    @Published var leaderBoardVMList: [LeaderBoardSecondSectionCellViewModel] = []
//    let leaderBoardVMList: Box<[LeaderBoardSecondSectionCellViewModel]> = Box([])
    
    // MARK: - Init
    init() {
      
    }
    
    // MARK: - Public
    func numberOfRowsInSection() -> Int {
        return self.leaderBoardVMList.count
    }
    
    func modelAt(_ indexPath: IndexPath) -> LeaderBoardSecondSectionCellViewModel? {
        return self.leaderBoardVMList[indexPath.row]
    }
    
    /// Get initial address section view model.
    func getInitialAddressSectionVM(of collectionType: CollectionType, gameType: GameType) async throws -> [LeaderBoardSecondSectionCellViewModel]? {
        do {
            let user = try UPlusUser.getCurrentUser()
            
            let users = try await fireStoreManager.getUsers()
            let gameData = try await fireStoreManager.getAllUserGameScore()
            
            var gameUsers: [GameUser] = []
            for gameDatum in gameData {
                for user in users {
                    let address = user.userWalletAddress ?? "no-address"
                    if address == gameDatum.address {
                        gameUsers.append(
                            GameUser(ownerAddress: gameDatum.address,
                                     actionCount: gameDatum.actionCount,
                                     popScore: gameDatum.popScore,
                                     profileImageUrl: "profile-image",
                                     userIndex: String(describing: user.userIndex),
                                     ownedNFTs: user.userNfts)
                        )
                    }
                }
            }
            
            guard let rankImage = UIImage(named: ImageAssets.goldTrophy) else { return [] }
            let initialRank = 1
            
            let viewModels = gameUsers.map { address in
                let viewModel = LeaderBoardSecondSectionCellViewModel(
                    ownerAddress: address.ownerAddress,
                    rankImage: rankImage,
                    rank: initialRank,
                    userProfileImage: address.profileImageUrl,
                    topLabelText: address.ownerAddress,
                    bottomLabelText: "\(String(describing: address.ownedNFTs?.count ?? 0))",
                    actionCount: address.actionCount,
                    popScore: address.popScore
                )
                
                if address.ownerAddress == user.userWalletAddress ?? "no-address" {
                    self.delegate?.currentUserDataFetched(viewModel)
                }
          
                return viewModel
            }
           
            self.leaderBoardVMList = viewModels
            
            return viewModels
             
        }
        catch {
            UPlusLogger.logger.error("Error getting initial address section vm of -- \(String(describing: error))")
            return nil
        }
        
    }
    
    func getCachedAddressSectionVM(of collectionType: CollectionType, gameType: GameType) async throws -> [LeaderBoardSecondSectionCellViewModel]? {
        let user = try UPlusUser.getCurrentUser()
        
        let users = try await fireStoreManager.getUsers()
        let gameData = try await fireStoreManager.getAllUserGameScore()
        
        var gameUsers: [GameUser] = []
        for gameDatum in gameData {
            for user in users {
                let address = user.userWalletAddress ?? "no-address"
                if address == gameDatum.address {
                    gameUsers.append(
                        GameUser(ownerAddress: gameDatum.address,
                                 actionCount: gameDatum.actionCount,
                                 popScore: gameDatum.popScore,
                                 profileImageUrl: "profile-image",
                                 userIndex: String(describing: user.userIndex),
                                 ownedNFTs: user.userNfts)
                    )
                }
            }
        }
        
        guard let rankImage = UIImage(named: ImageAssets.goldTrophy) else { return [] }
        let initialRank = 1
        
        let viewModels = gameUsers.map { address in
            let viewModel = LeaderBoardSecondSectionCellViewModel(
                ownerAddress: address.ownerAddress,
                rankImage: rankImage,
                rank: initialRank,
                userProfileImage: address.profileImageUrl,
                topLabelText: address.ownerAddress,
                bottomLabelText: "\(String(describing: address.ownedNFTs?.count ?? 0))",
                actionCount: address.actionCount,
                popScore: address.popScore
            )
            print("Bottom Label Text: \(String(describing: address.ownedNFTs?.count ?? 0))")
            if address.ownerAddress == user.userWalletAddress ?? "no-address" {
                self.delegate?.currentUserDataFetched(viewModel)
            }
      
            return viewModel
        }
       
        self.leaderBoardVMList = viewModels
        
        return viewModels
         
    }
    
    /*
    /// For using DifferenceKit
    func getCachedAddressSectionVM(
        of collectionType: CollectionType,
        gameType: GameType
    ) async throws -> [LeaderBoardSecondSectionCellViewModel]? {
        
        let addressList = try await self.fireStoreManager
            .getAllCachedAddress(gameType: .popgame)
        
        guard let addressList = addressList,
              let rankImage = UIImage(named: LeaderBoardAsset.firstPlace.rawValue)
        else {
            return nil
        }
        let initialRank = 1
        
        let viewModels = addressList.map { address in
            let viewModel = LeaderBoardSecondSectionCellViewModel(
                ownerAddress: address.ownerAddress,
                rankImage: rankImage,
                rank: initialRank,
                userProfileImage: address.profileImageUrl,
                topLabelText: address.ownerAddress,
                bottomLabelText: "\(address.ownedNFTs)",
                actionCount: address.actionCount,
                popScore: address.popScore
            )
            return viewModel
        }
       
        self.leaderBoardVMList.value = viewModels
        
        return viewModels
    }*/
    /*
    //TODO: Need to add error handler
    func getAllNftRankCellViewModels(completion: @escaping (Result<[LeaderBoardSecondSectionCellViewModel], Error>) -> ()) {
        
        let userList: [AfterMintUser] = MoonoMockUserData().getAllUserData()
        guard let rankImage = UIImage(named: LeaderBoardAsset.firstPlace.rawValue) else { return }
        let initialRank = 1
        
        let viewModels = userList.map { user in
            let viewModel: LeaderBoardSecondSectionCellViewModel =
            LeaderBoardSecondSectionCellViewModel(
                ownerAddress: user.address,
                rankImage: rankImage,
                rank: initialRank,
                userProfileImage: user.imageUrl,
                topLabelText: user.username,
                bottomLabelText: "NFTs \(user.totalNfts)",
                actionCount: user.actionCount,
                popScore: user.popCount
            )
            return viewModel
        }
        completion(.success(viewModels))
        return
    }
    */
}

//MARK: - LeaderBoardTableViewCellViewModel
final class LeaderBoardSecondSectionCellViewModel {
    let ownerAddress: String
    var rankImage: UIImage
    var rank: Int
    let userProfileImage: String
    let username: String
    let numberOfNfts: String
    let actionCount: Int64
    let popScore: Int64
    
    //MARK: - Initializer
    init(ownerAddress: String,
         rankImage: UIImage,
         rank: Int,
         userProfileImage: String,
         topLabelText: String,
         bottomLabelText: String,
         actionCount: Int64,
         popScore: Int64
    ) {
        self.ownerAddress = ownerAddress
        self.rankImage = rankImage
        self.rank = rank
        self.userProfileImage = userProfileImage
        self.username = topLabelText 
        self.numberOfNfts = bottomLabelText
        self.actionCount = actionCount
        self.popScore = popScore
    }
    
    //MARK: - Internal function
    func setRankImage(with image: UIImage?) {
        guard let image = image else { return }
        self.rankImage = image
    }
    
    func setRankNumberWithIndexPath(_ indexPathRow: Int) {
        self.rank = indexPathRow
    }
    
}

extension LeaderBoardSecondSectionCellViewModel: Differentiable {
    
    var differenceIdentifier: String {
        return self.ownerAddress
    }
    
    func isContentEqual(to source: LeaderBoardSecondSectionCellViewModel) -> Bool {
        return self.actionCount == source.actionCount
    }
    
}

extension LeaderBoardSecondSectionCellViewModel: Equatable {
    static func == (lhs: LeaderBoardSecondSectionCellViewModel, rhs: LeaderBoardSecondSectionCellViewModel) -> Bool {
        if (lhs.ownerAddress == rhs.ownerAddress) && (lhs.actionCount == rhs.actionCount) {
            return true
        } else {
            return false
        }
    }
}
