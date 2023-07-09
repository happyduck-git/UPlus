//
//  URL+Extension.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/07.
//

import UIKit.UIImage
import Nuke
import FirebaseStorage

extension URL {
    
    static func urlToImage(_ url: URL?) async throws -> UIImage? {
        let storageManager = FirebaseStorageCacheManager.shared
        
        guard var imageUrl = url else {
            return nil
        }
        
        if !imageUrl.absoluteString.hasPrefix("http") {
            let key = imageUrl
            
            if let cachedImageString = storageManager.getStorageCache(path: key),
               let url = URL(string: cachedImageString)
            {
                imageUrl = url
            } else {
                imageUrl = try await Storage.storage().reference(withPath: imageUrl.absoluteString).downloadURL()
                storageManager.setStorageCache(path: key, url: imageUrl)
            }
        }
        
        return try await ImagePipeline.shared.image(for: imageUrl)
    }
    
}
