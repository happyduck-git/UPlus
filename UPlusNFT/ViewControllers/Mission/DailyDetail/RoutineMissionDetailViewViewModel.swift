//
//  RoutineMissionDetailViewViewModel.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/28.
//

import UIKit.UIImage
import Combine

protocol RoutineMissionDetailViewViewModelDelegate: AnyObject {
    func didRecieveMission()
}

final class RoutineMissionDetailViewViewModel {
    
    // MARK: - Dependency
    private let firestoreManager = FirestoreManager.shared
    private let nftServiceManager = NFTServiceManager.shared
    
    //MARK: - Delegate
    weak var delegate: RoutineMissionDetailViewViewModelDelegate?
    
    // MARK: - DataSource
    var missionType: MissionType
    @Published var selectedImage: UIImage?
    
    /* Routine Mission */
    @Published var daysLeft: String = ""
    @Published var athleteMissions: [AthleteMission] = [] {
        didSet {
            self.successedMissionsCount = athleteMissions.count
        }
    }
    @Published var isFinishedRoutines: Bool?
    @Published var successedMissionsCount: Int = 0
    
    // MARK: - Init
    init(missionType: MissionType) {
        self.missionType = missionType
    }
    
}

// MARK: - Firestore
extension RoutineMissionDetailViewViewModel {
    
    func getAtheleteMissions() {
        Task {
            do {
                let user = try UPlusUser.getCurrentUser()

                let (daysLeft, missions) = try await self.firestoreManager.getRoutineMissionInfo(missionType: .dailyExpAthlete, userIndex: user.userIndex)
                self.daysLeft = daysLeft
                self.athleteMissions = missions
                
                if missions.count >= MissionConstants.routineMissionLimit {
                    
                    self.isFinishedRoutines = true
                    //TODO: isFinishedRoutines bind하여 true인 경우 참여 버튼 비활성화.
                } else {
                    self.isFinishedRoutines = false
                }
                
                self.delegate?.didRecieveMission()
            }
            catch {
                print("Error fetching athelete missions -- \(error)")
            }
        }
    }
    
    func getTodayMissionInfo() async -> (any Mission)? {
        do {
            return try await self.firestoreManager.getTodayMission(missionType: self.missionType)
        }
        catch {
            print("Error get today's mission -- \(error)")
            return nil
        }
    }
    
}
