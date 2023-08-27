//
//  LoginViewViewModel.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/06/21.
//

import Foundation
import Combine
import FirebaseAuth
import OSLog

final class LoginViewViewModel {
    
    // MARK: - Dependency
    private let firestoreManager = FirestoreManager.shared
    
    // MARK: - Property
    var fullEmail: String = ""
    @Published var email: String = "" {
        didSet {
            self.fullEmail = self.email + SignUpConstants.emailSuffix
        }
    }
    @Published var password: String = ""
    @Published var errorDescription: String = ""
    @Published var isKeepMeSignedIntTapped: Bool = false
    @Published var isPasswordHidden: Bool = true
    
    let isLoginSuccess = PassthroughSubject<Bool, Never>()
    
    private(set) lazy var isCredentialNotEmpty = Publishers.CombineLatest($email, $password)
        .map {
            return !$0.isEmpty && !$1.isEmpty ? true : false
        }.eraseToAnyPublisher()
    
    // MARK: - Internal
    func login() {
        
        Task {
            do {
                try await Auth.auth().signIn(withEmail: self.fullEmail, password: self.password)
                await self.saveLocalUserBasicInfo()
                print("Signed in.")
                self.isLoginSuccess.send(true)
            }
            catch (let error) {
                print("Error loging in user: \(error.localizedDescription)")
                self.errorDescription = LoginConstants.wrongCredential
                self.isLoginSuccess.send(false)
            }
        }
        
    }
    
    private func saveLocalUserBasicInfo() async {

            do {
                let userEmail = Auth.auth().currentUser?.email ?? FirestoreConstants.noUserEmail
                let _ = try await UPlusUser.saveCurrentUser(email: userEmail)
            }
            catch {
                switch error {
                case FirestoreError.userNotFound:
                    self.errorDescription = "가입되지 않은 사용자입니다."
                    print("User not found!")
                default:
                    print("Error fetching user -- \(error)")
                }
            }

    }
    
}
