//
//  CommentCountMissionViewViewModel.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/08/09.
//

import Foundation
import Combine
import FirebaseFirestore

final class CommentCountMissionViewViewModel: MissionBaseModel {

    // MARK: - Dependency
    private let firestoreManager = FirestoreManager.shared
    
    // MARK: - DataSource
    @Published var participationStatus: EventStatus
    var didUserLikeAnyComment: Bool = false
    
    @Published var comments: [MissionComment] = [] {
        didSet {
            self.numberOfComments = comments.count
        }
    }
    
    @Published var numberOfComments: Int = 0
    
    @Published var participated: Bool = false
    
    @Published var commentList: [UserCommentSet] = []
    @Published var isLikedList: [Bool] = []
    @Published var likesCountList: [Int] = []
    
    //MARK: - Init
    init(status: EventStatus,
         type: Type,
         mission: Mission,
         numberOfWeek: Int = 0) {
        
        self.participationStatus = status
        super.init(type: type, mission: mission)
        
        self.comments = self.getMissionComments(mission: mission)
    }

}

extension CommentCountMissionViewViewModel {
    
    func saveLikes() {
        Task {
            do {
                var commentIds: [String] = []
                
                for i in 0..<isLikedList.count {
                    if self.isLikedList[i] {
                        commentIds.append(self.commentList[i].commentId)
                    }
                    continue
                }
                
                try await self.firestoreManager
                    .saveCommentLikes(missionType: MissionType(rawValue: self.mission.missionSubTopicType) ?? .weeklyQuiz1,
                                      missionDoc: self.mission.missionId,
                                      didLikeAnyComment: self.didUserLikeAnyComment,
                                      commentIds: commentIds)
            }
            catch {
                UPlusLogger.logger.error("Error saving likes -- \(String(describing: error))")
            }
        }
    }
    
}

// MARK: - Private
extension CommentCountMissionViewViewModel {
    
    private func getMissionComments(mission: any Mission) -> [MissionComment] {
        guard let mission = mission as? CommentCountMission else { return [] }
        let userCommentSet = mission.userCommnetSet ?? []
        self.commentList = userCommentSet
        
        
        var comments: [MissionComment] = []
        for comment in userCommentSet {
            let isLiked: Bool = self.isLikedByCurrentUser(userRefs: comment.commentLikeUsers ?? [])
            let likes: Int = comment.commentLikeUsers?.count ?? 0
            
            self.didUserLikeAnyComment = isLiked ? true : false
            self.isLikedList.append(isLiked)
            self.likesCountList.append(likes)
            
            comments.append(
                MissionComment(userId: self.getUsernameFromReference(refString: comment.commentUser.path) ?? " ",
                               commentText: comment.commentText ?? " ",
                               likes: likes,
                               isLikedByCurrentUser: isLiked)
            )
        }
        return comments
    }
    
    private func getUsernameFromReference(refString: String) -> String? {
        let components = refString.components(separatedBy: "/")
        return components.last
    }
    
    private func isLikedByCurrentUser(userRefs: [DocumentReference]) -> Bool {
        do {
            let currentUser = try UPlusUser.getCurrentUser()
            for ref in userRefs {
                let username = self.getUsernameFromReference(refString: ref.path) ?? ""
                if username == currentUser.userNickname {
                    print("Has participated: True")
                    return true
                }
            }
            print("Has participated: False")
            return false
        }
        catch {
            UPlusLogger.logger.error("Error getting current user from UserDefaults -- \(String(describing: error))")
            return false
        }
    }
    
}

// MARK: - Mission Comment Model
struct MissionComment {
    let userId: String
    let commentText: String
    let likes: Int
    let isLikedByCurrentUser: Bool
}
