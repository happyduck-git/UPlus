//
//  GiftViewControllerViewViewModel.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/18.
//

import Foundation
import OSLog

final class GiftViewControllerViewViewModel {
    private let logger = Logger()
    
    private let firestoreManager = FirestoreManager.shared
    private let nftServiceManager = NFTServiceManager.shared
    
    let nft: UPlusNft
    
    @Published var username: String = ""
    var receiverUserIndex: Int64?
    
    init(nft: UPlusNft) {
        self.nft = nft
    }
    
}

extension GiftViewControllerViewViewModel {
    
    func checkIsValidEmail(username: String) async -> Bool {
        do {
            /* let email = username + LoginConstants.uplusEmailSuffix */
            /* DEV */
            let email = username + SignUpConstants.emailSuffix
            let (isAccountable, _) = try await firestoreManager.isAccountable(email: email)
            return isAccountable
        }
        catch {
            self.logger.error("Error checking email validation -- \(String(describing: error))")
            return false
        }
    }
    
    /// Transfer a raffle nft to other user.
    /// - Parameters:
    ///   - receiver: Person to receive nft.
    ///   - tokenId: Nft token id.
    func sendNft() async -> Bool {

        do {
            let user = try UPlusUser.getCurrentUser()
            let response = try await self.nftServiceManager.requestNftTransfer(from: user.userIndex,
                                                                               to: self.receiverUserIndex ?? 0,
                                                                               tokenId: self.nft.nftTokenId)
            let status = NFTServiceStatus(rawValue: response.data.status) ?? .fail
            
            switch status {
            case .pending:
                logger.info("Send nft success -- \(String(describing: response.data))")
                return true
            case .fail:
                logger.info("Send nft fail -- \(String(describing: response.data))")
                return false
            }
        }
        catch {
            if error is NFTServiceError {
                let err = error as? NFTServiceError
                switch err {
                case .senderError:
                    // TODO: Sender Error인 경우 UI에 alert 표시
                    break
                default:
                    break
                }
            }
            
            logger.error("Error requesting nft transfer -- \(String(describing: error))")
            return false
        }
    }
    
}
