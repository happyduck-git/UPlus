//
//  DailyRoutineMIssionViewController.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/07/27.
//

import UIKit

class DailyRoutineMIssionViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

  
    }

}

/*
 
 Task {
     do {
         
         // 1. Check missions
         let missions = try await FirestoreManager.shared.getDailyAthleteMission()
         // 2. Check participation status (in user_state_map)
         let statusMap = missions.compactMap {
             ($0.missionId, $0.missionUserStateMap)
         }
         
         // 3. if status is succeeded get point / if pending or failed show the status
         
         print("Current User: \(statusMap)")
     }
     catch {
         print("Error fetching athlete missions: \(error)")
     }
 }
 
 */
