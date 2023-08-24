//
//  MyPageViewController+Extensions.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/08/17.
//

import Foundation

extension MyPageViewController: BaseMissionViewControllerDelegate {
    func redeemDidTap(vc: BaseMissionViewController) {
     
        print("Completed Redeem did tap")
        // get event mission info
        Task {
            await self.vm.getRegularEvents()
            await self.vm.getLevelEvents()
        }
    }
}

extension MyPageViewController: CommentCountMissionViewControllerDelegate {
    func submitCommentDidTap() {
        print("Comment event comment submit did tap")
        // get event mission info
        Task {
            await self.vm.getRegularEvents()
            await self.vm.getLevelEvents()
        }
    }
}
