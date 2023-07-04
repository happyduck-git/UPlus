//
//  FirestoreManager.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/06/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage

final class FirestoreManager {
    
    //MARK: - Init
    static let shared = FirestoreManager()
    private init() {}
    
    //MARK: - Property
    
    // Database
    private let db = Firestore.firestore()
    
    // Pagination
    var isPagenating: Bool = false
    var queryDocumentSnapshot: QueryDocumentSnapshot?
}

// MARK: - Getters
extension FirestoreManager {

    //MARK: - Get Posts
    /// Fetch all the posts
    func getAllPosts() async throws -> [Post] {
        let snapshots = try await db.collectionGroup(FirestoreConstants.threadSetCollection)
            .getDocuments()
            .documents
        
        // Convert document snapshot to `Post`.
        let posts = snapshots.map { snapshot in
            return self.convertQueryDocumentToPost(snapshot)
            
        }
//        print("Posts: \(posts)")
//        print(posts.count)
        return posts
    }
    
    func getPaginatedPosts() async throws -> (posts: [Post], lastDoc: QueryDocumentSnapshot?) {
        let snapshots = try await db.collectionGroup(FirestoreConstants.threadSetCollection)
            .limit(to: FirestoreConstants.documentLimt)
            .getDocuments()
            .documents
        
        let posts = snapshots.map { snapshot in
            return self.convertQueryDocumentToPost(snapshot)
        }

        let lastDoc = snapshots.last
        
        return (posts: posts, lastDoc: lastDoc)
    }
    
    func getAdditionalPaginatedPosts(
        after lastDocumentSnapshot: QueryDocumentSnapshot?
    ) async throws -> (posts: [Post], lastDoc: QueryDocumentSnapshot?) {
        
        guard let lastSnapshot = lastDocumentSnapshot
        else {
            print("Last document found to be nil.")
            throw FirestoreErorr.documentFoundToBeNil
        }
        
        let snapshots = try await db.collectionGroup(FirestoreConstants.threadSetCollection)
            .start(afterDocument: lastSnapshot)
            .limit(to: FirestoreConstants.documentLimt)
            .getDocuments()
            .documents
        
        let posts = snapshots.map { snapshot in
            return self.convertQueryDocumentToPost(snapshot)
        }

        let lastDoc = snapshots.last
        
        return (posts: posts, lastDoc: lastDoc)
    }

