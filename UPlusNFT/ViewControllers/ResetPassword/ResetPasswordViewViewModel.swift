//
//  ResetPasswordViewViewModel.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/06/22.
//

import Foundation
import FirebaseAuth
import Combine
import OSLog

final class ResetPasswordViewViewModel {
    
    private let logger = Logger()
    
    @Published var email: String = ""
    
    private(set) var hasEmailSent = PassthroughSubject<Bool, Never>()
    
    func sendResetEmail() {

        Task {
            do {
                print("Email entered: \(email)")
               try await Auth.auth().sendPasswordReset(withEmail: email)
                self.hasEmailSent.send(true)
            }
            catch {
                logger.error("Error sending password reset email -- \(error.localizedDescription)")
                self.hasEmailSent.send(false)
            }
        }
        
    }
    
}
