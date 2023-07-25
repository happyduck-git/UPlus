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
    
    /* uplus_missions_v2 */
    private let threadsSetCollectionPath2 = Firestore.firestore().collection(FirestoreConstants.devThreads2)
    
    /* uplus_posts_and_missions_v1 */
    private let threadsSetCollectionPath = Firestore.firestore().collection("\(FirestoreConstants.devThreads)/\(FirestoreConstants.threads)/\(FirestoreConstants.threadSetCollection)")
    private let userSetCollectionPath =
    Firestore.firestore().collection("\(FirestoreConstants.devThreads)/\(FirestoreConstants.users)/\(FirestoreConstants.userSetCollection)")
    
    // Pagination
    var isPagenating: Bool = false
    var queryDocumentSnapshot: QueryDocumentSnapshot?
}

/* uplus_missions_v2 */
extension FirestoreManager {
    
    // MARK: - Get Missions
    
    func getAllDailyAttendanceMission() async throws -> [DailyAttendanceMission] {
        let documents = try await threadsSetCollectionPath2.document(FirestoreConstants.missions)
            .collection(FirestoreConstants.dailyAttendanceMission)
            .getDocuments()
            .documents
        
        var missions: [DailyAttendanceMission] = []
        let decoder = Firestore.Decoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        for doc in documents {
            var data = try doc.data(as: DailyAttendanceMission.self, decoder: decoder)
            data.postId = doc.documentID
            missions.append(data)
        }
        return missions
    }
    
    func getAthleteMission() async throws -> [AthleteMission] {
        let documents = try await threadsSetCollectionPath2.document(FirestoreConstants.missions)
            .collection(FirestoreConstants.athleteMission)
            .getDocuments()
            .documents
        
        var missions: [AthleteMission] = []
        let decoder = Firestore.Decoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        for doc in documents {
            missions.append(try doc.data(as: AthleteMission.self, decoder: decoder))
        }
        return missions
    }
    
    func getEnvironmentalistMission() async throws -> [EnvironmentalistMission] {
        let documents = try await threadsSetCollectionPath2.document(FirestoreConstants.missions)
            .collection(FirestoreConstants.environmentalistMission)
            .getDocuments()
            .documents
        
        var missions: [EnvironmentalistMission] = []
        let decoder = Firestore.Decoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        for doc in documents {
            missions.append(try doc.data(as: EnvironmentalistMission.self, decoder: decoder))
        }
        return missions
    }
    
    func getGoodWorkerMission() async throws -> [GoodWorkerMission] {
        let documents = try await threadsSetCollectionPath2.document(FirestoreConstants.missions)
            .collection(FirestoreConstants.goodWorkerMission)
            .getDocuments()
            .documents
        
        var missions: [GoodWorkerMission] = []
        let decoder = Firestore.Decoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        for doc in documents {
            missions.append(try doc.data(as: GoodWorkerMission.self, decoder: decoder))
        }
        return missions
    }
    
    func getSuddenMission() async throws -> [SuddenMission] {
        let documents = try await threadsSetCollectionPath2.document(FirestoreConstants.missions)
            .collection(FirestoreConstants.suddenMission)
            .getDocuments()
            .documents
        
        var missions: [SuddenMission] = []
        let decoder = Firestore.Decoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        for doc in documents {
            missions.append(try doc.data(as: SuddenMission.self, decoder: decoder))
        }
        return missions
    }
    
    // MARK: - Get Rewards
    func getRewardsOwned(by ownerIndex: String) async throws -> [Reward] {
        let documents = try await threadsSetCollectionPath2
            .document(FirestoreConstants.rewards)
            .collection(FirestoreConstants.rewardSetCollection)
            .whereField(FirestoreConstants.rewardUser, isEqualTo: ownerIndex)
            .getDocuments()
            .documents
        
        let decoder = Firestore.Decoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let rewards = try documents.map { doc in
            try doc.data(as: Reward.self, decoder: decoder)
        }

        return rewards
    }
    
