//
//  CommentCountMissionViewViewModel.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/08/09.
//

import Foundation
import Combine

final class CommentCountMissionViewViewModel: EventBaseModel {

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
    
    override init(mission: any Mission) {
        super.init(mission: mission)
        
        guard let mission = self.mission as? CommentCountMission else { return }
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

