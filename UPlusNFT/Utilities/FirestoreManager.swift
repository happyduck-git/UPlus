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
    func getAllPosts() async throws -> [Post] {
        let snapshots = try await db.collectionGroup(FirestoreConstants.threadSetCollection)
            .getDocuments()
            .documents
        
        let posts = snapshots.map { snapshot in
            
            /// Post
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
//        print("Posts: \(posts)")
//        print(posts.count)
        return posts
    }
    
    /// Fetch all the comments
    func getAllComments() async throws {
        // comment_set parent document id & Post id
        let snapshot = try await db.collectionGroup(FirestoreConstants.commentSet)
            .getDocuments()
            .documents
        
        let comments = snapshot.map { snapshot in
            let data = snapshot.data()
            
            let postId = snapshot.reference.documentID
            let commentAuthorUid = data[FirestoreConstants.commentAuthorUid] as? String ?? FirestoreConstants.noUserUid
            let commentContentImagePath = data[FirestoreConstants.commentContentImagePath] as? String
            let commentContentText = data[FirestoreConstants.commentContentText] as? String ?? FirestoreConstants.noUserUid
            let commentCreatedTime = data[FirestoreConstants.commentCreatedTime] as? Date ?? Date()
            let commentId = data[FirestoreConstants.commentId] as? String ?? FirestoreConstants.noUserUid
            let commentLikedUserUidList = data[FirestoreConstants.commentLikedUserUidList] as? [String]
            
            return Comment(
                postId: postId,
                commentAuthorUid: commentAuthorUid,
                commentContentImagePath: commentContentImagePath,
                commentContentText: commentContentText,
                commentCreatedTime: commentCreatedTime,
                commentId: commentId,
                commentLikedUserUidList: commentLikedUserUidList
            )
        }
        print("Comments: \(comments) \n Counts: \(comments.count)")
    }
    
    /// Fetch all the re-comments
    func getAllRecomments() async throws {
        // recomment_set parent document id & Comment id
        let snapshots = try await db.collectionGroup(FirestoreConstants.recommentSet)
            .getDocuments()
            .documents
        
        let recomments = snapshots.map { snapshot in
            let data = snapshot.data()
            
            let commentId = snapshot.reference.documentID
            let recommentAuthorUid = data[FirestoreConstants.recommentAuthorUid] as? String ?? FirestoreConstants.noUserUid
            let recommentContentText = data[FirestoreConstants.recommentContentText] as? String ?? FirestoreConstants.noUserUid
            let recommentCreatedTime = data[FirestoreConstants.recommentCreatedTime] as? Date ?? Date()
            let recommentId = data[FirestoreConstants.recommentId] as? String ?? FirestoreConstants.noUserUid
            
            return Recomment(
                commentId: commentId,
                recommentAuthorUid: recommentAuthorUid,
                recommentContentText: recommentContentText,
                recommentCreatedTime: recommentCreatedTime,
                recommentId: recommentId
            )
        }
        print("Recomments: \(recomments) \n Counts: \(recomments.count)")
    }
    
    /// Fetch all the comments of a certain post
    func getComments(of postId: String) async throws -> [Comment] {
        let snapshots = try await db.collection(FirestoreConstants.devThreads)
            .document(FirestoreConstants.threads)
            .collection("\(FirestoreConstants.threadSetCollection)/\(postId)/\(FirestoreConstants.commentSet)")
            .getDocuments()
            .documents
     
        let comments = snapshots.map { snapshot in
            let data = snapshot.data()
            
            let postId = snapshot.reference.parent.parent?.documentID ?? "no-document-id"
            let commentAuthorUid = data[FirestoreConstants.commentAuthorUid] as? String ?? FirestoreConstants.noUserUid
            let commentContentImagePath = data[FirestoreConstants.commentContentImagePath] as? String
            let commentContentText = data[FirestoreConstants.commentContentText] as? String ?? FirestoreConstants.noUserUid
            let commentCreatedTime = data[FirestoreConstants.commentCreatedTime] as? Date ?? Date()
            let commentId = data[FirestoreConstants.commentId] as? String ?? FirestoreConstants.noUserUid
            let commentLikedUserUidList = data[FirestoreConstants.commentLikedUserUidList] as? [String]
            
            return Comment(
                postId: postId,
                commentAuthorUid: commentAuthorUid,
                commentContentImagePath: commentContentImagePath,
                commentContentText: commentContentText,
                commentCreatedTime: commentCreatedTime,
                commentId: commentId,
                commentLikedUserUidList: commentLikedUserUidList
            )
        }
        return comments
    }
    
    /// Fetch all the recommnets of a certain comment
    func getRecomments(postId: String, commentId: String) async throws -> [Recomment] {
        let snapshots = try await db.collection(FirestoreConstants.devThreads)
            .document(FirestoreConstants.threads)
            .collection("\(FirestoreConstants.threadSetCollection)/\(postId)/\(FirestoreConstants.commentSet)/\(commentId)/\(FirestoreConstants.recommentSet)")
            .getDocuments()
            .documents
        
        let recomments = snapshots.map { snapshot in
            let data = snapshot.data()
            
            let commentId = snapshot.reference.documentID
            let recommentAuthorUid = data[FirestoreConstants.recommentAuthorUid] as? String ?? FirestoreConstants.noUserUid
            let recommentContentText = data[FirestoreConstants.recommentContentText] as? String ?? FirestoreConstants.noUserUid
            let recommentCreatedTime = data[FirestoreConstants.recommentCreatedTime] as? Date ?? Date()
            let recommentId = data[FirestoreConstants.recommentId] as? String ?? FirestoreConstants.noUserUid
            
            return Recomment(
                commentId: commentId,
                recommentAuthorUid: recommentAuthorUid,
                recommentContentText: recommentContentText,
                recommentCreatedTime: recommentCreatedTime,
                recommentId: recommentId
            )
        }
        
        print("Recomments counts: \(recomments)")
        return recomments
    }
    
    func getAllPostContent() async throws -> [PostContent] {
        
        var contents: [PostContent] = []
        let posts = try await self.getAllPosts()
        
        for post in posts {
            
            let comments = try await self.getComments(of: post.id)
            
            let content = PostContent(
                post: post,
                comments: comments
            )
            
            contents.append(content)
            
        }
        
        return contents
    }
}
