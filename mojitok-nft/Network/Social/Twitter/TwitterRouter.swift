//
//  TwitterRouter.swift
//  mojitok-nft
//
//  Created by 김진우 on 2022/05/23.
//

import Foundation
import Alamofire

enum TwitterRouter: URLRequestConvertible {
    case oauthToken(consumerKey: String, consumerSecret: String, callbackScheme: String)
    case accessToken(accessTokenInput: AccessTokenInput)
//    case imageUpload(authInfo: AuthInfo)
    case mediaUploadInit(authInfo: AuthInfo, mediaType: String, bytes: Int)
    case mediaUploadAppend(authInfo: AuthInfo, mediaID: String)
    case mediaUploadStatus(authInfo: AuthInfo, mediaID: String)
    case mediaUploadFinalize(authInfo: AuthInfo, mediaID: String)
    case tweetPost(String)
    
    private var baseURL: String {
        switch self {
        case .oauthToken, .accessToken, .tweetPost:
            #if DEBUG
            return "https://api.twitter.com"
            #else
            return "https://api.twitter.com"
            #endif
        case .mediaUploadInit, .mediaUploadAppend, .mediaUploadStatus, .mediaUploadFinalize:
            return "https://upload.twitter.com/1.1"
        case .tweetPost:
            return ""
        }
    }
    
    private var method: HTTPMethod {
        switch self {
        default:
            return .post
        }
    }
    
    private var path: String {
        switch self {
        case .oauthToken:
            return "/oauth/request_token"
        case .accessToken:
            return "/oauth/access_token"
        case .mediaUploadInit, .mediaUploadAppend, .mediaUploadStatus, .mediaUploadFinalize:
            return "/media/upload.json"
        case .tweetPost:
            return "/statuses/update.json"
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
        case let .mediaUploadInit(_, mediaType, bytes):
            return [
                .init(name: "command", value: "INIT"),
                .init(name: "media_type", value: "video/mp4"),
                .init(name: "oauth_consumer_key", value: "4RuGoeeXZW49jAujRMdonMatX"),
                .init(name: "oauth_nonce", value: "llkOIXhbnDhM7bMytMofCjr7wdDLGYLy"),
                .init(name: "oauth_signature_method", value: "HMAC-SHA1"),
                .init(name: "oauth_timestamp", value: "1655346469"),
                .init(name: "oauth_token", value: "1526149031067791360-Fk3U1ooSyLQVWInPtlZopgXevGzK13"),
                .init(name: "oauth_version", value: "1.0A"),
                .init(name: "total_bytes", value: "\(bytes)"),
                .init(name: "oauth_signature", value: "2bO5uCjdFyjiDoWDe0gJP2aAKOc%3D")
            ]
        case let .mediaUploadAppend(_, mediaID):
            return [
                .init(name: "command", value: "APPEND"),
                .init(name: "media_id", value: mediaID),
                .init(name: "segment_index", value: "0")
            ]
        case let .mediaUploadStatus(_, mediaID):
            return [
                .init(name: "command", value: "STATUS"),
                .init(name: "media_id", value: mediaID)
            ]
        case let .mediaUploadFinalize(_, mediaID):
            return [
                .init(name: "command", value: "FINALIZE"),
                .init(name: "media_id", value: mediaID)
            ]
        default:
            return []
        }
    }
    
    private var headers: [String: String] {
        var headers: [String: String] = [
            "oauth_nonce" : UUID().uuidString,
            "oauth_signature_method": "HMAC-SHA1",
            "oauth_timestamp": String(Int(NSDate().timeIntervalSince1970)),
            "oauth_version": "1.0"
        ]
        let url = baseURL + path
        switch self {
        case let .oauthToken(consumerKey, consumerSecret, callbackScheme):
            headers["oauth_callback"] = callbackScheme + "://success"
            headers["oauth_consumer_key"] = consumerKey
            headers["oauth_signature"] = TwitterUtility.shared.oauthSignature(httpMethod: "POST", url: url, params: headers, consumerSecret: consumerSecret)
        case .accessToken(let accessTokenInput):
            headers["oauth_token"] = accessTokenInput.requestToken
            headers["oauth_consumer_key"] = accessTokenInput.consumerKey
            headers["oauth_verifier"] = accessTokenInput.oauthVerifier
            headers["oauth_signature"] = TwitterUtility.shared.oauthSignature(httpMethod: "POST", url: url, params: headers, consumerSecret: accessTokenInput.consumerSecret)
        case let .mediaUploadInit(authInfo, _, _):
            print("MediaUpload")
        case let .mediaUploadAppend(authInfo, _):
            headers["oauth_token"] = authInfo.accessToken
            headers["oauth_consumer_key"] = authInfo.consumerKey
            headers["oauth_signature"] = TwitterUtility.shared.oauthSignature(httpMethod: "POST", url: url, params: headers, consumerSecret: authInfo.consumerSecret, oauthTokenSecret: authInfo.accessTokenSecret)
        case let .mediaUploadStatus(authInfo, _):
            headers["o"]
        case let .mediaUploadFinalize(authInfo, _):
            headers["oauth_token"] = authInfo.accessToken
            headers["oauth_consumer_key"] = authInfo.consumerKey
            headers["oauth_signature"] = TwitterUtility.shared.oauthSignature(httpMethod: "POST", url: url, params: headers, consumerSecret: authInfo.consumerSecret, oauthTokenSecret: authInfo.accessTokenSecret)
        case .tweetPost(_):
            headers.removeAll()
        }
        return headers
    }
    
    func asURLRequest() throws -> URLRequest {
        var urlComponents = URLComponents(string: baseURL + path)
        // MARK: - QueryString
        switch self {
        default:
            urlComponents?.queryItems = queryString
        }
        // MARK: - URL
        let url = urlComponents?.url
        var urlRequest = URLRequest(url: url!)
        // MARK: - Method
        urlRequest.httpMethod = method.rawValue
        // MARK: - Header
        switch self {
        case .oauthToken, .accessToken:
            
            let authHeader = TwitterUtility.shared.authorizationHeader(params: headers)
            urlRequest.addValue(authHeader, forHTTPHeaderField: "Authorization")
        default:
            print("Pass")
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

extension TwitterRouter {
    var curlString: String {
        return self.urlRequest?.curlString ?? "Curl nil"
    }
}
