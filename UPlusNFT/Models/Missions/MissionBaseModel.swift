//
//  MissionBaseModel.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/08/22.
//

import UIKit
import OSLog

class MissionBaseModel {
    
    enum `Type` {
        case weekly
        case event
    }
    
    // MARK: - Dependency
    private let firestoreManager = FirestoreManager.shared
    private let nftServiceManager = NFTServiceManager.shared
    
    // MARK: - Logger
    private let logger = Logger()
    
    // MARK: - Data
    let type: Type
    let mission: any Mission
    let numberOfWeek: Int
    
    //MARK: - Weekly
    // WeeklyMission Completion
    @Published var weeklyMissionCompletion: Bool = false
    
    // MARK: - ImageUrls
    @Published var imageUrls: [URL] = []
    
    //MARK: - Init
    init(type: Type, mission: any Mission, numberOfWeek: Int = 0) {
        self.type = type
        self.numberOfWeek = numberOfWeek
        self.mission = mission
        
        self.getImageUrls()
    }
    
}

// MARK: - Get Image Urls
extension MissionBaseModel {
    func getImageUrls() {
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

extension MissionBaseModel {
    // MARK: - HTML String
    
    func retrieveHtmlString(html: String) -> NSAttributedString? {
        if let data = html.data(using: .unicode),
           let attributedString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
            return attributedString
        }
        return nil
    }
    
    func openURL(from html: String) {
        let urlString = self.extractOutsideUrlString(from: html) ?? ""
        
        if let url = URL(string: urlString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    private func extractOutsideUrlString(from htmlString: String) -> String? {
        let pattern = "href=\"([^\"]*)\""
        
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let range = NSRange(location: 0, length: htmlString.utf16.count)
            
            if let match = regex.firstMatch(in: htmlString, options: [], range: range) {
                if let range = Range(match.range(at: 1), in: htmlString) {
                    return String(htmlString[range])
                }
            }
        } catch {
            print("Invalid regular expression")
        }
        
        return nil
    }
    
}

// MARK: - NFT Service
extension MissionBaseModel {
    
    func checkLevelUpdate() async throws {
        do {
            try await UserLevelPoint.userLevelUpdate(mission: self.mission,
                                                     nftType: .avatar,
                                                     firestoreManager: self.firestoreManager,
                                                     nftServiceManager: self.nftServiceManager)
        }
        catch {
            self.logger.error("Error updating user level -- \(String(describing: error))")
        }
  
    }
    
}

// MARK: - (Firestore) Save Weekly Mission Participation
extension MissionBaseModel {
    func saveWeeklyMissionParticipationStatus() async throws {
        guard let missionType = MissionType(rawValue: self.mission.missionSubTopicType) else {
             return
         }
        
        try await self.firestoreManager
            .saveParticipatedWeeklyMission(
                questionId: self.mission.missionId,
                week: self.numberOfWeek,
                today: Date().yearMonthDateFormat,
                missionType: missionType,
                point: self.mission.missionRewardPoint,
                state: .succeeded
            )
    }

    func checkMissionCompletion() async throws {
        self.weeklyMissionCompletion = try await self.firestoreManager.checkWeeklyMissionSetCompletion(week: self.numberOfWeek)
    }
    
}

//MARK: - (Firestore) Save Event Mission Participation
extension MissionBaseModel {
    func saveEventParticipationStatus(selectedIndex: Int?,
                                      recentComments: [String]?,
                                      comment: String?) async throws {
        
        guard let missionFormatType = MissionFormatType(rawValue: self.mission.missionFormatType),
              let missionType = MissionType(rawValue: self.mission.missionSubTopicType),
              let missionSubformatType = MissionSubFormatType(rawValue: self.mission.missionSubFormatType)
        else {
            return
        }
        
        try await self.firestoreManager
            .saveParticipatedEventMission(
                formatType: missionFormatType,
                subFormatType: missionSubformatType,
                missionType: missionType,
                eventId: self.mission.missionId,
                selectedIndex: selectedIndex,
                recentComments: recentComments ?? [],
                comment: comment,
                point: self.mission.missionRewardPoint
            )

    }
}
