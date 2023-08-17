//
//  FirestoUPlusNftreManager.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/06/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage
import FirebaseAuth

enum FirestoreError: Error {
    case documentNotFound
    case documentFoundToBeNil
    case userNotFound
    case invalidEmail
}

final class FirestoreManager {
    
    //MARK: - Init
    static let shared = FirestoreManager()
    
    private init() {
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.encoder.keyEncodingStrategy = .convertToSnakeCase
    }
    
    //MARK: - Property

    // Decoder
    private let decoder = Firestore.Decoder()
    private let encoder = Firestore.Encoder()
    
    // Database
    private let db = Firestore.firestore()
    
    /* uplus_missions_v2 */
    private let dummyCollection = Firestore.firestore().collection("gene_threads")
    
    private let threadsSetCollectionPath2 = Firestore.firestore().collection(FirestoreConstants.devThreads2)
    
    /* uplus_posts_and_missions_v1 */
    private let threadsSetCollectionPath = Firestore.firestore().collection("\(FirestoreConstants.devThreads)/\(FirestoreConstants.threads)/\(FirestoreConstants.threadSetCollection)")
    private let userSetCollectionPath =
    Firestore.firestore().collection("\(FirestoreConstants.devThreads)/\(FirestoreConstants.users)/\(FirestoreConstants.userSetCollection)")
    
    // Pagination
    var isPagenating: Bool = false
    var queryDocumentSnapshot: QueryDocumentSnapshot?
}

/* Signup logic */
extension FirestoreManager {

    func isAccountable(email: String) async throws -> (isAccountable: Bool, isVip: Bool) {
        let data = try await threadsSetCollectionPath2
            .document(FirestoreConstants.configuration)
            .getDocument()
            .data()
        
        let accountableEmails = data?[FirestoreConstants.accountableEmails] as? [String] ?? []
        let vipEmails = data?[FirestoreConstants.vipNftHolderEmails] as? [String] ?? []
        
        // 1. Check is accountable
        let isAccountable = accountableEmails.contains {
            $0 == email
        }
        // 2. Check is vip
        let isVip = vipEmails.contains {
            $0 == email
        }
        
        return (isAccountable, isVip)
    }
    
}

/* uplus_missions_v3 */
//MARK: - UPlus Current User
extension FirestoreManager {
    
    /// Get user's document path that has been created before registring the account.
    /// - Parameter email: User email.
    /// - Returns: Document snapshot.
    private func getCurrentUserDocumentPath(email: String) async throws -> QueryDocumentSnapshot {
        let documents = try await threadsSetCollectionPath2
            .document(FirestoreConstants.users)
            .collection(FirestoreConstants.userSetCollection)
            .whereField(FirestoreConstants.userEmail, isEqualTo: email)
            .getDocuments()
            .documents
        
        guard let currentUserDoc = documents.first else {
            throw FirestoreError.userNotFound
        }
        return currentUserDoc
    }
    
    private func getCurrentUserPointHistory(snapshot: QueryDocumentSnapshot) async throws -> [PointHistory] {
        let documents = try await snapshot.reference
            .collection(FirestoreConstants.userPointHistory)
            .getDocuments()
            .documents
        
        var pointHistory: [PointHistory] = []
        
        for doc in documents {
            pointHistory.append(try doc.data(as: PointHistory.self, decoder: self.decoder))
        }
        
        return pointHistory
    }
    
    // MARK: - Setters
    
    /// Save created account's information.
    /// - Parameters:
    ///   - email: User email.
    ///   - uid: Auth user account.
    ///   - creationTime: Account created time.
    func saveUserInfo(email: String, uid: String, creationTime: Timestamp) async throws {
        let currentUserDoc = try await self.getCurrentUserDocumentPath(email: email)
        
        try await currentUserDoc.reference.setData([
            FirestoreConstants.userUid: uid,
            FirestoreConstants.accountCreationTime: creationTime
        ], merge: true)
    }
    
    func saveVipUserInitialPoint(userIndex: Int64) async throws {
        let batch = self.db.batch()
        let today = Date().yearMonthDateFormat
        
        // userDocRef
        let userDocRef = self.threadsSetCollectionPath2
            .document(FirestoreConstants.users)
            .collection(FirestoreConstants.userSetCollection)
            .document(String(describing: userIndex))
        
        // userPointHistoryDocRef
        let userPointHistoryDocRef = userDocRef
            .collection(FirestoreConstants.userPointHistory)
            .document(today)
        
        // userBaseDocRef
        let userBaseDocRef =  self.threadsSetCollectionPath2
            .document(FirestoreConstants.users)
        
        // dailyPointHistoryDocPath
        let dailyPointHistoryDocPath = self.threadsSetCollectionPath2
            .document(FirestoreConstants.users)
            .collection(FirestoreConstants.dailyPointHistorySet)
            .document(today)
        
        batch.setData(
            [
                FirestoreConstants.userTotalPoint: FieldValue.increment(SignUpConstants.vipHolderInitialPoint)
            ],
            forDocument: userDocRef,
            merge: true
        )
        
        batch.setData(
            [
                FirestoreConstants.userPointCount: FieldValue.increment(SignUpConstants.vipHolderInitialPoint),
                FirestoreConstants.userPointTime: today
            ],
            forDocument: userPointHistoryDocRef,
            merge: true
        )
        
        batch.setData(
            [
                FirestoreConstants.pointHistoryUserCountMap: [String(describing: SignUpConstants.vipHolderInitialPoint): FieldValue.increment(Int64(1))]
            ],
            forDocument: dailyPointHistoryDocPath,
            merge: true
        )
        
        batch.setData(
            [
                FirestoreConstants.usersPointUserCountMap: [String(describing: SignUpConstants.vipHolderInitialPoint): FieldValue.increment(Int64(1))]
            ],
            forDocument: userBaseDocRef,
            merge: true
        )
        
        try await batch.commit()
    }
    
