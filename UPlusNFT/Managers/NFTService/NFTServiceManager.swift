//
//  NFTServiceManager.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/08/09.
//

import Foundation

/// Singleton Object Class for UPlus NFT Service
final class NFTServiceManager {
    
    //MARK: - Init
    static let shared = NFTServiceManager()
    private init() {}
    
    //MARK: - URL Constant
    private let baseUrl = "https://its-test.gall3ry.io/nft-infra"
    private let accessCode = "Bearer c2b79418-febc-4758-9172-b27a3b354705"
    private let jsonKey = "application/json"
    private let headerFieldAuthorization = "Authorization"
    private let headerFieldContentType = "Content-Type"
    
    //MARK: - NFT Contract
    private let contractAddress = "0xaab65f4b433ead72c9f0275a6419ba1f413b3fa7"
}

extension NFTServiceManager {
    
    /// Request to issue one nft for a cetain user.
    /// - Parameters:
    ///   - userIndex: User index.
    ///   - nftType: Type of Nft to be issued.
    ///   - level: Nft level, if needed.
    /// - Returns: NFTResponse.
    func requestSingleNft(userIndex: Int64,
                          nftType: UPlusNftDetailType,
                          level: Int = 0) async throws -> NFTResponse {
        var type = nftType.rawValue
        
        if nftType.rawValue.hasSuffix("%d") {
            type = String(format: nftType.rawValue, level)
        }
        
        let urlRequest = try self.buildUrlRequest(
            method: .post,
            endPoint: .issue,
            requestBody: [
                "userIndex": userIndex,
                "type": type
            ]
        )
        
        return try await NetworkServiceManager.execute(expecting: NFTResponse.self,
                            request: urlRequest)
    }
    
    /// Request to transfer one nft to other user.
    /// - Parameters:
    ///   - senderIndex: Sender's user index.
    ///   - receiverIndex: Reciever's user index.
    ///   - tokenId: NFT token id.
    /// - Returns: NFTTransferResponse.
    func requestNftTransfer(from senderIndex: Int64,
                            to receiverIndex: Int64,
                            tokenId: Int64) async throws -> NFTResponse {
        let urlRequest = try self.buildUrlRequest(
            method: .post,
            endPoint: .transfer,
            requestBody: [
                "from": senderIndex,
                "to": receiverIndex,
                "tokenId": tokenId
            ]
        )
        
        return try await NetworkServiceManager.execute(expecting: NFTResponse.self,
                            request: urlRequest)
    }
    
}

//MARK: - Private
extension NFTServiceManager {
    
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
    }
    
    enum NFTEndPoint: String {
        case status
        case issue
        case multiissue
        case transfer
        case reclaim
        case multireclaim
    }
    
    private func buildUrlRequest(method: HTTPMethod,
                                 endPoint: NFTEndPoint,
                                 pathComponents: [String] = [],
                                 queryParameters: [URLQueryItem] = [],
                                 requestBody: [String: Any])
    throws -> URLRequest {
        
        var urlString = self.baseUrl + "/" + endPoint.rawValue
        
        if !pathComponents.isEmpty {
            pathComponents.forEach {
                urlString += "/\($0)"
            }
        }
        
        if !queryParameters.isEmpty {
            urlString += "?"
            let argumentString = queryParameters.compactMap {
                guard let value = $0.value else { return nil }
                return "\($0.name)=\(value)"
            }.joined(separator: "&")
            
            urlString += argumentString
        }
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        urlRequest.addValue(jsonKey, forHTTPHeaderField: headerFieldContentType)
        urlRequest.addValue(accessCode, forHTTPHeaderField: headerFieldAuthorization)
        urlRequest.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        return urlRequest
    }

}

struct NFTResponse: Decodable {
    let statusCode: Int
    let data: NFTResponseData
}

struct NFTResponseData: Decodable {
    let status: String
    let requestId: String?
    let message: String?
}