    //MARK: - Get Comments
    /// Fetch all the comments
    func getAllComments() async throws {
        // comment_set parent document id & Post id
        let snapshot = try await db.collectionGroup(FirestoreConstants.commentSet)
            .getDocuments()
            .documents
        
        let comments = snapshot.map { snapshot in
            let data = snapshot.data()
            
            let commentAuthorUid = data[FirestoreConstants.commentAuthorUid] as? String ?? FirestoreConstants.noUserUid
            let commentContentImagePath = data[FirestoreConstants.commentContentImagePath] as? String
            let commentContentText = data[FirestoreConstants.commentContentText] as? String ?? FirestoreConstants.noUserUid
            let commentCreatedTime = data[FirestoreConstants.commentCreatedTime] as? Date ?? Date()
            let commentId = data[FirestoreConstants.commentId] as? String ?? FirestoreConstants.noUserUid
            let commentLikedUserUidList = data[FirestoreConstants.commentLikedUserUidList] as? [String]
            
            return Comment(
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
        let snapshots = try await db            .collection("\(FirestoreConstants.devThreads)/\(FirestoreConstants.threads)/\(FirestoreConstants.threadSetCollection)/\(postId)/\(FirestoreConstants.commentSet)")
            .getDocuments()
            .documents
     
        let comments = snapshots.map { snapshot in
            let data = snapshot.data()
            
            let commentAuthorUid = data[FirestoreConstants.commentAuthorUid] as? String ?? FirestoreConstants.noUserUid
            let commentContentImagePath = data[FirestoreConstants.commentContentImagePath] as? String
            let commentContentText = data[FirestoreConstants.commentContentText] as? String ?? FirestoreConstants.noUserUid
            let commentCreatedTime = data[FirestoreConstants.commentCreatedTime] as? Date ?? Date()
            let commentId = data[FirestoreConstants.commentId] as? String ?? FirestoreConstants.noUserUid
            let commentLikedUserUidList = data[FirestoreConstants.commentLikedUserUidList] as? [String]
            
            return Comment(
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
    
    func getBestComments(of postId: String) async throws -> [Comment] {
        guard let postData = try await db            .collection("\(FirestoreConstants.devThreads)/\(FirestoreConstants.threads)/\(FirestoreConstants.threadSetCollection)")
            .document(postId)
            .getDocument()
            .data() else {
            return []
        }
        
        let commentIds = postData[FirestoreConstants.cachedBestCommentIdList] as? [String] ?? []
        var comments: [Comment] = []
        print("Comments ids: \(commentIds)")
        for id in commentIds {
            let data = try await db            .collection("\(FirestoreConstants.devThreads)/\(FirestoreConstants.threads)/\(FirestoreConstants.threadSetCollection)/\(postId)/\(FirestoreConstants.commentSet)")
                .document(id)
                .getDocument()
                .data()
            
            let commentAuthorUid = data?[FirestoreConstants.commentAuthorUid] as? String ?? FirestoreConstants.noUserUid
            let commentContentImagePath = data?[FirestoreConstants.commentContentImagePath] as? String
            let commentContentText = data?[FirestoreConstants.commentContentText] as? String ?? FirestoreConstants.noUserUid
            let commentCreatedTime = data?[FirestoreConstants.commentCreatedTime] as? Date ?? Date()
            let commentId = data?[FirestoreConstants.commentId] as? String ?? FirestoreConstants.noUserUid
            let commentLikedUserUidList = data?[FirestoreConstants.commentLikedUserUidList] as? [String]
            
            let comment = Comment(
                commentAuthorUid: commentAuthorUid,
                commentContentImagePath: commentContentImagePath,
                commentContentText: commentContentText,
                commentCreatedTime: commentCreatedTime,
                commentId: commentId,
                commentLikedUserUidList: commentLikedUserUidList
            )
            comments.append(comment)
        }
        
        return comments
    }
    
    /// Fetch all the recommnets of a certain comment
    func getRecomments(postId: String, commentId: String) async throws -> [Recomment] {
        let snapshots = try await db            .collection("\(FirestoreConstants.devThreads)/\(FirestoreConstants.threads)/\(FirestoreConstants.threadSetCollection)/\(postId)/\(FirestoreConstants.commentSet)/\(commentId)/\(FirestoreConstants.recommentSet)")
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
    
    func getAllInitialPostContent() async throws -> (posts: [PostContent], lastDoc: QueryDocumentSnapshot?) {
        var contents: [PostContent] = []
        let results = try await self.getPaginatedPosts()
        
        for post in results.posts {
            let comments = try await self.getComments(of: post.id)
            
            let content = PostContent(
                post: post,
                comments: comments
            )
            contents.append(content)
        }
        return (posts: contents, lastDoc: results.lastDoc)
    }
    
    func getAllAdditionalPostContent(after lastDoc: QueryDocumentSnapshot?) async throws -> (posts: [PostContent], lastDoc: QueryDocumentSnapshot?) {
        var contents: [PostContent] = []
        let results = try await self.getAdditionalPaginatedPosts(after: lastDoc)
        
        for post in results.posts {
            let comments = try await self.getComments(of: post.id)
            
            let content = PostContent(
                post: post,
                comments: comments
            )
            contents.append(content)
        }
        return (posts: contents, lastDoc: results.lastDoc)
    }
    
    // MARK: - MetaData
    
    func getMetadata(of postId: String) async throws -> CampaignMetaData? {
        let snapshots =  try await self.db.collection("\(FirestoreConstants.devThreads)/\(FirestoreConstants.threads)/\(FirestoreConstants.threadSetCollection)/\(postId)/\(FirestoreConstants.campaignMetadataBundle)")
            .getDocuments()
            .documents
        
        var config: CampaignConfiguration?
        var items: [CampaignItem] = []
        var users: [CampaignUser] = []
        var bestComments: [BestComment] = []
        
        for snapshot in snapshots {
            let docRef = snapshot.reference
    
            // 1. configuration -> doc fields
            if snapshot.documentID == FirestoreConstants.campaginConfiguration {
                let data = snapshot.data()
                let beginTime = data[FirestoreConstants.beginTime] as? Timestamp ?? Timestamp(date: Date())
                let endTime = data[FirestoreConstants.endTime] as? Timestamp ?? Timestamp(date: Date())
                config = CampaignConfiguration(
                    beginTime: beginTime,
                    endTime: endTime
                )
                
            } else if snapshot.documentID == FirestoreConstants.campaignItems {
                // 2. campaign items
                let itemSnapshots = try await docRef.collection(FirestoreConstants.campaignItemSet)
                    .getDocuments()
                    .documents
                for itemSnapshot in itemSnapshots {
                    let data = itemSnapshot.data()
                    let id = data[FirestoreConstants.itemId] as? Int64 ?? 0
                    let caption = data[FirestoreConstants.itemCaption] as? String ?? ""
                    let isRight = data[FirestoreConstants.isRightItem] as? Bool ?? false
                    let rewardCategoryId = data[FirestoreConstants.itemRewardCategoryId] as? String ?? ""
                    let participantsCount = data[FirestoreConstants.cachedItemUserCount] as? Int64 ?? 0
   
                    let item = CampaignItem(
                        id: id,
                        caption: caption,
                        isRight: isRight,
                        rewardCategoryId: rewardCategoryId,
                        participantsCount: participantsCount
                    )
                    items.append(item)
                }
            } else if snapshot.documentID == FirestoreConstants.campaignUsers {
                // 3. campaign users
                let userSnapshots = try await docRef.collection(FirestoreConstants.campaignUserSet)
                    .getDocuments()
                    .documents
                
                for userSnapshot in userSnapshots {
                    let data = userSnapshot.data()
                    let id = data[FirestoreConstants.userUid] as? String ?? FirestoreConstants.noUserUid
                    let selectedItemId = data[FirestoreConstants.userSelectedItemId] as? Int64 ?? 0
                    let answerSubmitted = data[FirestoreConstants.userAnsweredText] as? String
                    let isRightAnswer = data[FirestoreConstants.isUserSendRightAnswer] as? Bool ?? false
                    let isRewared = data[FirestoreConstants.hasUserReward] as? Bool ?? false
   
                    let user = CampaignUser(
                        id: id,
                        selectedItemId: selectedItemId,
                        answerSubmitted: answerSubmitted,
                        isRightAnswer: isRightAnswer,
                        isRewared: isRewared
                    )
                    users.append(user)
                }
            } else if snapshot.documentID == FirestoreConstants.campaignBestCommentItems {
                // 4. best comments
                let itemSnapshots = try await docRef.collection(FirestoreConstants.campaignBestCommentItemSet)
                    .getDocuments()
                    .documents
                
                for itemSnapshot in itemSnapshots {
                    let data = itemSnapshot.data()
                    
                    let order = data[FirestoreConstants.bestCommentOrder] as? Int64 ?? 0
                    let rewardCategory = data[FirestoreConstants.bestCommentRewardCategoryId] as? String
                    let rewaredUser = data[FirestoreConstants.bestCommentRewardedUserUid] as? String
   
                    let item = BestComment(
                        order: order,
                        rewardCategory: rewardCategory,
                        rewaredUser: rewaredUser
                    )
                    
                    bestComments.append(item)
                }
            } else {
                
            }

        }
        
        guard let config = config else {
            return nil
        }
        
        let metaData = CampaignMetaData(
            configuration: config,
            items: items,
            users: users,
            bestComments: bestComments
        )
//        print("Meta data: \(metaData)")
        return metaData
    }
    
    // MARK: - Get user
    func getUser(_ userId: String) async throws -> User {
        return try await self.db
            .collection("\(FirestoreConstants.devThreads)/\(FirestoreConstants.users)/\(FirestoreConstants.userSetCollection)")
            .document(userId)
            .getDocument(as: User.self)
    }
    
}

// MARK: - Setters
extension FirestoreManager {
    
    func saveUser(_ user: User) throws {
        let userSet = self.db
            .collection("\(FirestoreConstants.devThreads)/\(FirestoreConstants.users)/\(FirestoreConstants.userSetCollection)")
            .document(user.id)
        
        try userSet.setData(
            from: user,
            merge: true
        ) { _ in
            print("User sucessfully saved!")
        }
    }
    
    func saveImage(postId: String, images: [Data], completion: @escaping ([String]) -> Void) {
        
        let group = DispatchGroup()
        var imageUrls: [String] = []
        
        for image in images {
            
            let imageId = UUID().uuidString
            let uploadRef = Storage.storage().reference(withPath: "dev_threads/threads/thread_set/\(postId)/\(imageId).jpg")
            
            let uploadMetadata = StorageMetadata()
            uploadMetadata.contentType = "image/jpeg"
            
            group.enter()
            uploadRef.putData(image, metadata: uploadMetadata) { metadata, error in
                group.leave()
                guard error == nil else {
                    print("Error uploading image to Firebase Storage. --- " + String(describing: error?.localizedDescription))
                    return
                }
                guard let metadata = metadata else {
                    print("Metadata found to be nil.")
                    return
                }
//                print("Uploading Image is completed; \(metadata)")
                
                group.enter()
                uploadRef.downloadURL { result in
                    group.leave()
                    switch result {
                    case .success(let url):
                        imageUrls.append(url.absoluteString)
                    case .failure(let error):
                        print("Error dowloading image URL: \(error)")
                    }
                }
            }
        }
        
        group.notify(queue: .main) {
            completion(imageUrls)
        }
    }
    
    func savePost(_ post: Post) throws {
        let threadSet = self.db
            .collection("\(FirestoreConstants.devThreads)/\(FirestoreConstants.threads)/\(FirestoreConstants.threadSetCollection)")
            .document(post.id)
        
        try threadSet.setData(
            from: post,
            merge: true
        ) { _ in
            print("Post sucessfully save!")
        }
    }
    
    // Like button tap
    func updateLike() {
        
        // Need to include a logic that updates cached_best_comment_id_list
        
    }
    
}

//MARK: - Convert `Query Document` to `Post`
extension FirestoreManager {
    
    private func convertQueryDocumentToPost(_ queryDocument: QueryDocumentSnapshot) -> Post {
        let data = queryDocument.data()
        
        let id = data[FirestoreConstants.id] as? String ?? FirestoreConstants.noPostId
        let url = data[FirestoreConstants.url] as? String ?? FirestoreConstants.noUrl
        let cachedType = data[FirestoreConstants.cachedType] as? String ?? FirestoreConstants.noUserUid
        let title = data[FirestoreConstants.title] as? String ?? FirestoreConstants.noTitle
        let contentText = data[FirestoreConstants.contentText] as? String ?? FirestoreConstants.noContent
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
}

extension FirestoreManager {
    enum FirestoreErorr: Error {
        case documentNotFound
        case documentFoundToBeNil
    }
}