    // MARK: - Getters
    func getCurrentUserInfo(email: String) async throws -> UPlusUser {
        do {
            let currentUserDoc = try await self.getCurrentUserDocumentPath(email: email)
            var user = try currentUserDoc.data(as: UPlusUser.self, decoder: self.decoder)
            user.userPointHistory = try await self.getCurrentUserPointHistory(snapshot: currentUserDoc)
            return user
        }
        catch {
            print("Error getting current User - \(error)")
            throw FirestoreError.userNotFound
        }
    }
    
    /// Fetch membership NFT image url of the user who finished the user registration.
    /// - Parameter userIndex: User index.
    /// - Returns: Nft image url string.
    func getMemberNft(userIndex: Int64, isVip: Bool) async throws -> String {
        
        // NOTE: nft index는 Alchemy에서 받아올 예정.
        let docId: Int64 = isVip ? userIndex : (userIndex + 10_000)

        let doc = try await threadsSetCollectionPath2
            .document(FirestoreConstants.nfts)
            .collection(FirestoreConstants.nftSet)
            .document(String(describing: docId))
            .getDocument()
        
        let nft = try doc.data(as: UPlusNft.self, decoder: self.decoder)
       
        return nft.nftContentImageUrl
    }
    
    func getNft(tokenId: String) async -> UPlusNft? {
        do {
            let doc = try await threadsSetCollectionPath2
                .document(FirestoreConstants.nfts)
                .collection(FirestoreConstants.nftSet)
                .document(String(describing: tokenId))
                .getDocument()
            
            return try doc.data(as: UPlusNft.self, decoder: self.decoder)
        }
        catch {
            print("Error fetching Nft info -- \(error)")
            return nil
        }
    }
    
    /// Get NFT document of a certain document reference.
    /// - Parameter reference: DocumentReference.
    /// - Returns: UPlusNft object.
    func getNft(reference: DocumentReference) async throws -> UPlusNft {
        let snapshot = try await reference.getDocument()
        return try snapshot.data(as: UPlusNft.self, decoder: self.decoder)
    }
    
    func getOwnedNfts(referenceList: [DocumentReference], completion: @escaping (Result<[UPlusNft], Error>) -> Void) {
        var nfts: [UPlusNft] = []
        let dispatchGroup = DispatchGroup()

        for ref in referenceList {
            dispatchGroup.enter()
            ref.getDocument { (snapshot, error) in
                defer { dispatchGroup.leave() }

                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let snapshot = snapshot,
                      let nft = try? snapshot.data(as: UPlusNft.self, decoder: self.decoder) else {
                    completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to decode document"])))
                    return
                }

                nfts.append(nft)
            }
        }

        dispatchGroup.notify(queue: .main) {
            completion(.success(nfts))
        }
    }
    
    func getOwnedRewards(referenceList: [DocumentReference], completion: @escaping (Result<[Reward], Error>) -> Void) {
        var rewards: [Reward] = []
        let dispatchGroup = DispatchGroup()
        
        for ref in referenceList {
            dispatchGroup.enter()
            ref.getDocument { (snapshot, error) in
                defer { dispatchGroup.leave() }
                
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let snapshot = snapshot,
                      let reward = try? snapshot.data(as: Reward.self, decoder: self.decoder) else {
                    completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to decode document"])))
                    return
                }

                rewards.append(reward)
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(.success(rewards))
        }
    }
    
}

//MARK: - Get Users Point
extension FirestoreManager {
    
    func getTodayPointHistory() async throws -> [PointHistory] {

        let documents = try await self.db.collectionGroup(FirestoreConstants.userPointHistory)
            .whereField(FirestoreConstants.userPointTime, isEqualTo: Date().yearMonthDateFormat)
            .order(by: FirestoreConstants.userPointCount, descending: true)
            .getDocuments()
            .documents
        
        var points: [PointHistory] = []
        
        for doc in documents {
            var point = try doc.data(as: PointHistory.self, decoder: self.decoder)
            point.userIndex = doc.reference.parent.parent?.documentID
            points.append(point)
        }
        
        return points
        
    }
    
    func getYesterdayPointHistory() async throws -> [PointHistory] {
        
        let today = Date()
        let calendar = Calendar.current
        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today) else {
            return []
        }
        
        let documents = try await self.db.collectionGroup(FirestoreConstants.userPointHistory)
            .whereField(FirestoreConstants.userPointTime, isEqualTo: yesterday.yearMonthDateFormat)
            .order(by: FirestoreConstants.userPointCount, descending: true)
            .getDocuments()
            .documents
        
