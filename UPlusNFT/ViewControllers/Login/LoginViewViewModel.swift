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
    
    @Published var email: String = ""
    @Published var password: String = ""
    
    let isLoginSuccess = PassthroughSubject<Bool, Never>()
    
    private(set) lazy var isCredentialNotEmpty = Publishers.CombineLatest($email, $password)
        .map {
            return !$0.isEmpty && !$1.isEmpty ? true : false
        }.eraseToAnyPublisher()
    
    
    func login() {
        
        Task {
            do {
                try await Auth.auth().signIn(withEmail: self.email, password: self.password)
                print("Signed in.")
                self.isLoginSuccess.send(true)
            }
            catch (let error) {
                print("Error loging in user: \(error.localizedDescription)")
                self.isLoginSuccess.send(false)
            }
        }
        
    }
    
}