    // MARK: - Get Users
    func getUsers() async throws -> [UPlusUser] {
        let documents = try await threadsSetCollectionPath2
            .document(FirestoreConstants.users)
            .collection(FirestoreConstants.userSetCollection)
            .getDocuments()
            .documents
        
        let decoder = Firestore.Decoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let users = try documents.map { doc in
            try doc.data(as: UPlusUser.self, decoder: decoder)
        }

        return users
    }
    
    // MARK: - Setters
    func saveUserState(postId: String,
                       userIndex: Int64,
                       state: MissionAnswerState) async throws {
        
        try await threadsSetCollectionPath2
            .document(FirestoreConstants.missions)
            .collection(FirestoreConstants.dailyAttendanceMission)
            .document(postId)
            .updateData([FirestoreConstants.missionUserStateMap : [userIndex: state.rawValue]])
    }
}


/* uplus_posts_and_missions_v1 */
// MARK: - Getters
extension FirestoreManager {

    //MARK: - Get Posts
    func getPaginatedPosts() async throws -> (posts: [Post], lastDoc: QueryDocumentSnapshot?) {
        let snapshots = try await threadsSetCollectionPath
            .order(by: FirestoreConstants.createdTime, descending: true)
            .limit(to: FirestoreConstants.documentLimit)
            .getDocuments()
            .documents
        
        var posts: [Post] = []
        for snapshot in snapshots {
            posts.append(try await self.convertQueryDocumentToPost(snapshot))
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
        
        let snapshots = try await threadsSetCollectionPath
            .order(by: FirestoreConstants.createdTime, descending: true)
            .start(afterDocument: lastSnapshot)
            .limit(to: FirestoreConstants.documentLimit)
            .getDocuments()
            .documents
        
        var posts: [Post] = []
        for snapshot in snapshots {
            posts.append(try await self.convertQueryDocumentToPost(snapshot))
        }

        let lastDoc = snapshots.last
        
        return (posts: posts, lastDoc: lastDoc)
    }

    // MARK: - Get Comments & Recomments
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
            let recommentCreatedTime = data[FirestoreConstants.recommentCreatedTime] as? Timestamp ?? Timestamp(date: Date())
            let recommentId = data[FirestoreConstants.recommentId] as? String ?? FirestoreConstants.noUserUid
            
            return Recomment(
//                commentId: commentId,
                recommentAuthorUid: recommentAuthorUid,
                recommentContentText: recommentContentText,
                recommentCreatedTime: recommentCreatedTime,
                recommentId: recommentId
            )
        }
        print("Recomments: \(recomments) \n Counts: \(recomments.count)")
    }
 
    /// Fetch initial paginated comments of a certain post
    func getPaginatedComments(of postId: String) async throws -> (comments: [Comment], lastDoc: QueryDocumentSnapshot?) {
        let snapshots = try await threadsSetCollectionPath
            .document(postId)
            .collection(FirestoreConstants.commentSet)
            .order(by: FirestoreConstants.commentCreatedTime, descending: true)
            .limit(to: FirestoreConstants.documentLimit)
            .getDocuments()
            .documents
     
        var comments: [Comment] = []
        let decoder = Firestore.Decoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        for snapshot in snapshots {
            do {
                comments.append(try await snapshot.reference.getDocument(as: Comment.self, decoder: decoder))
            }
            catch {
                print("Error fetching initial comments: \(error.localizedDescription)")
            }
        }
        
        return (comments: comments, lastDoc: snapshots.last)
    }
    
    func getAdditionalPaginatedComments(
        of postId: String,
        after lastDocumentSnapshot: QueryDocumentSnapshot?
    ) async throws -> (comments: [Comment], lastDoc: QueryDocumentSnapshot?) {
        
        guard let lastSnapshot = lastDocumentSnapshot
        else {
            print("Last document found to be nil.")
            throw FirestoreErorr.documentFoundToBeNil
        }
        
        let snapshots = try await threadsSetCollectionPath.document(postId).collection(FirestoreConstants.commentSet)
            .order(by: FirestoreConstants.commentCreatedTime, descending: true)
            .start(afterDocument: lastSnapshot)
            .limit(to: FirestoreConstants.documentLimit)
            .getDocuments()
            .documents
        
           var comments: [Comment] = []
           let decoder = Firestore.Decoder()
           decoder.keyDecodingStrategy = .convertFromSnakeCase
           for snapshot in snapshots {
               do {
                   comments.append(try await snapshot.reference.getDocument(as: Comment.self, decoder: decoder))
               }
               catch {
                   print("Error fetching additional comments: \(error.localizedDescription)")
               }
           }

        return (comments: comments, lastDoc: snapshots.last)
    }
    
    /// Get Best 5 comments.
    /// - Parameter postId: Id of the post to query best comments.
    /// - Returns: Comments list.
    func getBestComments(of postId: String) async throws -> [Comment] {
        let postDocPath = threadsSetCollectionPath.document(postId)
        guard let postData = try await postDocPath
            .getDocument()
            .data() else {
            return []
        }
        
        let commentIds = postData[FirestoreConstants.cachedBestCommentIdList] as? [String] ?? []
        var comments: [Comment] = []
        let decoder = Firestore.Decoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        for id in commentIds {
            let data = postDocPath
                .collection(FirestoreConstants.commentSet)
                .document(id)
           
            do {
                let comment = try await data.getDocument(as: Comment.self, decoder: decoder)
                comments.append(comment)
            }
            catch {
                print("Error fetching best comments: \(error.localizedDescription)")
            }
        }
        return comments
    }
        
    
    /// Fetch all the recommnets of a certain comment
    func getRecomments(postId: String, commentId: String) async throws -> [Recomment] {
        let snapshots = try await threadsSetCollectionPath
            .document(postId)
            .collection(FirestoreConstants.commentSet)
            .document(commentId)
            .collection(FirestoreConstants.recommentSet)
            .getDocuments()
            .documents
        
        let recomments = snapshots.map { snapshot in
            let data = snapshot.data()
            
            let commentId = snapshot.reference.documentID
            let recommentAuthorUid = data[FirestoreConstants.recommentAuthorUid] as? String ?? FirestoreConstants.noUserUid
            let recommentContentText = data[FirestoreConstants.recommentContentText] as? String ?? FirestoreConstants.noUserUid
            let recommentCreatedTime = data[FirestoreConstants.recommentCreatedTime] as? Timestamp ?? Timestamp(date: Date())
            let recommentId = data[FirestoreConstants.recommentId] as? String ?? FirestoreConstants.noUserUid
            
            return Recomment(
//                commentId: commentId,
                recommentAuthorUid: recommentAuthorUid,
                recommentContentText: recommentContentText,
                recommentCreatedTime: recommentCreatedTime,
                recommentId: recommentId
            )
        }
        
        return recomments
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

        return metaData
    }
    
    // MARK: - Get user
    func getUser(_ userId: String) async throws -> User {
        return try await self.userSetCollectionPath
            .document(userId)
            .getDocument(as: User.self)
    }
    
}