        var points: [PointHistory] = []

        for doc in documents {
            var point = try doc.data(as: PointHistory.self, decoder: self.decoder)
            point.userIndex = doc.reference.parent.parent?.documentID
            points.append(point)
        }

        return points
    }
    
}

//MARK: - Get Users Point
extension FirestoreManager {

    func getAllPointHistory() async throws -> [PointHistory] {
        
        let documents = try await self.db.collectionGroup(FirestoreConstants.userPointHistory)
            .order(by: FirestoreConstants.userPointCount, descending: true)
            .getDocuments()
            .documents
        
        var points: [PointHistory] = []

        for doc in documents {
            var point = try doc.data(as: PointHistory.self, decoder: self.decoder)
            point.userIndex = doc.reference.parent.parent?.documentID
            points.append(point)
        }

        return points
    }
    
    private func getSingleUser(_ userIndex: String) async throws -> UPlusUser {
        
        let document = try await self.dummyCollection
            .document(FirestoreConstants.users)
            .collection(FirestoreConstants.userSetCollection)
            .document(userIndex)
            .getDocument()
        
        return try document.data(as: UPlusUser.self, decoder: self.decoder)
    }
        
    func getAllUserTotalPoint() async throws -> [UPlusUser] {
        let documents = try await self.threadsSetCollectionPath2
            .document(FirestoreConstants.users)
            .collection(FirestoreConstants.userSetCollection)
            .order(by: FirestoreConstants.userTotalPoint, descending: true)
            .getDocuments()
            .documents
     
        var users: [UPlusUser] = []
        
        for doc in documents {
            do {
                let userData = try doc.data(as: UPlusUser.self, decoder: self.decoder)
                users.append(userData)
            }
            catch {
                print("Error decoding UPlusUser -- \(error)")
                continue
            }
        }
        print("Total point 개수: \(documents.count)")
        return users
    }
    
}

/* uplus_missions_v3 - Getters */
extension FirestoreManager {
    
    /// Get User Selected Routine MissionType.
    /// - Parameter userIndex: Current User's index.
    /// - Returns: Optional MissionType.
    func getUserSelectedRoutineMission(userIndex: Int64) async throws -> MissionType? {
        let data = try await self.threadsSetCollectionPath2
            .document(FirestoreConstants.users)
            .collection(FirestoreConstants.userSetCollection)
            .document(String(describing: userIndex))
            .getDocument()
            .data()
        guard let rawVal = data?[FirestoreConstants.selectedMissionTopic] as? String else {
            return nil
        }
        
        return MissionType(rawValue: rawVal)
    }
    
    /* Daily Mission */
    func getDailyAthleteMission() async throws -> [AthleteMission] {
        let documents = try await threadsSetCollectionPath2.document(FirestoreConstants.missions)
            .collection(FirestoreConstants.dailyExpAthleteMissionSet)
            .getDocuments()
            .documents
        
        var missions: [AthleteMission] = []
        for doc in documents {
            missions.append(try doc.data(as: AthleteMission.self, decoder: self.decoder))
        }
        return missions
    }
    
    func getRoutineMission(type: MissionType) async throws -> [any Mission] {
        let documents = try await threadsSetCollectionPath2.document(FirestoreConstants.missions)
            .collection(type.storagePathFolderName)
            .getDocuments()
            .documents
        var missions: [any Mission] = []
        
        switch type {
        case .dailyExpAthlete:
            for doc in documents {
                missions.append(try doc.data(as: AthleteMission.self, decoder: self.decoder))
            }
        case .dailyExpGoodWorker:
            for doc in documents {
                missions.append(try doc.data(as: GoodWorkerMission.self, decoder: self.decoder))
            }
        case .dailyExpEnvironmentalist:
            for doc in documents {
                missions.append(try doc.data(as: EnvironmentalistMission.self, decoder: self.decoder))
            }
        default:
            break
        }
        
        return missions
    }
    
    func convertToMission(doc: DocumentReference) async throws -> (any Mission)? {
        let doc = try await doc.getDocument()
        let type = doc.data()?[FirestoreConstants.missionTopicType] as? String ?? "n/a"
        let topicType = MissionTopicType(rawValue: type) ?? .eventMission
        
        switch topicType {
        case .dailyExp:
            return try doc.data(as: RoutineMission.self, decoder: self.decoder)
        case .weeklyQuiz:
            return try doc.data(as: MissionModel.self, decoder: self.decoder)
            
        default:
            return nil
        }
    }
    
    /* Weekly Mission */
    func getWeeklyMission(week: Int) async throws -> [any Mission] {
        
        let weekCollection = String(format: "weekly_quiz__%d__mission_set", week)
        
        let documents = try await threadsSetCollectionPath2.document(FirestoreConstants.missions)
            .collection(weekCollection)
            .getDocuments()
            .documents
        
        var missions: [any Mission] = []
        
        for doc in documents {
            let data = doc.data()
            let type = data[FirestoreConstants.missionFormatType] as? String ?? "n/a"
           
            let formatType = MissionFormatType(rawValue: type)

            switch formatType {
            case .photoAuth:
                missions.append(try doc.data(as: PhotoAuthMission.self, decoder: self.decoder))
            case .choiceQuiz:
                missions.append(try doc.data(as: ChoiceQuizMission.self, decoder: self.decoder))
            case .answerQuiz:
                missions.append(try doc.data(as: ShortAnswerQuizMission.self, decoder: self.decoder))
            case .contentReadOnly:
                missions.append(try doc.data(as: ContentReadOnlyMission.self, decoder: self.decoder))

            default:
                break
            }
            
        }
      
        return missions
    }
    
