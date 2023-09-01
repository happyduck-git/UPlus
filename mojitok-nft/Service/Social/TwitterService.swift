//
//  TwitterService.swift
//  mojitok-nft
//
//  Created by 김진우 on 2022/05/24.
//

import Foundation
import CommonCrypto
import Alamofire
import OAuthSwift
import UIKit

final class TwitterService {
    
    static let shared = TwitterService()
    static let twitterURLScheme = "gall3ry3"

    private let consumerKey = "evrxaJ2s8YBjs6rvf4xd7OrbQ"
    private let consumerSecret = "QN1EhM13zpAWsjg1OPjiq9gAQ5qRFA8fpCn0milthdtfPYfZyS"
    private let queue = DispatchQueue(label: "TwitterService.MediaUpload.Append", attributes: .concurrent)
    private let twitterClient: TwitterClient
    private let twitterUtility: TwitterUtility
    private let userService: UserService
    private let chunkMaxSize = 4194304
    
    var callbackObserver: Any? {
        willSet {
            guard let token = callbackObserver else { return }
            NotificationCenter.default.removeObserver(token)
        }
    }
    
    // MARK: - Init
    init() {
        twitterClient = .shared
        twitterUtility = .shared
        userService = .shared
    }
    
    // Method
    func tweet(accessTokenWithSecret: AccessTokenWithSecret, twitterTweet form: TwitterTweetForm) -> String? {
        let semaphore = DispatchSemaphore(value: 0)
        var resultURLString: String?
        if let data = form.art.data {
            DispatchQueue.global().async { [weak self] in
                guard let self = self else {
                    semaphore.signal()
                    return
                }
                let fileName = form.art.fileName
                let mediaType = form.art.mediaType == .image ? "image/jpeg" : "video/mov"
                let category = form.art.mediaType == .image ? "TweetImage" : "amplify_video"
                let authInfo = AuthInfo(consumerKey: self.consumerKey, consumerSecret: self.consumerSecret, accessToken: accessTokenWithSecret.token, accessTokenSecret: accessTokenWithSecret.secret)
                print("Request: Init")
                let (mediaID, error) = TwitterClient.shared.mediaUploadInit(authInfo: authInfo, mediaType: mediaType, bytes: data.count, category: category)
                
                if let mediaID = mediaID {
                    let returnResult = self.uploadMediaChunk(data: data, authInfo: authInfo, fileName: fileName, mediaType: mediaType, mediaID: mediaID)
                    
                    if returnResult {
                        print("Request: Finalize")
                        let (resultMediaID, error) = TwitterClient.shared.mediaUploadFinalize(authInfo: authInfo, mediaID: mediaID)
                        var result = true
                        if form.art.mediaType == .image {
                            result = false
                        }
                        while result {
                            let (response, _) = TwitterClient.shared.mediaUploadStatus(authInfo: authInfo, mediaID: mediaID)
                            if response?.status == .success {
                                result = false
                                dump(response!)
                            } else {
                                print("Request: Processing")
                            }
                            sleep(1)
                        }
                        if let urlString = TwitterClient.shared.tweet(authInfo: authInfo, text: form.text, mediaID: mediaID) {
                            print("Tweet url: \(urlString)")
                            resultURLString = urlString
                        } else if let error = error,
                                  error.kind == .expiredToken {
                            self.removeToken()
                        }
                        semaphore.signal()
                    } else if let error = error,
                              error.kind == .expiredToken {
                        self.removeToken()
                        semaphore.signal()
                    }
                } else if let error = error,
                          error.kind == .expiredToken {
                    self.removeToken()
                    semaphore.signal()
                }
            }
        }
        semaphore.wait()
        return resultURLString
    }
    
