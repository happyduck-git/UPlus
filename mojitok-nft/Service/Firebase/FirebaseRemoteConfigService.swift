//
//  FirebaseRemoteConfigService.swift
//  mojitok-nft
//
//  Created by GAMZA on 2022/03/17.
//

import FirebaseRemoteConfig

final class RemoteConfigService {
    // MARK: - Typealias
    typealias Handler = (Data?) -> Void
    typealias HandlerBlock = (key: RemoteConfigKey, handler: Handler)
    
    // MARK: - Enum
    enum RemoteConfigKey: String, CaseIterable {
        case templates = "template"
        case fonts = "fonts"
    }
    
    // MARK: - Static Proerty
    static let shared = RemoteConfigService()
    
    // MARK: - Property
    private let queue = DispatchQueue(label: "RemoteConfigService", attributes: .concurrent)
    private var handlerQueue: [UUID: HandlerBlock] = [:]
    private var isFetched = false
    private let remoteConfig: RemoteConfig
    private let settings: RemoteConfigSettings
    
    // MARK: - Init
    init(remoteConfig: RemoteConfig = RemoteConfig.remoteConfig(), settings: RemoteConfigSettings = RemoteConfigSettings()) {
        self.remoteConfig = remoteConfig
        self.settings = settings
        
        setup()
    }
    
    // MARK: - Interface
    private func setup() {
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
        
        fetchRemoteConfig()
    }
    
    func getResource(key: RemoteConfigKey, completion: @escaping Handler, id: UUID = UUID()) {
        if isFetched {
            let data = self.remoteConfig[key.rawValue].dataValue
            completion(data)
        } else {
            handlerQueue[id] = (key, completion)
        }
    }
    
    // MARK: - Private Method
    private func fetchRemoteConfig() {
        self.remoteConfig.fetch(withExpirationDuration: TimeInterval(3600)) { (status, error) in
            if let error = error {
                print("📑 RemoteConfig fetch faild - \(error.localizedDescription)")
            } else {
                self.remoteConfig.activate { (result, error) in
                    if let err = error {
                        print("📑 RemoteConfig fetch from cloud faild")
                        dump(err)
                    } else {
                        self.isFetched = true
                        print("📑 RemoteConfig: ✅ fetch success")
                        self.executeHandlerQueue()
                    }
               }
            }
        }
    }
    
    
    private func executeHandlerQueue() {
        for (key, handlerBlock) in handlerQueue {
            queue.async {
                let data = self.remoteConfig[handlerBlock.key.rawValue].dataValue
                handlerBlock.handler(data)
            }
            self.handlerQueue.removeValue(forKey: key)
        }
    }
 
}