    func getEvent() async throws -> [any Mission] {
    
        let documents = try await threadsSetCollectionPath2
            .document(FirestoreConstants.missions)
            .collection(MissionType.eventMission.storagePathFolderName)
            .getDocuments()
            .documents
        
        var missions: [any Mission] = []
        
        for doc in documents {
            do {
                let data = doc.data()
                let type = data[FirestoreConstants.missionFormatType] as? String ?? "n/a"
               
                let formatType = MissionFormatType(rawValue: type)
                switch formatType {
                case .contentReadOnly:
                    missions.append(try doc.data(as: ContentReadOnlyMission.self, decoder: self.decoder))
                    
                case .shareMediaOnSlack:
                    missions.append(try doc.data(as: MediaShareMission.self, decoder: self.decoder))
                    
                case .governanceElection:
                    missions.append(try doc.data(as: GovernanceMission.self, decoder: self.decoder))
                    
                case .commentCount:
                    missions.append(try doc.data(as: CommentCountMission.self, decoder: self.decoder))
                    
                default:
                    break
                }
            }
            catch {
                continue
            }
            
        }

        return missions
    }
    
    func getAllMissionDate() async throws -> [String: [Timestamp]] {
        let data = try await threadsSetCollectionPath2
            .document(FirestoreConstants.missions)
            .getDocument()
            .data()
        
        return data?[FirestoreConstants.missionTimelineMap] as? [String: [Timestamp]] ?? [:]
    }
    
    /// Fetch all the mission hitory that the user has participated.
    /// - Parameter user: User.
    /// - Returns: An array of PointHistory.
    func getAllParticipatedMissionHistory(user: UPlusUser) async throws -> [PointHistory] {
        
        let docs = try await threadsSetCollectionPath2
            .document(FirestoreConstants.users)
            .collection(FirestoreConstants.userSetCollection)
            .document(String(describing: user.userIndex))
            .collection(FirestoreConstants.userPointHistory)
            .getDocuments()
            .documents
        
        var history: [PointHistory] = []

        for doc in docs {
            history.append(try doc.data(as: PointHistory.self, decoder: self.decoder))
        }
        
        return history
    }
 
}

/* uplus_missions_v3 - Setters(Mission) */
extension FirestoreManager {
    