// MARK: - Setters
extension FirestoreManager {
    
    //MARK: - Save User Info
    func saveUser(_ user: User) throws {
        let userSet = self.userSetCollectionPath
            .document(user.id)
        
        try userSet.setData(
            from: user,
            merge: true
        ) { _ in
            print("User sucessfully saved!")
        }
    }
    
    //MARK: - Save Post
    func savePostImage(postId: String, images: [Data], completion: @escaping ([String]) -> Void) {
        
        let group = DispatchGroup()
        var imagePaths: [String] = []
        
        for image in images {
            
            let imageId = UUID().uuidString
            let path = "dev_threads/threads/thread_set/\(postId)/\(imageId).jpg"
            let uploadRef = Storage.storage().reference(withPath: path)
            
            let uploadMetadata = StorageMetadata()
            uploadMetadata.contentType = "image/jpeg"
            
            group.enter()
            uploadRef.putData(image, metadata: uploadMetadata) { metadata, error in
                group.leave()
                guard error == nil else {
                    print("Error uploading image to Firebase Storage. --- " + String(describing: error?.localizedDescription))
                    return
                }
                guard metadata != nil else {
                    print("Metadata found to be nil.")
                    return
                }
                imagePaths.append(path)
            }
        }
        
        group.notify(queue: .main) {
            completion(imagePaths)
        }
    }
    
