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
    var errorDescription: String = ""
    
    private(set) var hasEmailSent = PassthroughSubject<Bool, Never>()
    
    func sendResetEmail() {

        Task {
            do {
                print("Email entered: \(email)")
               try await Auth.auth().sendPasswordReset(withEmail: email)
                self.hasEmailSent.send(true)
            }
            catch (let error) {
                let err = error as? AuthErrorCode
                switch err {
                case .none:
                    break
                case .some(let wrapped):
                    if wrapped.code == .userNotFound {
                        self.errorDescription = "등록되지 않은 이메일입니다."
                    }
                    if wrapped.code == .invalidEmail {
                        self.errorDescription = "유효하지 않은 이메일 형식입니다."
                    }
                    self.errorDescription = ResetPasswordConstants.checkEmail
                }
                logger.error("Error sending password reset email -- \(error.localizedDescription)")
                self.hasEmailSent.send(false)
            }
        }
        
    }
    
}
