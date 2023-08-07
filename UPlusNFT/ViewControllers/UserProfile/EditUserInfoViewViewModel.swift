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
    
    @Published var newPassword: String = ""
    
    func updatePassword(newPassword: String) async throws {
        try await Auth.auth().currentUser?.updatePassword(to: newPassword)
    }
    
}