    /// When a user submitted a mission answer, save data to related documents.
    /// - Parameters:
    ///   - userIndex: User index.
    ///   - questionId: Question document id.
    ///   - week: Number of current week.
    ///   - date: YYYYmmdd format date string.
    ///   - missionType: Mission type.
    ///   - point: Point the user gets from the mission.
    ///   - state: Mission completion state.
    func saveParticipatedWeeklyMission(
        questionId: String,
        week: Int,
        today: String,
        missionType: MissionType,
        point: Int64,
        state: MissionAnswerState
    ) async throws {
        
        var user = try UPlusUser.getCurrentUser()
        
        let batch = self.db.batch()
        
        // 1. Save to missions collection
        let weekCollection = String(format: "weekly_quiz__%d__mission_set", week)
        let missionDocPath = threadsSetCollectionPath2
            .document(FirestoreConstants.missions)
            .collection(weekCollection)
            .document(questionId)
        
        // userDocRef
        let userDocRef = self.threadsSetCollectionPath2
            .document(FirestoreConstants.users)
            .collection(FirestoreConstants.userSetCollection)
            .document(String(describing: user.userIndex))
        
        // userBaseDocRef
        let userBaseDocRef =  self.threadsSetCollectionPath2
            .document(FirestoreConstants.users)
        
        // dailyPointHistoryDocPath
        let dailyPointHistoryDocPath = self.threadsSetCollectionPath2
            .document(FirestoreConstants.users)
            .collection(FirestoreConstants.dailyPointHistorySet)
            .document(today)
        
        batch.setData(
            [
                FirestoreConstants.missionUserStateMap: [String(describing: user.userIndex): state.rawValue]
            ],
            forDocument: missionDocPath,
            merge: true)
        
        // 2. Save to user_type_mission_array_map
        let userDocPath = threadsSetCollectionPath2
            .document(FirestoreConstants.users)
            .collection(FirestoreConstants.userSetCollection)
            .document(String(describing: user.userIndex))
        
        if state == .successed {
            batch.setData(
                [
                    FirestoreConstants.userTotalPoint: FieldValue.increment(point),
                    FirestoreConstants.userTypeMissionArrayMap: [
                        missionType.rawValue: FieldValue.arrayUnion([missionDocPath]) 
                    ]
                ],
                forDocument: userDocPath,
                merge: true)
        }
        
        let pointHistoryDocPath = userDocPath.collection(FirestoreConstants.userPointHistory)
            .document(today)
        // 3. Save to user_point_history
        batch.setData(
            [
                FirestoreConstants.userPointCount: FieldValue.increment(point),
                FirestoreConstants.userPointMissions: FieldValue.arrayUnion([missionDocPath]),
                FirestoreConstants.userPointTime: today
            ],
            forDocument: pointHistoryDocPath,
            merge: true)
        
        // 4. daily
        let (todayPrevPoint, todayNewPoint) = self.fetchCurrentUserPoint(
            userPointHistory: user.userPointHistory,
            earningPoint: point,
            today: today
        )
        
        batch.setData(
            [
                FirestoreConstants.pointHistoryUserCountMap: [String(describing: todayPrevPoint): FieldValue.increment(Int64(-1))]
            ],
            forDocument: userDocRef,
            merge: true
        )
        
        batch.setData(
            [
                FirestoreConstants.pointHistoryUserCountMap: [String(describing: todayNewPoint): FieldValue.increment(Int64(1))],
                
            ],
            forDocument: userDocRef,
            merge: true
        )
        
        let previousPoint = user.userTotalPoint ?? 0
        let newPoint = previousPoint + point
        batch.setData(
            [
                FirestoreConstants.usersPointUserCountMap: [String(describing: previousPoint): FieldValue.increment(Int64(-1))]
            ],
            forDocument: userBaseDocRef,
            merge: true)
        
        batch.setData(
            [
                FirestoreConstants.usersPointUserCountMap: [String(describing: newPoint): FieldValue.increment(Int64(1))]
            ],
            forDocument: userBaseDocRef,
            merge: true)
        
        // dailyPointHistory
        batch.setData(
            [
                FirestoreConstants.pointHistoryUserCountMap: [String(describing: previousPoint): FieldValue.increment(Int64(-1))]
            ],
            forDocument: dailyPointHistoryDocPath,
            merge: true)
        
        batch.setData(
            [
                FirestoreConstants.pointHistoryUserCountMap: [String(describing: newPoint): FieldValue.increment(Int64(1))]
            ],
            forDocument: dailyPointHistoryDocPath,
            merge: true)
        
        
        
        try await batch.commit()
        
        // Update UserDefaults
        user.userTotalPoint = newPoint

        let dailyPointHistory = self.updateCurrentUserPoint(
            userIndex: user.userIndex,
            userPointHistory: user.userPointHistory,
            today: today,
            todayNewPoint: todayNewPoint,
            missionDocPath: missionDocPath
        )

        user.userPointHistory = dailyPointHistory
        try UPlusUser.updateUser(user)
    
    }
    
    func saveParticipatedDailyMission(
        missionType: MissionType,
        image: Data
    ) async throws {
        
        var user = try UPlusUser.getCurrentUser()
        
        //1. Save photo to Storage
        let imageId = UUID().uuidString
        let path = "dev_threads/missions/mission_set/\(missionType.storagePathFolderName)/\(user.userIndex)/\(imageId).jpg"
        let uploadRef = Storage.storage().reference(withPath: path)
        
        let uploadMetadata = StorageMetadata()
        uploadMetadata.contentType = "image/jpeg"
        
        let _ = try await uploadRef.putDataAsync(image, metadata: uploadMetadata)
        
        // 2. Save user state and mission_photo_task to missions.
        let batch = self.db.batch()
        let participationDate = Date()

        // missionDocRef
        let missionDocRef = self.threadsSetCollectionPath2
            .document(FirestoreConstants.missions)
            .collection(missionType.storagePathFolderName)
            .document(participationDate.yearMonthDateFormat)
        
        // missionPhotoTaskSetDocRef
        let missionPhotoTaskSetDocRef = self.threadsSetCollectionPath2
            .document(FirestoreConstants.missions)
            .collection(missionType.storagePathFolderName)
            .document(participationDate.yearMonthDateFormat)
            .collection(FirestoreConstants.missionPhotoTaskSet)
            .document(String(describing: user.userIndex))
        
        // userDocRef
        let userDocRef = threadsSetCollectionPath2
            .document(FirestoreConstants.users)
            .collection(FirestoreConstants.userSetCollection)
            .document(String(describing: user.userIndex))
        
        // userPointHistoryDocRef
        let userPointHistoryDocRef = userDocRef
            .collection(FirestoreConstants.userPointHistory)
            .document(participationDate.yearMonthDateFormat)

        batch.setData(
            [
                FirestoreConstants.missionUserStateMap: [String(describing: user.userIndex): MissionUserState.pending.rawValue]
            ],
            forDocument: missionDocRef,
            merge: true)

        let ref = Storage.storage().reference(withPath: path)
        
        let photoTask = MissionPhotoTask(missionPhotoTaskUser: userDocRef,
                                         missionPhotoTaskImagePath: String(describing: ref), //TODO: gs:// 로 변경.
                                         missionPhotoTaskTime: Timestamp(date: participationDate))
        
        
        try batch.setData(from: photoTask,
                          forDocument: missionPhotoTaskSetDocRef,
                          merge: true,
                          encoder: self.encoder)

        batch.setData(
            [
                FirestoreConstants.userPointTime: participationDate.yearMonthDateFormat,
                FirestoreConstants.userPointCount: FieldValue.increment(Int64(0)),
                FirestoreConstants.userPointMissions: FieldValue.arrayUnion([missionDocRef])
            ],
            forDocument: userPointHistoryDocRef,
            merge: true
        )

        // Update batch
        try await batch.commit()
        
        // Update UserDefaults
        let (_, todayNewPoint) = self.fetchCurrentUserPoint(
            userPointHistory: user.userPointHistory,
            earningPoint: 0,
            today: participationDate.yearMonthDateFormat
        )
        
        let dailyPointHistory = self.updateCurrentUserPoint(
            userIndex: user.userIndex,
            userPointHistory: user.userPointHistory,
            today: participationDate.yearMonthDateFormat,
            todayNewPoint: todayNewPoint,
            missionDocPath: missionDocRef
        )

        user.userPointHistory = dailyPointHistory
        try UPlusUser.updateUser(user)
    }
    
