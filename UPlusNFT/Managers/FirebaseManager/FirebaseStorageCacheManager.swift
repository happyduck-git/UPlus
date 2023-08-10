//
//  FirebaseStorageCacheManager.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/07/09.
//

import Foundation

final class FirebaseStorageCacheManager {
    
    static let shared = FirebaseStorageCacheManager()
    
    private init() {}
    
    private var imageDataCache: NSCache = NSCache<NSString, NSString>()
    
    func setStorageCache(path: URL, url: URL) {
        let key = path.absoluteString as NSString
        let value = url.absoluteString as NSString
        
        self.imageDataCache.setObject(value, forKey: key)
    }
    
    func getStorageCache(path: URL) -> String? {
        let key = path.absoluteString as NSString
        return self.imageDataCache.object(forKey: key) as? String
    }
    
}
