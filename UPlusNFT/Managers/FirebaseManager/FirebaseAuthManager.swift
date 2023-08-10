//
//  FirebaseAuthManager.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/08/04.
//

import Foundation
import FirebaseAuth

final class FirebaseAuthManager {
    
    //MARK: - Init
    static let shared = FirebaseAuthManager()

}

extension FirebaseAuthManager {
    /// Create User Account using FirebaseAuth.
    /// - Parameters:
    ///   - email: User email to register.
    ///   - password: Password.
    func createAccount(email: String, password: String) async throws -> AuthDataResult {
        return try await Auth.auth().createUser(withEmail: email, password: email)
    }
}
