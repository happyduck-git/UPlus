//
//  FirestoreManager.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/06/23.
//

import Foundation
import FirebaseFirestore

final class FirestoreManager {
    
    static let shared = FirestoreManager()
    private init() {}
    
    private let db = Firestore.firestore()
    
    /// Fetch all the posts
    func getAllPosts() async throws {
        let snapshots = try await db.collectionGroup(FirestoreConstants.threadSetCollection)
            .getDocuments()
            .documents
        
        let posts = snapshots.map { snapshot in
            let data = snapshot.data()
            
            let id = data[FirestoreConstants.id] as? String ?? FirestoreConstants.noUserUid
            let url = data[FirestoreConstants.url] as? String ?? FirestoreConstants.noUserUid
            let cachedType = data[FirestoreConstants.cachedType] as? String ?? FirestoreConstants.noUserUid
            let title = data[FirestoreConstants.title] as? String ?? FirestoreConstants.noUserUid
            let contentText = data[FirestoreConstants.contentText] as? String ?? FirestoreConstants.noUserUid
            let contentImagePathList = data[FirestoreConstants.contentImagePathList] as? [String]
            let authorUid = data[FirestoreConstants.authorUid] as? String ?? FirestoreConstants.noUserUid
            let createdTime = data[FirestoreConstants.createdTime] as? Date ?? Date()
            let likedUserIdList = data[FirestoreConstants.likedUserIdList] as? [String]
            let cachedBestCommentIdList = data[FirestoreConstants.cachedBestCommentIdList] as? [String]
            
            return Post(
                id: id,
                url: url,
                cachedType: cachedType,
                title: title,
                contentText: contentText,
                contentImagePathList: contentImagePathList,
                authorUid: authorUid,
                createdTime: createdTime,
                likedUserIdList: likedUserIdList,
                cachedBestCommentIdList: cachedBestCommentIdList
            )
        }
        print("Posts: \(posts)")
        print(posts.count)
    }
    
}
