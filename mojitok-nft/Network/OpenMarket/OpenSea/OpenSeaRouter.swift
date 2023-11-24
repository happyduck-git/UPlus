//
//  OpenSeaRouter.swift
//  mojitok-nft
//
//  Created by GAMZA on 2022/02/03.
//

import Foundation
import Alamofire

//"https://api.opensea.io/api/v1/assets"
//"https://api.opensea.io/api/v1/assets?owner=0x91582cb98902b5d14bd89ba69c85bfef4613b448&limit=20&offset=0"
enum OpenseaRouter: URLRequestConvertible {
    case nft(address: String, limit: Int, offset: Int, orderBy: String?)
    case collectionNFTs(String, String)
    case collection(String)
    case collections(String)
    
    private var baseURL: String {
        #if DEBUG
        return "https://api.opensea.io/api/v1"
        #else
        return "https://api.opensea.io/api/v1"
        #endif
    }
    
    private var method: HTTPMethod {
        switch self {
        case .nft, .collectionNFTs, .collection, .collections:
            return .get
        }
    }
    
    private var path: String {
        switch self {
        case .nft:
            return "/assets"
        case .collectionNFTs:
            return "/assets"
        case .collection(let slug):
            return "/collection/\(slug)"
        case .collections:
            return "/collections"
        }
    }
    
    private var parameters: Parameters? {
        switch self {
        default:
            return nil
        }
    }
    
    private var queryString: [URLQueryItem] {
        switch self {
        case .nft(let address, let limit, let offset, let orderBy):
            var query: [URLQueryItem] = [
                .init(name: "owner", value: address),
                .init(name: "limit", value: "\(limit)"),
                .init(name: "offset", value: "\(offset)")
            ]
            if let orderBy = orderBy {
                query.append(.init(name: "order_by", value: orderBy))
            }
            return query
        case .collectionNFTs(let address, let collectionSlug):
            return [
                .init(name: "owner", value: address),
                .init(name: "collection_slug", value: collectionSlug)
            ]
        case .collections(let owner):
            return [
                .init(name: "asset_owner", value: owner),
                .init(name: "offset", value: "0"),
                .init(name: "limit", value: "300")
            ]
        case .collection:
            return []
        }
    }
    
    private var headers: [String: String] {
        switch self {
        default:
            return ["X-API-KEY": "64d6b01887b24e9fb2e9cf39eb00ef27"]
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        var urlComponents = URLComponents(string: baseURL + path)
        // MARK: - QueryString
        urlComponents?.queryItems = queryString
        // MARK: - URL
        let url = urlComponents?.url
        var urlRequest = URLRequest(url: url!)
        // MARK: - Method
        urlRequest.httpMethod = method.rawValue
        // MARK: - Header
        for (key, value) in headers {
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        // MARK: - Parameters
        if let parameters = parameters {
            if let body = try? JSONSerialization.data(withJSONObject: parameters, options: []) {
                urlRequest.httpBody = body
            }
        }
        return urlRequest
    }
}
