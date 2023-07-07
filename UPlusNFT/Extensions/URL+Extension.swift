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
        guard var imageUrl = url else {
            return nil
        }
        
        if !imageUrl.absoluteString.hasPrefix("http") {
            imageUrl = try await Storage.storage().reference(withPath: imageUrl.absoluteString).downloadURL()
        }
        return try await ImagePipeline.shared.image(for: imageUrl)
    }
    
}
