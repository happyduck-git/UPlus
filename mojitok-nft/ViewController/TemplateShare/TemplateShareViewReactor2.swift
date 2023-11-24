//
//  TemplateShareViewReactor.swift
//  mojitok-nft
//
//  Created by GAMZA on 2022/02/07.
//

import UIKit

import ReactorKit
import Pure

final class TemplateShareViewReactor2: Reactor, FactoryModule {
    // MARK: - Declarations
    struct Dependency {
        let twitterService: TwitterService
        let userService: UserService
    }
    
    struct Payload {
        let art: ArtUIProtocol
        let isLive: Bool
    }
    
    enum Action {
        case fetch
        case saveGallery
        case presentTwitterPreview
        case shareTwitter
    }
    
    enum Mutation {
        case fetchImage(UIImage?)
        case fetchVideo(URL?)
        case saveGallery
        case presentTwitterPreview(TwitterTweetForm)
        case postTwitter(Bool)
    }
    
    struct State {
        var image: UIImage?
        var videoPath: URL?
        var isArtSave: Bool = false
        var messageViewText: String?
        var twitterTweetForm: TwitterTweetForm?
    }
    
    // MARK: - Property
    let initialState: State
    let dependency: Dependency
    let payload: Payload
    let scheduler: Scheduler = SerialDispatchQueueScheduler(qos: .default)
    
    // MARK: - Init
    init(dependency: Dependency, payload: Payload) {
        initialState = .init()
        self.dependency = dependency
        self.payload = payload
    }
    
    // MARK: - Method
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetch:
            switch payload.art.mediaType {
            case .video:
                return .just(.fetchVideo(InventoryService.videoCacheFolderURL.appendingPathComponent(payload.art.fileName)))
            case .image:
                let image = payload.art.thumbnailImage
                return .just(.fetchImage(image))
            }
        case .saveGallery:
            return .just(.saveGallery)
        case .presentTwitterPreview:
            guard let twitterForm = payload.art.resource.template.twitterForm else {
                return .just(.postTwitter(false))
            }
            let text = generateTwitterForm(twitter: twitterForm, art: payload.art)
            if let _ = dependency.userService.getUsers().first?.socialAccount {
                return .just(.presentTwitterPreview(.init(text: text, art: payload.art)))
            } else {
                if let _ = dependency.twitterService.login() {
                    return .just(.presentTwitterPreview(.init(text: text, art: payload.art)))
                } else {
                    return .just(.postTwitter(false))
                }
            }
        case .shareTwitter:
            if let twitterForm = payload.art.resource.template.twitterForm,
               let twitterAccount = dependency.userService.getUsers().first?.socialAccount,
               let accessTokenWithSecret = try? JSONDecoder().decode(AccessTokenWithSecret.self, from: twitterAccount.token.tokenData) {
                let text = generateTwitterForm(twitter: twitterForm, art: payload.art)
                let form = TwitterTweetForm(text: text, art: payload.art)
                let urlString = dependency.twitterService.tweet(accessTokenWithSecret: accessTokenWithSecret, twitterTweet: form)
                return .just(.postTwitter(urlString != nil))
            } else if let _ = dependency.twitterService.login() {
                return .just(.presentTwitterPreview(.init(text: payload.art.resource.permalink, art: payload.art)))
            }
            return .just(.postTwitter(false))
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case .fetchImage(let image):
            state.videoPath = nil
            state.image = image
            state.messageViewText = nil
            state.twitterTweetForm = nil
        case .fetchVideo(let url):
            state.image = nil
            state.videoPath = url
            state.messageViewText = nil
            state.twitterTweetForm = nil
        case .saveGallery:
            state.isArtSave = true
            state.messageViewText = "Saved to Gallery"
            state.twitterTweetForm = nil
        case .presentTwitterPreview(let form):
            state.twitterTweetForm = form
            state.messageViewText = nil
        case .postTwitter(let result):
            state.twitterTweetForm = nil
            if result {
                state.messageViewText = "Posted on Twitter"
            } else {
                state.messageViewText = "Posted to Twitter failed"
            }
        }
        return state
    }
    
    func generateTopbarDependency() -> TopBar.Dependency {
        return .init()
    }
    
    private func generateTwitterForm(twitter form: String, art: ArtProtocol) -> String{
        var newForm = form
        let tags = getTagList(twitter: form)
        for tag in tags {
            switch tag {
            case .collectionName:
                newForm = newForm.replace(target: tag.code, withString: "\(art.resource.nft.collectionName)")
            case .itemName:
                newForm = newForm.replace(target: tag.code, withString: "#\(art.resource.nft.tokenID)")
            case .openSeaLink:
                newForm = newForm.replace(target: tag.code, withString: art.resource.permalink)
            case .price:
                newForm = newForm.replace(target: tag.code, withString: "price")
            case .marketplace:
                newForm = newForm.replace(target: tag.code, withString: "opensea")
            case .collection_name:
                let splitedCollectionName = art.resource.nft.collectionName.split(separator: "(").first ?? ""
                let removedLastSpace = splitedCollectionName.split(separator: " ").joined(separator: " ")
                let collectionName = removedLastSpace.replace(target: " ", withString: "_")
                newForm = newForm.replace(target: tag.code, withString: "\(collectionName)")
            case .ownerID:
                newForm = newForm.replace(target: tag.code, withString: "\(art.resource.nft.owner?.address ?? "")")
            }
        }
        return newForm
    }
    
    private func getTagList(twitter form: String) -> [TwitterFormCode] {
        var result: [TwitterFormCode] = []
        for code in TwitterFormCode.allCases {
            if form.contains(code.code) {
                result.append(code)
            }
        }
        return result
    }
}