    func savePost(_ post: Post) throws {
        let threadSet = self.threadsSetCollectionPath
            .document(post.id)
        let encoder = Firestore.Encoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        
        try threadSet.setData(from: post,
                              merge: true,
                              encoder: encoder) { _ in
            print("Post sucessfully save!")
        }
    }
    
    //MARK: - Save Comment
    func saveComment(to postId: String, _ comment: Comment) async throws {
        
        /// Save Comments to `comment_set` collection.
        let commentSet = self.threadsSetCollectionPath
            .document(postId)
            .collection(FirestoreConstants.commentSet)
            .document(comment.commentId)
        
        let encoder = Firestore.Encoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        
        try commentSet.setData(
            from: comment,
            merge: true,
            encoder: encoder
        ) {
            _ in
            print("Comment sucessfully save!")
        }
        
        /// Increment `cached_comment_count`
        let post = self.threadsSetCollectionPath
            .document(postId)
        
        try await post.updateData([
            FirestoreConstants.cachedCommentCount: FieldValue.increment(Int64(1))
        ])
    }
    
    func saveCommentImage(to postId: String, image: Data?) async throws -> String? {
        
        guard let photo = image else {
            return nil
        }
        
        let imageId = UUID().uuidString
        let path = "dev_threads/threads/thread_set/\(postId)/comment_set/\(imageId).jpg"
        
        let uploadMetadata = StorageMetadata()
        uploadMetadata.contentType = "image/jpeg"
        
        let uploadRef = Storage.storage().reference(withPath: path)
        let _ = try await uploadRef.putDataAsync(photo)
        
        return path
    }
    
    // MARK: - Save Recomment.
    func saveRecomment(postId: String,
                       commentId: String,
                       recomment: Recomment) throws {
        let recommentId = UUID().uuidString
        
        let recommentDoc = threadsSetCollectionPath
            .document(postId)
            .collection(FirestoreConstants.commentSet)
            .document(commentId)
            .collection(FirestoreConstants.recommentSet)
            .document(recomment.recommentId)
        
        let encoder = Firestore.Encoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        
        try recommentDoc.setData(from: recomment,
                                 merge: true,
                                 encoder: encoder)
        
    }
    
}

// MARK: - Update like counts
extension FirestoreManager {
    /// Like count update 시 사용.
    private func updateCachedBestCommentIdList(postId: String) async throws {
        // 1. Sort best 5 comments from comment_set
        let comments = try await threadsSetCollectionPath
            .document(postId)
            .collection(FirestoreConstants.commentSet)
            .order(by: FirestoreConstants.cachedCommentLikedCount, descending: true)
            .limit(to: FirestoreConstants.bestCommentLimit)
            .getDocuments()
            .documents
        
        let commentIds = comments.map { snapshot in
            let data = snapshot.data()
            return data[FirestoreConstants.commentId] as? String ?? ""
        }
        
        // 2. Update best 5 comments to the post field.
        try await threadsSetCollectionPath
            .document(postId)
            .updateData([
                FirestoreConstants.cachedBestCommentIdList: FieldValue.arrayUnion(commentIds)
            ])
    }
    
    //MARK: - Update Like
    
    /// Check if the current user has liked a post.
    /// - Parameter postId: Id of a post.
    func isPostLiked(postId: String) async throws -> Bool {
        let userId = UserDefaults.standard.string(forKey: UserDefaultsConstants.userId) ?? UserDefaultsConstants.noUserFound
        
        let data = try await threadsSetCollectionPath
            .document(postId)
            .getDocument()
            .data()
        
        let likedUserList: [String] = data?[FirestoreConstants.likedUserIdList] as? [String] ?? []
        
        return likedUserList.contains { $0 == userId }
    }
    
