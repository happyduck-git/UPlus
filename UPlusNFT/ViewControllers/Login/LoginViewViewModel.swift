//
//  LoginViewViewModel.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/06/21.
//

import Foundation
import Combine
import FirebaseAuth

final class LoginViewViewModel {
    
    var fullEmail: String = ""
    @Published var email: String = "" {
        didSet {
            self.fullEmail = self.email + SignUpConstants.emailSuffix
        }
    }
    @Published var password: String = ""
    @Published var errorDescription: String = ""
    
    
    let isLoginSuccess = PassthroughSubject<Bool, Never>()
    
    private(set) lazy var isCredentialNotEmpty = Publishers.CombineLatest($email, $password)
        .map {
            return !$0.isEmpty && !$1.isEmpty ? true : false
        }.eraseToAnyPublisher()
    
    
    func login() {
        
        Task {
            do {
                try await Auth.auth().signIn(withEmail: self.fullEmail, password: self.password)
                print("Signed in.")
                self.isLoginSuccess.send(true)
            }
            catch (let error) {
                print("Error loging in user: \(error.localizedDescription)")
                self.errorDescription = "이메일/비밀번호를 확인해주세요."
                self.isLoginSuccess.send(false)
            }
        }
        
    }
    
}

