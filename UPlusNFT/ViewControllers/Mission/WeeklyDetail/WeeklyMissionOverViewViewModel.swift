
//
//  WeeklyMissionOverViewViewModel.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/03.
//

import Foundation
import Combine
import UIKit.UIImage
import OSLog

final class WeeklyMissionOverViewViewModel {
    
    private let logger = Logger()
    
    private let firestoreManager = FirestoreManager.shared
    private let nftServiceManager = NFTServiceManager.shared
    
    /* Header */
    var endDate: Date
    var endDateDescription: String = ""
    
    var week: Int = 1
    var title: String = "UPlus 알아가기"
    var missionDays: String = "미션 참여 기간: 08.07 - 08.14"
    var nftImage: UIImage? = nil
    
    /* Missions */
    var missionParticipation: [String: Bool] = [:] {
        didSet {
            if missionParticipation.allSatisfy({ $0.value == true }) {
                self.weeklyMissionCompletion.send(true)
            } else {
                self.weeklyMissionCompletion.send(false)
            }
            
            self.numberOfCompeletion.send((self.week, self.countTrueValues(in: missionParticipation)))
        }
    }
    
    @Published var weeklyMissions: [any Mission] = [] {
        didSet {
            do {
                let user = try UPlusUser.getCurrentUser()
                var status: [String: Bool] = [:]
                
                for mission in self.weeklyMissions {
                    let map = mission.missionUserStateMap ?? [:]
                    let hasParticipated = map.contains { ele in
                        ele.key == String(describing: user.userIndex)
                    }
                    
                    status[mission.missionId] = hasParticipated
                }
                self.missionParticipation = status
                
            }
            catch {
                print("Error getting user info from UserDefaults -- \(error)")
            }
        }
    }
    var weeklyMissionCompletion = PassthroughSubject<Bool, Never>()
    var numberOfCompeletion = PassthroughSubject<(Int, Int), Never>()
    
    @Published var nftIssueStatus = PassthroughSubject<Bool, NFTServiceError>()
    
    // MARK: - Init
    init(week: Int, endDate: Date) {
        self.week = week
        self.endDate = endDate
        self.getWeeklyMissionInfo(week: week)
        
        let monthAndDay = endDate.monthDayFormat
        print("Month and day: \(monthAndDay)")
        let (month, day) = self.splitByDot(input: monthAndDay) ?? ("09", "09")
        self.endDateDescription = String(format: MissionConstants.weeklyTopTitle, month, day)
        print("Enddate: \(self.endDateDescription)")
    }
    
}

// MARK: - Firestore Service
extension WeeklyMissionOverViewViewModel {
    
    func getWeeklyMissionInfo(week: Int) {
        Task {
            do {
                self.weeklyMissions = try await self.firestoreManager.getWeeklyMission(week: week)
            }
            catch {
                print("Error fetching weekly mission data -- \(error)")
            }
        }
    }

}

// MARK: - NFT Service
extension WeeklyMissionOverViewViewModel {
    
    func requestJourneyNft() {
        Task {
            do {
                let user = try UPlusUser.getCurrentUser()
                let result = try await nftServiceManager.requestSingleNft(
                    userIndex: user.userIndex,
                    nftType: .journey,
                    level: week
                )
                
                guard let status = NFTServiceStatus(rawValue: result.data.status) else { return }
                switch status {
                case .pending:
                    self.nftIssueStatus.send(true)
                case .fail:
                    self.nftIssueStatus.send(completion: .failure(.issueFailed))
                }
            }
            catch {
                print("Error requesting nft to NFTServiceInfra -- \(error)")
            }
        }
    }
}

// MARK: - Private
extension WeeklyMissionOverViewViewModel {
    private func countTrueValues(in dictionary: [String: Bool]) -> Int {
        return dictionary.values.filter { $0 == true }.count
    }
    
    private func splitByDot(input: String) -> (String, String)? {
        let components = input.split(separator: ".", maxSplits: 1, omittingEmptySubsequences: true)
        if components.count == 2 {
            return (String(components[0]), String(components[1]))
        } else {
            return nil
        }
    }
}