    func isCommentLiked(postId: String, commentId: String) async throws -> Bool {
        let userId = UserDefaults.standard.string(forKey: UserDefaultsConstants.userId) ?? UserDefaultsConstants.noUserFound
        
        let data = try await threadsSetCollectionPath
            .document(postId)
            .collection(FirestoreConstants.commentSet)
            .document(commentId)
            .getDocument()
            .data()
        
        let likedUserList: [String] = data?[FirestoreConstants.commentLikedUserUidList] as? [String] ?? []
        
        return likedUserList.contains { $0 == userId }
    }
    
    // Like button tap
    func updatePostLike(postId: String, isLiked: Bool) async throws {
        
        let userId = UserDefaults.standard.string(forKey: UserDefaultsConstants.userId) ?? UserDefaultsConstants.noUserFound
        
        // 1. Update like user uid list and cached like counts
        switch isLiked {
        case true:
            try await threadsSetCollectionPath
                .document(postId)
                .updateData([
                    FirestoreConstants.likedUserIdList: FieldValue.arrayUnion([userId]),
                    FirestoreConstants.cachedLikedCount: FieldValue.increment(Int64(1))
                ])
        case false:
            try await threadsSetCollectionPath
                .document(postId)
                .updateData([
                    FirestoreConstants.likedUserIdList: FieldValue.arrayRemove([userId]),
                    FirestoreConstants.cachedLikedCount: FieldValue.increment(Int64(-1))
                ])
        }
    }
    
    func updateCommentLike(postId: String, commentId: String, isLiked: Bool) async throws {
        let userId = UserDefaults.standard.string(forKey: UserDefaultsConstants.userId) ?? UserDefaultsConstants.noUserFound
        
        switch isLiked {
        case true:
            try await threadsSetCollectionPath
                .document(postId)
                .collection(FirestoreConstants.commentSet)
                .document(commentId)
                .updateData([
                    FirestoreConstants.commentLikedUserUidList: FieldValue.arrayUnion([userId]),
                    FirestoreConstants.cachedCommentLikedCount: FieldValue.increment(Int64(1))
                ])
        case false:
            try await threadsSetCollectionPath
                .document(postId)
                .collection(FirestoreConstants.commentSet)
                .document(commentId)
                .updateData([
                    FirestoreConstants.commentLikedUserUidList: FieldValue.arrayRemove([userId]),
                    FirestoreConstants.cachedCommentLikedCount: FieldValue.increment(Int64(-1))
                ])
        }
        // 2. Update cached_best_comment_id_list
        try await self.updateCachedBestCommentIdList(postId: postId)
    }
    
}

// MARK: - Patch
extension FirestoreManager {
    
    func editPost(
        of postId: String,
        title: String,
        content: String,
        images: [String]?
    ) async throws {
        do {
            try await threadsSetCollectionPath
                .document(postId)
                .updateData([
                    FirestoreConstants.title: title,
                    FirestoreConstants.contentText: content,
                    FirestoreConstants.contentImagePathList: FieldValue.arrayUnion(images ?? [])
                ])
            print("Post successfully edited!")
        }
        catch {
            print("Error editing post#\(postId) -- \(error.localizedDescription)")
        }
    }
    
    func editComment(
        of postId: String,
        commentId: String,
        commentToEdit: String,
        imageToEdit: String?
    ) async throws {
        do {
            if let image = imageToEdit {
                try await threadsSetCollectionPath
                    .document(postId)
                    .collection(FirestoreConstants.commentSet)
                    .document(commentId)
                    .updateData([
                        FirestoreConstants.commentContentText: commentToEdit,
                        FirestoreConstants.commentContentImagePath: image,
                        FirestoreConstants.commentCreatedTime: Timestamp()
                    ])
            } else {
                try await threadsSetCollectionPath
                    .document(postId)
                    .collection(FirestoreConstants.commentSet)
                    .document(commentId)
                    .updateData([
                        FirestoreConstants.commentContentText: commentToEdit,
                        FirestoreConstants.commentCreatedTime: Timestamp()
                    ])
            }
            
                
            print("Comment successfully edited!")
        }
        catch {
            print("Error editing comment#\(commentId) of post#\(postId) -- \(error.localizedDescription)")
        }
    }
    
}

