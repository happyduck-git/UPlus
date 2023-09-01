//
//  TwitterClient.swift
//  mojitok-nft
//
//  Created by 김진우 on 2022/05/23.
//

import Foundation
import Alamofire
import OhhAuth

final class TwitterClient {
    
    public static let shared = TwitterClient()
    
    private init() {}
    
    func oauthToken(input: OAuthTokenInput) -> OAuthTokenResponse? {
        let semaphore = DispatchSemaphore(value: 0)
        var result: OAuthTokenResponse!
        AF.request(TwitterRouter.oauthToken(consumerKey: input.consumerKey, consumerSecret: input.consumerSecret, callbackScheme: input.callbackScheme))
            .responseData { response in
                if let data = response.data,
                   let dataString = String(data: data, encoding: .utf8) {
                    let attributes = dataString.urlQueryStringParameters
                    result = OAuthTokenResponse(oauthToken: attributes["oauth_token"] ?? "", oauthTokenSecret: attributes["oauth_token_secret"] ?? "", oauthCallbackConfirmed: attributes["oauth_callback_confirmed"] ?? "")
                    semaphore.signal()
                }
            }
        semaphore.wait()
        return result
    }
    
    func accessToken(accessTokenInput: AccessTokenInput) -> AccessTokenResponse? {
        let semaphore = DispatchSemaphore(value: 0)
        var result: AccessTokenResponse!
        
        AF.request(TwitterRouter.accessToken(accessTokenInput: accessTokenInput))
            .responseData { response in
                if let data = response.data,
                   let dataString = String(data: data, encoding: .utf8) {
                    let attributes = dataString.urlQueryStringParameters
                    result = AccessTokenResponse(accessToken: attributes["oauth_token"] ?? "", accessTokenSecret: attributes["oauth_token_secret"] ?? "", userId: attributes["user_id"] ?? "", screenName: attributes["screen_name"] ?? "")
                    semaphore.signal()
                }
            }
        semaphore.wait()
        return result
    }
    
    
    func mediaUploadInit(authInfo: AuthInfo, mediaType: String, bytes: Int, category: String) -> (String?, G3Error?) {
        let semaphore = DispatchSemaphore(value: 0)
        var mediaID: String?
        var resultError: G3Error?
        var req = URLRequest(url: URL(string: "https://upload.twitter.com/1.1/media/upload.json?command=INIT&media_type=\(mediaType.urlEncoded)&total_bytes=\(bytes)&media_category=\(category)")!)
        req.httpMethod = "POST"
        req.oAuthSign(method: "POST", urlFormParameters: [:], consumerCredentials: (key: authInfo.consumerKey, secret: authInfo.consumerSecret), userCredentials: (key: authInfo.accessToken, secret: authInfo.accessTokenSecret))
        let task = URLSession(configuration: .ephemeral).dataTask(with: req) { [weak self] (data, response, error) in
            guard let self = self else {
                resultError = .init(kind: .fail, moreInfo: "self reference error")
                semaphore.signal()
                return
            }
            if let error = error {
                resultError = .init(kind: .requestInvalid, moreInfo: error.localizedDescription)
            } else  if let data = data {
                if let mediaUploadResponse = try? JSONDecoder().decode(MediaUploadInitResponse.self, from: data) {
                    mediaID = mediaUploadResponse.mediaIDString
                } else if let twitterError = try? JSONDecoder().decode(TwitterError.self, from: data) {
                    if let firstError = twitterError.errors.first {
                        resultError = .init(kind: .expiredToken, moreInfo: firstError.message)
                    } else {
                        resultError = .init(kind: .fail, moreInfo: "Twitter error: Empty error info")
                    }
                } else if let urlResponse = response as? HTTPURLResponse {
                    resultError = self.statusCodeToG3Error(statusCode: urlResponse.statusCode)
                }
            }
            semaphore.signal()
        }
        task.resume()
        semaphore.wait()
        return (mediaID, resultError)
    }
    