    func saveSelectedRoutineMission(type: MissionType, userIndex: Int64) async throws {
        try await self.threadsSetCollectionPath2
            .document(FirestoreConstants.users)
            .collection(FirestoreConstants.userSetCollection)
            .document(String(describing: userIndex))
            .setData([FirestoreConstants.selectedMissionTopic: type.rawValue],
                     merge: true)
    }
    
    
    /// Save and update related values of missions.
    /// - Parameters:
    ///   - type: MissionFormatType.
    ///   - eventId: eventId.
    ///   - selectedIndex: selectedIndex for Governance Mission.
    ///   - comment: comment for Comment Mission.
    ///   - point: point.
    func saveParticipatedEventMission(
        type: MissionFormatType,
        eventId: String,
        selectedIndex: Int?,
        recentComments: [String],
        comment: String?,
        point: Int64
    ) async throws {
        
        var user = try UPlusUser.getCurrentUser()
        
        let today = Date().yearMonthDateFormat
        
        let batch = self.db.batch()
        // userDocRef
        let userDocRef = self.threadsSetCollectionPath2
            .document(FirestoreConstants.users)
            .collection(FirestoreConstants.userSetCollection)
            .document(String(describing: user.userIndex))
        
        // userBaseDocRef
        let userBaseDocRef =  self.threadsSetCollectionPath2
            .document(FirestoreConstants.users)
        
        // userPoint doc path
        let userPointDocPath = userDocRef
            .collection(FirestoreConstants.userPointHistory)
            .document(today)
            
        let dailyPointHistoryDocPath = self.threadsSetCollectionPath2
            .document(FirestoreConstants.users)
            .collection(FirestoreConstants.dailyPointHistorySet)
            .document(today)
        
        // Event doc path
        let eventDocPath = threadsSetCollectionPath2
            .document(FirestoreConstants.missions)
            .collection(MissionType.eventMission.storagePathFolderName)
            .document(eventId)
        
        switch type {
        case .contentReadOnly:
            batch.setData(
                [
                    FirestoreConstants.userTypeMissionArrayMap: [MissionType.eventMission.rawValue: FieldValue.arrayUnion([userDocRef]) ]
                ],
                forDocument: userDocRef,
                merge: true
            )
        case .shareMediaOnSlack:
            batch.setData(
                [
                    FirestoreConstants.shareMediaOnSlackDownloadedUsers: FieldValue.arrayUnion([String(describing: user.userIndex)])
                ],
                forDocument: eventDocPath,
                merge: true
            )
            batch.setData(
                [
                    FirestoreConstants.userTypeMissionArrayMap: [MissionType.eventMission.rawValue: FieldValue.arrayUnion([userDocRef]) ]
                ],
                forDocument: userDocRef,
                merge: true
            )
 
        case .governanceElection:
            guard let selectedIndex = selectedIndex else {
                print("Governance event에 선택된 답변이 없습니다.")
                return
            }
            
            batch.setData(
                [
                    FirestoreConstants.governanceElectionUserMap: [String(describing: selectedIndex): FieldValue.arrayUnion([userDocRef])]
                ],
                forDocument: eventDocPath,
                merge: true
            )
            
        case .commentCount:
            guard let comment = comment else {
                print("Comment event에 제출된 답변이 없습니다.")
                return
            }
            
            var recentComments: [String] = recentComments
            recentComments.append(contentsOf: [user.userNickname, comment])
            
            batch.setData(
                [
                    FirestoreConstants.commentCountMap: [comment: FieldValue.increment(Int64(1))],
                    FirestoreConstants.commentUserRecents: recentComments
                ],
                forDocument: eventDocPath,
                merge: true
            )
            batch.setData(
                [
                    FirestoreConstants.userTypeMissionArrayMap: [MissionType.eventMission.rawValue: FieldValue.arrayUnion([userDocRef]) ]
                ],
                forDocument: userDocRef,
                merge: true
            )
    
        default:
            break
        }

        batch.setData(
            [
                FirestoreConstants.missionUserStateMap: [String(describing: user.userIndex): MissionUserState.succeeded.rawValue]
            ],
            forDocument: eventDocPath,
            merge: true
        )
        
        batch.setData(
            [
                FirestoreConstants.userTotalPoint: FieldValue.increment(Int64(point))
            ],
            forDocument: userDocRef,
            merge: true
        )
        
        batch.setData(
            [
                FirestoreConstants.userPointTime: today,
                FirestoreConstants.userPointCount: FieldValue.increment(Int64(point)),
                FirestoreConstants.userPointMissions: FieldValue.arrayUnion([eventDocPath])
            ],
            forDocument: userPointDocPath,
            merge: true
        )

        let (todayPrevPoint, todayNewPoint) = self.fetchCurrentUserPoint(
            userPointHistory: user.userPointHistory,
            earningPoint: point,
            today: today
        )
        
        batch.setData(
            [
                FirestoreConstants.pointHistoryUserCountMap: [String(describing: todayPrevPoint): FieldValue.increment(Int64(-1))]
            ],
            forDocument: userDocRef,
            merge: true
        )
        
        batch.setData(
            [
                FirestoreConstants.pointHistoryUserCountMap: [String(describing: todayNewPoint): FieldValue.increment(Int64(1))],
                
            ],
            forDocument: userDocRef,
            merge: true
        )
        
        //usersPointUserCountMap
        let previousPoint = user.userTotalPoint ?? 0
        let newPoint = previousPoint + point
        batch.setData(
            [
                FirestoreConstants.usersPointUserCountMap: [String(describing: previousPoint): FieldValue.increment(Int64(-1))]
            ],
            forDocument: userBaseDocRef,
            merge: true)
        
        batch.setData(
            [
                FirestoreConstants.usersPointUserCountMap: [String(describing: newPoint): FieldValue.increment(Int64(1))]
            ],
            forDocument: userBaseDocRef,
            merge: true)
        
        // pointHistoryUserCountMap
        batch.setData(
            [
                FirestoreConstants.pointHistoryUserCountMap: [String(describing: previousPoint): FieldValue.increment(Int64(-1))]
            ],
            forDocument: dailyPointHistoryDocPath,
            merge: true)
        
        batch.setData(
            [
                FirestoreConstants.pointHistoryUserCountMap: [String(describing: newPoint): FieldValue.increment(Int64(1))]
            ],
            forDocument: dailyPointHistoryDocPath,
            merge: true)
        
        // Update batch
        try await batch.commit()
        
        // Update UserDefaults
        user.userTotalPoint = newPoint

        let dailyPointHistory = self.updateCurrentUserPoint(
            userIndex: user.userIndex,
            userPointHistory: user.userPointHistory,
            today: today,
            todayNewPoint: todayNewPoint,
            missionDocPath: eventDocPath
        )

        user.userPointHistory = dailyPointHistory
        try UPlusUser.updateUser(user)
    }
   