// MARK: - Delete
extension FirestoreManager {
    func deleteImageFromStorage(path: String?) async throws {
        guard let path = path else { return }
        let ref = Storage.storage().reference(withPath: path)
        try await ref.delete()
        print("Successfully deleted image from Storage.")
    }
    
    func deleteComment(postId: String, commentId: String) async throws {
        try await threadsSetCollectionPath
            .document(postId)
            .collection(FirestoreConstants.commentSet)
            .document(commentId)
            .delete()
        print("Successfully deleted the comment#\(commentId) of post#\(postId).")
    }
}

//MARK: - Convert `Query Document` to `Post`
extension FirestoreManager {
    
    private func convertQueryDocumentToPost(_ queryDocument: QueryDocumentSnapshot) async throws -> Post {
        let decoder = Firestore.Decoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try await queryDocument.reference.getDocument(as: Post.self, decoder: decoder)
    }
    
}

extension FirestoreManager {
    enum FirestoreErorr: Error {
        case documentNotFound
        case documentFoundToBeNil
    }
}

/// Codes when `cached_comment_count` was not introduced to db.
/// Currently NOT IN USE.
extension FirestoreManager {
    
    /// Fetch all the posts
    func getAllPosts() async throws -> [Post] {
        let snapshots = try await db.collectionGroup(FirestoreConstants.threadSetCollection)
            .getDocuments()
            .documents
        
        // Convert document snapshot to `Post`.
        var posts: [Post] = []
        for snapshot in snapshots {
            posts.append(try await self.convertQueryDocumentToPost(snapshot))
        }

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
            
            let commentAuthorUid = data[FirestoreConstants.commentAuthorUid] as? String ?? FirestoreConstants.noUserUid
            let commentContentImagePath = data[FirestoreConstants.commentContentImagePath] as? String
            let commentContentText = data[FirestoreConstants.commentContentText] as? String ?? FirestoreConstants.noUserUid
            let commentCreatedTime = data[FirestoreConstants.commentCreatedTime] as? Timestamp ?? Timestamp(date: Date())
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
    
    
    /// Fetch all the comments of a certain post
    func getComments(of postId: String) async throws -> [Comment] {
        let snapshots = try await db            .collection("\(FirestoreConstants.devThreads)/\(FirestoreConstants.threads)/\(FirestoreConstants.threadSetCollection)/\(postId)/\(FirestoreConstants.commentSet)")
            .getDocuments()
            .documents
        
        var comments: [Comment] = []
        let decoder = Firestore.Decoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        for snapshot in snapshots {
            do {
                comments.append(try await snapshot.reference.getDocument(as: Comment.self, decoder: decoder))
            }
            catch {
                print("Error fetching comments: \(error.localizedDescription)")
            }
        }
        return comments
       
    }
    
    func getAllInitialPostContent() async throws -> (posts: [PostContent], lastDoc: QueryDocumentSnapshot?) {
        var contents: [PostContent] = []
        let results = try await self.getPaginatedPosts()

        for post in results.posts {
            let content = PostContent(
                post: post,
                comments: nil
            )
            contents.append(content)
        }

        return (posts: contents, lastDoc: results.lastDoc)
    }
    
    func getAllAdditionalPostContent(after lastDoc: QueryDocumentSnapshot?) async throws -> (posts: [PostContent], lastDoc: QueryDocumentSnapshot?) {
        var contents: [PostContent] = []
        let results = try await self.getAdditionalPaginatedPosts(after: lastDoc)
        
        for post in results.posts {
            print(post.id)
            let comments = try await self.getComments(of: post.id)
            
            let content = PostContent(
                post: post,
                comments: comments
            )
            contents.append(content)
        }
        return (posts: contents, lastDoc: results.lastDoc)
    }
    
}