    func mediaUploadAppend(authInfo: AuthInfo, data: Data, fileName: String, mimeType: String, mediaID: String, segment: Int) -> (Bool, G3Error?) {
        let semaphore = DispatchSemaphore(value: 0)
        var result: Bool = false
        var resultError: G3Error?
        
        var req = URLRequest(url: URL(string: "https://upload.twitter.com/1.1/media/upload.json?command=APPEND&media_id=\(mediaID)&segment_index=\(segment)")!)
        req.oAuthSign(method: "POST", urlFormParameters: [:], consumerCredentials: (key: authInfo.consumerKey, secret: authInfo.consumerSecret), userCredentials: (key: authInfo.accessToken, secret: authInfo.accessTokenSecret))
        req.httpMethod = "POST"
        let boundary = "--------------------------182849347276580981262231"
        req.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var formData = Data()
        formData.append("--\(boundary)\r\n".data(using: .utf8)!)
        formData.append("Content-Disposition: form-data; name=\"media\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        formData.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        formData.append(data)
        formData.append("\r\n".data(using: .utf8)!)
        formData.append("--\(boundary)--\r\n".data(using: .utf8)!)
        req.httpBody = formData
        let task = URLSession(configuration: .ephemeral).dataTask(with: req) { [weak self] (data, response, error) in
            guard let self = self else {
                resultError = .init(kind: .fail, moreInfo: "self reference error")
                semaphore.signal()
                return
            }
            if let urlResponse = response as? HTTPURLResponse {
                let remainderStatusCode = urlResponse.statusCode - 200
                if remainderStatusCode >= 0,
                    remainderStatusCode < 100 {
                    result = true
                } else {
                    resultError = self.statusCodeToG3Error(statusCode: urlResponse.statusCode)
                }
            } else if let error = error {
                resultError = .init(kind: .requestInvalid, moreInfo: error.localizedDescription)
            }
            semaphore.signal()
        }
        task.resume()
        semaphore.wait()
        return (result, resultError)
    }
    
    func mediaUploadStatus(authInfo: AuthInfo, mediaID: String) -> (TwitterUploadStatusResponse?, G3Error?) {
        let semaphore = DispatchSemaphore(value: 0)
        var result: TwitterUploadStatusResponse?
        var resultError: G3Error?
        
        var req = URLRequest(url: URL(string: "https://upload.twitter.com/1.1/media/upload.json?command=STATUS&media_id=\(mediaID)")!)
        req.httpMethod = "GET"
        req.oAuthSign(method: "GET", urlFormParameters: [:], consumerCredentials: (key: authInfo.consumerKey, secret: authInfo.consumerSecret), userCredentials: (key: authInfo.accessToken, secret: authInfo.accessTokenSecret))
        let task = URLSession(configuration: .ephemeral).dataTask(with: req) { [weak self] (data, response, error) in
            guard let self = self else {
                resultError = .init(kind: .fail, moreInfo: "self reference error")
                semaphore.signal()
                return
            }
            if let data = data {
                if let twitterUploadStatusResponse = try? JSONDecoder().decode(TwitterUploadStatusResponse.self, from: data) {
                    result = twitterUploadStatusResponse
                } else if let twitterError = try? JSONDecoder().decode(TwitterError.self, from: data) {
                    if let firstError = twitterError.errors.first {
                        resultError = .init(kind: .expiredToken, moreInfo: firstError.message)
                    } else {
                        resultError = .init(kind: .fail, moreInfo: "Twitter error: Empty error info")
                    }
                } else if let urlResponse = response as? HTTPURLResponse {
                    resultError = self.statusCodeToG3Error(statusCode: urlResponse.statusCode)
                }
            } else if let error = error {
                resultError = .init(kind: .requestInvalid, moreInfo: error.localizedDescription)
            }
            semaphore.signal()
        }
        task.resume()
        semaphore.wait()
        return (result, resultError)
    }
    
    func mediaUploadFinalize(authInfo: AuthInfo, mediaID: String) -> (String?, G3Error?) {
        let semaphore = DispatchSemaphore(value: 0)
        var resultMediaID: String?
        var resultError: G3Error?
        
        var req = URLRequest(url: URL(string: "https://upload.twitter.com/1.1/media/upload.json?command=FINALIZE&media_id=\(mediaID)")!)
        req.httpMethod = "POST"
        req.oAuthSign(method: "POST", urlFormParameters: [:], consumerCredentials: (key: authInfo.consumerKey, secret: authInfo.consumerSecret), userCredentials: (key: authInfo.accessToken, secret: authInfo.accessTokenSecret))
        let task = URLSession(configuration: .ephemeral).dataTask(with: req) { [weak self] (data, response, error) in
            guard let self = self else {
                resultError = .init(kind: .fail, moreInfo: "self reference error")
                semaphore.signal()
                return
            }
            if let data = data {
                if let mediaUploadResponse = try? JSONDecoder().decode(MediaUploadInitResponse.self, from: data) {
                    resultMediaID = mediaUploadResponse.mediaIDString
                } else if let twitterError = try? JSONDecoder().decode(TwitterError.self, from: data) {
                    if let firstError = twitterError.errors.first {
                        resultError = .init(kind: .expiredToken, moreInfo: firstError.message)
                    } else {
                        resultError = .init(kind: .fail, moreInfo: "Twitter error: Empty error info")
                    }
                } else if let urlResponse = response as? HTTPURLResponse {
                    resultError = self.statusCodeToG3Error(statusCode: urlResponse.statusCode)
                }
            } else if let error = error {
                resultError = .init(kind: .requestInvalid, moreInfo: error.localizedDescription)
            }
            semaphore.signal()
        }
        task.resume()
        semaphore.wait()
        return (resultMediaID, resultError)
    }
    
    func tweet(authInfo: AuthInfo, text: String, mediaID: String) -> String? {
        let semaphore = DispatchSemaphore(value: 0)
        var tweetURLString: String?
        var req = URLRequest(url: URL(string: "https://api.twitter.com/1.1/statuses/update.json?status=\(text.urlEncoded)&media_ids=\(mediaID)")!)
        req.httpMethod = "POST"
        req.oAuthSign(method: "POST", urlFormParameters: [:], consumerCredentials: (key: authInfo.consumerKey, secret: authInfo.consumerSecret), userCredentials: (key: authInfo.accessToken, secret: authInfo.accessTokenSecret))
        let task = URLSession(configuration: .ephemeral).dataTask(with: req) { (data, response, error) in
            if let data = data {
                if let tweetResponse = try? JSONDecoder().decode(TweetResponse.self, from: data),
                   let urlString = tweetResponse.entities.urls.first?.display_url {
                    tweetURLString = urlString
                } else {
                }
            } else if let error = error {
                print(error.localizedDescription)
            }
            semaphore.signal()
        }
        task.resume()
        semaphore.wait()
        return tweetURLString
    }
    
    private func statusCodeToG3Error(statusCode: Int) -> G3Error? {
        switch statusCode {
        case 400...499:
            return .init(kind: .requestInvalid)
        case 500...599:
            return .init(kind: .serverError)
        default:
            return nil
        }
    }
}