    func checkWeeklyMissionSetCompletion(week: Int) async throws -> Bool {
        let user = try UPlusUser.getCurrentUser()
        
        let weekCollection = String(format: "weekly_quiz__%d__mission_set", week)
        let missionDocCounts = try await threadsSetCollectionPath2
            .document(FirestoreConstants.missions)
            .collection(weekCollection)
            .getDocuments()
            .count
        
        let weekMissionKey = "weekly_quiz__%d"
        let userSuccessedMissionCounts = user.userTypeMissionArrayMap?[weekMissionKey]?.count ?? 0
        
        return missionDocCounts == userSuccessedMissionCounts ? true : false
    }
    
}

/* uplus_missions_v3 - Mission Private */
extension FirestoreManager {
    
    private func fetchCurrentUserPoint(
        userPointHistory: [PointHistory]?,
        earningPoint: Int64,
        today: String
    ) -> (todayPrevPoint: Int64, todayNewPoint: Int64) {
        let dailyPointHistory = userPointHistory ?? []

        let filtered = dailyPointHistory.filter {
            $0.userPointTime == today
        }.first
        let todayPrevPoint = filtered?.userPointCount ?? 0
        let todayNewPoint = todayPrevPoint + earningPoint
        
        return (todayPrevPoint, todayNewPoint)
    }
    
    private func updateCurrentUserPoint(
        userIndex: Int64,
        userPointHistory: [PointHistory]?,
        today: String,
        todayNewPoint: Int64,
        missionDocPath: DocumentReference
    )
    -> [PointHistory] {
        var dailyPointHistory = userPointHistory ?? []
        
        if let index = dailyPointHistory.firstIndex(where: {
            $0.userPointTime == today
        }) {
            dailyPointHistory[index].userPointCount = todayNewPoint
            dailyPointHistory[index].userPointMissions?.append(missionDocPath)
            
        } else {
            dailyPointHistory.append(
                PointHistory(
                    userIndex: String(describing: userIndex),
                    userPointTime: today,
                    userPointCount: todayNewPoint,
                    userPointMissions: [missionDocPath]
                )
            )
        }
        return dailyPointHistory
    }
   
}

extension FirestoreManager {
    
    /// Update the user owned nft list after comparing to the nft list received from API.
    /// - Parameter tokens: NFT token id list.
    func updateOwnedNfts(tokens: [String], userIndex: Int64) async throws {
        
        let paths = tokens.map { token in
            self.generateDocPath(pathIds: [
                FirestoreConstants.devThreads2,
                FirestoreConstants.nfts,
                FirestoreConstants.nftSet,
                token
            ])
        }
       
        try await threadsSetCollectionPath2
            .document(FirestoreConstants.users)
            .collection(FirestoreConstants.userSetCollection)
            .document(String(describing: userIndex))
            .setData(
                [
                    FirestoreConstants.userNfts: FieldValue.arrayUnion(paths)
                ],
                merge: true)
        
    }
    
