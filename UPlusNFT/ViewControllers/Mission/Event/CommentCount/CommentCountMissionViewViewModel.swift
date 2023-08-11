//
//  CommentCountMissionViewViewModel.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/08/09.
//

import Foundation
import Combine

final class CommentCountMissionViewViewModel {
    
    private let firestoreManager = FirestoreManager.shared
    
    var mission: CommentCountMission
    
    var comment: String?
    
    @Published var imageUrls: [URL] = [] {
        willSet {
            combinations["ImageUrls"] = newValue
        }
    }
    
    @Published var comments: [String] = [] {
        didSet {
            combinations["comments"] = comments
        }
    }
    
    @Published var commentCountMap: [String: Int64] = [:] {
        didSet {
            combinations["commentCountMap"] = commentCountMap
        }
    }
    
    @Published var combinations: [String: Any] = [:]
    
    @Published var participated: Bool = false
    
    init(mission: CommentCountMission) {
        self.mission = mission
        self.comments = mission.commentUserRecents ?? []
        self.commentCountMap = mission.commentCountMap ?? [:]
        
        self.getImageUrls()
        
        do {
            let user = try UPlusUser.getCurrentUser()
            if self.comments.contains(user.userNickname) {
                self.participated = true
            }
        }
        catch {
            print("Error fetching user info from UserDefaults -- \(error)")
        }
        
    }
}

extension CommentCountMissionViewViewModel {
    private func getImageUrls() {
        Task {
            do {
                let imagePaths = mission.missionContentImagePaths ?? []
                var imageUrls: [URL] = []
                for imagePath in imagePaths {
                    imageUrls.append(try await FirebaseStorageManager.shared.getDataUrl(reference: imagePath))
                }
                self.imageUrls = imageUrls
            }
            catch {
                print("Error downloading image url -- \(error)")
            }
        }
    }
}

extension CommentCountMissionViewViewModel {
    func saveComment() {
        Task {
            do {
                print("Prev commts: \(mission.commentUserRecents ?? [])")
                try await self.firestoreManager.saveParticipatedEventMission(
                    type: .commentCount,
                    eventId: mission.missionId,
                    selectedIndex: nil,
                    recentComments: mission.commentUserRecents ?? [],
                    comment: self.comment,
                    point: mission.missionRewardPoint
                )
            }
            catch {
                
            }
        }
    }
}
