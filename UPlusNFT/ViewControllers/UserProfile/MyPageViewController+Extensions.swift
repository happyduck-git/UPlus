//
//  MyPageViewController+Extensions.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/08/17.
//

import Foundation

extension MyPageViewController: BaseMissionViewControllerDelegate {
    func redeemDidTap(vc: BaseMissionViewController) {
        if vc is GovernanceElectionMissionViewController {
            Task {
                await self.vm.getLevelEvents()
            }
        }
        if vc is ShareMediaOnSlackMissionViewController {
            print("SOS")
        }
        if vc is CommentCountMissionViewController {
            print("CCM")
        }
        if vc is ContentReadOnlyMissionViewController {
            print("CROM")
        }
    }
}

extension MyPageViewController: CommentCountMissionViewControllerDelegate {
    func checkAnswerDidTap() {
        
    }
}