    private func generateDocPath(pathIds: [String]) -> DocumentReference {
        var pathString: String = ""
        let divider: String = "/"
        for pathId in pathIds {
            pathString += divider
            pathString += pathId
        }
        return Firestore.firestore().document(pathString)
    }
}

/* uplus_missions_v2 */
extension FirestoreManager {
    
    // MARK: - Get Missions
    
    /*
    func getRoutineMission(type: MissionType) async throws -> [RoutineMission] {
        let documents = try await threadsSetCollectionPath2.document(FirestoreConstants.missions)
            .collection(type.storagePathFolderName)
            .getDocuments()
            .documents
        
        var missions: [RoutineMission] = []
        
        for doc in documents {
            missions.append(try doc.data(as: RoutineMission.self, decoder: self.decoder))
        }
        return missions
    }
    */
    
    // NOTE: mission type이 한가지로 정해지면 missionType argument 삭제 가능.
    func getRoutineMissionInfo(missionType: MissionType, userIndex: Int64) async throws -> (daysLeft: String, participatedMission: [AthleteMission]) {
        
        let daysLeft = try await self.getRoutineMissionPeriod(missonType: missionType)
        let participatedMission = try await getParticipatedRoutineMissionList(userIndex: userIndex, missionType: missionType)
        
        return (daysLeft, participatedMission)
    }
    
    private func getRoutineMissionPeriod(missonType: MissionType) async throws -> String {
        let data = try await threadsSetCollectionPath2
            .document(FirestoreConstants.missions)
            .getDocument()
            .data()
        
        let beginEndTime = data?[FirestoreConstants.missionsBeginEndTimeMap] as? [String: [Timestamp]]
        let timeArray = beginEndTime?[missonType.storagePathFolderName]
        let begin = Timestamp(date: Date())
        let end = timeArray?[1] ?? Timestamp(date: Date())
        
        let daysLeft = self.daysBetween(from: begin, to: end)
    
        return String(describing: daysLeft)
    }
    
    private func getParticipatedRoutineMissionList(userIndex: Int64, missionType: MissionType) async throws -> [AthleteMission] {
        let data = try await threadsSetCollectionPath2
            .document(FirestoreConstants.users)
            .collection(FirestoreConstants.userSetCollection)
            .document(String(String(describing: userIndex)))
            .getDocument()
            .data()
        
        var missions: [AthleteMission] = []
        let map = data?[FirestoreConstants.userTypeMissionArrayMap] as? [String: [DocumentReference]]
        let refList = map?[missionType.rawValue] ?? []
        
        for ref in refList {
            await missions.append(try ref.getDocument().data(as: AthleteMission.self, decoder: self.decoder))
        }
        return missions
    }
    
    func getAthleteMission(userIndex: Int64) async throws -> [AthleteMission] {
        let documents = try await threadsSetCollectionPath2.document(FirestoreConstants.missions)
            .collection(FirestoreConstants.athleteMission)
            .getDocuments()
            .documents
        
        var missions: [AthleteMission] = []
        
        for doc in documents {
            missions.append(try doc.data(as: AthleteMission.self, decoder: self.decoder))
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
    
    func getTodayMission(missionType: MissionType) async throws -> any Mission {
        
        let doc = try await threadsSetCollectionPath2
            .document(FirestoreConstants.missions)
            .collection(missionType.rawValue)
            .document(Date().yearMonthDateFormat)
            .getDocument()
            
        switch missionType {
        case .dailyExpAthlete:
            return try doc.data(as: AthleteMission.self, decoder: decoder)
            
        case .dailyExpGoodWorker:
            return try doc.data(as: GoodWorkerMission.self, decoder: decoder)
            
        case .dailyExpEnvironmentalist:
            return try doc.data(as: EnvironmentalistMission.self, decoder: decoder)
            
        default:
            return try doc.data(as: EnvironmentalistMission.self, decoder: decoder)
        }
    }
    
    // MARK: - Get Rewards
    func getRewardsOwned(by ownerIndex: Int64) async throws -> [Reward] {
        let documents = try await threadsSetCollectionPath2
            .document(FirestoreConstants.rewards)
            .collection(FirestoreConstants.rewardSetCollection)
            .whereField(FirestoreConstants.rewardUser, isEqualTo: ownerIndex)
            .getDocuments()
            .documents
        
        let rewards = try documents.map { doc in
            try doc.data(as: Reward.self, decoder: self.decoder)
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
    
}

// MARK: - Utilities
extension FirestoreManager {
    private func daysBetween(from begin: Timestamp, to end: Timestamp) -> Int {
        let calendar = Calendar.current

        let date1 = calendar.startOfDay(for: begin.dateValue())
        let date2 = calendar.startOfDay(for: end.dateValue())

        let components = calendar.dateComponents([.day], from: date1, to: date2)
        
        return components.day ?? 0
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
            throw FirestoreError.documentFoundToBeNil
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
            throw FirestoreError.documentFoundToBeNil
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
