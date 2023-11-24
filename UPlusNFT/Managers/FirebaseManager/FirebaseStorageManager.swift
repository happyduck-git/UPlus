//
//  FirebaseStorageManager.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/08/09.
//

import Foundation
import FirebaseStorage

final class FirebaseStorageManager {
    
    static let shared = FirebaseStorageManager()
    private init() {}
    
}

extension FirebaseStorageManager {
    
    func getDataUrl(reference: String) async throws -> URL {
        return try await Storage.storage().reference(forURL: reference).downloadURL()
    }
    
}
