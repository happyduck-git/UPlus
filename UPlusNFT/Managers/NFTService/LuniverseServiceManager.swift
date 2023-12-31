//
//  LuniverseServiceManager.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/08/10.
//

import Foundation

final actor LuniverseServiceManager {
    //MARK: - Init
    static let shared = LuniverseServiceManager()
    private init() {}
    
    //MARK: - URL Constant
    private let baseUrl = "https://web3.luniverse.io/v1"
    private let jsonKey = "application/json"
    private let acceptKey = "application/json"
    private let headerFieldAuthorizationKey = "Authorization"
    private let headerFieldContentTypeKey = "Content-Type"

    var authorizationKey: String?
    
    //MARK: - X-Keys
    private let xNodeIdKey = "X-NODE-ID"
    private let xNodeIdValue = EnvironmentConfig.xNodeId
    private let xKeyIdKey = "X-Key-ID"
    private let xKeyIdValue = EnvironmentConfig.xKeyId
    private let xKeySecretKey = "X-Key-Secret"
    private let xKeySecretValue = EnvironmentConfig.xKeySecretValue
    
    //MARK: - NFT Contract
    private let contractAddressKey = "contractAddress"
    private let contractAddressValue = EnvironmentConfig.uplusContractAddress
    private let ownerAddressKey = "ownerAddress"
}

extension LuniverseServiceManager {
    func requestAccessToken() async throws -> String {

        let urlRequest = try self.buildUrlRequest(
            method: .post,
            endPoint: .auth,
            requests: [
                xNodeIdKey: xNodeIdValue,
                xKeyIdKey: xKeyIdValue,
                xKeySecretKey: xKeySecretValue
            ]
        )
        
        do {
            let response = try await NetworkServiceManager.execute(expecting: LuniverseAuthResponse.self, request: urlRequest)
            
            self.authorizationKey = response.accessToken
            return response.accessToken
        }
        catch {
            print("Error -- \(error)")
            throw LuniverseServiceError.errorAuthetication
        }
        
    }
    
    func requestNftList(authKey: String, walletAddress: String) async throws -> LuniverseNftListResponse {
        let urlRequest = try self.buildUrlRequest(
            method: .post,
            endPoint: .listNft,
            requests: [
                headerFieldAuthorizationKey: "Bearer " + authKey
            ],
            requestBody: [
                contractAddressKey: contractAddressValue,
                ownerAddressKey: walletAddress
            ]
        )
        
        let response = try await NetworkServiceManager.execute(expecting: LuniverseNftListResponse.self, request: urlRequest)
        
        return response
    }
}

extension LuniverseServiceManager {
    
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
    }
    
    enum LuniverseEndPoint: String {
        case auth = "auth-token"
        case listNft = "polygon/mumbai/nft/listNftByOwnerAndContract"
    }
    
    private func buildUrlRequest(method: HTTPMethod,
                                 endPoint: LuniverseEndPoint,
                                 requests: [String: String] = [:],
                                 pathComponents: [String] = [],
                                 queryParameters: [URLQueryItem] = [],
                                 requestBody: [String: Any] = [:])
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
        urlRequest.allHTTPHeaderFields = requests
        
        urlRequest.addValue(acceptKey, forHTTPHeaderField: headerFieldContentTypeKey)
        
        urlRequest.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        return urlRequest
    }
}

extension LuniverseServiceManager {
    enum LuniverseServiceError: Error {
        case errorAuthetication
    }
}
