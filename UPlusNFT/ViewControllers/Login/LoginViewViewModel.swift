//
//  LoginViewViewModel.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/06/21.
//

import Foundation
import FirebaseAuth

final class LoginViewViewModel {
    
    private func login(email: String, password: String) async throws -> Bool {
        do {
            try await Auth.auth().signIn(withEmail: email, password: password)
            print("Signed in.")
            return true
        }
        catch (let error) {
            print("Error loging in user: \(error.localizedDescription)")
            return false
        }
    }
    
}
