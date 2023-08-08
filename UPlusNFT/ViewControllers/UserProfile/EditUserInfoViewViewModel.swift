//
//  EditUserInfoViewViewModel.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/07.
//

import Foundation
import FirebaseAuth
import Combine

final class EditUserInfoViewViewModel {
    
    @Published var currentPassword: String = ""
    @Published var newPassword: String = ""
    @Published var newPasswordCheck: String = ""
    
    private(set) lazy var isAllFilled = Publishers.CombineLatest4($currentPassword, $newPassword, $newPasswordCheck, isSame)
        .map {
            return ($0.count >= 6) && ($1.count >= 6) && ($2.count >= 6) && $3 ? true : false
        }.eraseToAnyPublisher()
    
    private(set) lazy var isSame = Publishers.CombineLatest($newPassword, $newPasswordCheck)
        .map {
            return $0 == $1
        }.eraseToAnyPublisher()
 
}

extension EditUserInfoViewViewModel {
    func updatePassword(newPassword: String) async throws {
        try await Auth.auth().currentUser?.updatePassword(to: newPassword)
    }
}
