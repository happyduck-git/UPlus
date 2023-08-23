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
    }
}

extension MyPageViewController: CommentCountMissionViewControllerDelegate {
    func checkAnswerDidTap() {
        
    }
}