    private func uploadMediaChunk(data: Data, authInfo: AuthInfo, fileName: String, mediaType: String, mediaID: String) -> Bool {
        let semaphore = DispatchSemaphore(value: 0)
        let resultQueue = DispatchQueue(label: "ResultQueue", attributes: .concurrent)
        let group = DispatchGroup()
        var returnResult = true
        for segmentIndex in (0...(data.count / chunkMaxSize)) {
            let realIndex = chunkMaxSize * segmentIndex
            var currentData = Data()
            if realIndex + chunkMaxSize > data.count {
                let range: Range = (realIndex..<data.count)
                currentData = data.subdata(in: range)
            } else {
                let range = (realIndex..<realIndex + chunkMaxSize)
                currentData = data.subdata(in: range)
            }
            queue.async(group: group) {
                print("Request Chunp: \(segmentIndex)")
                let (result, error) = TwitterClient.shared.mediaUploadAppend(authInfo: authInfo, data: currentData, fileName: fileName, mimeType: mediaType, mediaID: mediaID, segment: segmentIndex)
                resultQueue.sync {
                    if !result {
                        returnResult = false
                    } else {
                        dump(error)
                    }
                }
            }
        }
        
        group.notify(queue: queue) {
            semaphore.signal()
        }
        semaphore.wait()
        return returnResult
    }
    
    func login() -> TwitterAccount? {
        if let response = authorize(),
           var user = userService.getUsers().first {
            let token = AccessTokenWithSecret(token: response.accessToken, secret: response.accessTokenSecret)
            if let tokenData = try? JSONEncoder().encode(token) {
                let twitterAccount = TwitterAccount(id: response.userId, token: .init(kind: .accessTokenWithSecret, tokenData: tokenData), name: response.screenName)
                let archiveAccount = ArchiveAccount(id: twitterAccount.id, token: twitterAccount.token, name: twitterAccount.name)
                user.socialAccount = archiveAccount
                userService.update(user)
                return twitterAccount
            }
        }
        return nil
    }
    
    func logout() {
        if var user = userService.getUsers().first {
            user.socialAccount = nil
            userService.update(user)
        }
    }
    
    private func removeToken() {
        if var user = userService.getUsers().first {
            user.socialAccount = nil
            userService.update(user)
        }
    }
    
    func authorize() -> AccessTokenResponse? {
        let semaphore = DispatchSemaphore(value: 0)
        let oAuthTokenInput = OAuthTokenInput(consumerKey: self.consumerKey, consumerSecret: self.consumerSecret, callbackScheme: TwitterService.twitterURLScheme)
        var credential: AccessTokenResponse?
        
        DispatchQueue.global().async {
            let oAuthTokenResponse = self.twitterClient.oauthToken(input: oAuthTokenInput)
            
            self.callbackObserver = NotificationCenter.default.addObserver(forName: .twitterCallback, object: nil, queue: nil) { notification in
                self.callbackObserver = nil // remove notification observer
                guard let url = notification.object as? URL,
                      let parameters = url.query?.urlQueryStringParameters,
                      let verifier = parameters["oauth_verifier"] else {
                    return
                }
                // Start Step 3: Request Access Token
                let accessTokenInput = AccessTokenInput(consumerKey: self.consumerKey,
                                                               consumerSecret: self.consumerSecret,
                                                               requestToken: oAuthTokenResponse!.oauthToken,
                                                               requestTokenSecret: oAuthTokenResponse!.oauthTokenSecret,
                                                               oauthVerifier: verifier)
                DispatchQueue.global().async {
                    if let accessTokenResponse = self.twitterClient.accessToken(accessTokenInput: accessTokenInput) {
                        print(" ----> authorize \(accessTokenResponse)")
                        credential = accessTokenResponse
                        semaphore.signal()
                    }
                }
            }
                                                
            let urlString = "https://api.twitter.com/oauth/authorize?oauth_token=\(oAuthTokenResponse!.oauthToken)"
            guard let oauthUrl = URL(string: urlString) else { return }
            self.presentLoginWebView(url: oauthUrl)
        }
        semaphore.wait()
        return credential
    }
    
    private func presentLoginWebView(url: URL) {
        DispatchQueue.main.async {
            let safariVC = SafariViewController()
            safariVC.url = url
            UIApplication.shared.windows.filter { $0.isKeyWindow }.first?.rootViewController?.present(safariVC, animated: true)
        }
    }
}
