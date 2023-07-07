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
    
    func saveUser() {
        Task {
            do {
                let userId = Auth.auth().currentUser?.uid ?? ""
                let username = Auth.auth().currentUser?.displayName ?? FirestoreConstants.noUsername
                let profileImageUrl = Auth.auth().currentUser?.photoURL
                var profileImageUrlString = ""
                if let profileImageUrl = profileImageUrl {
                    profileImageUrlString = String(describing: profileImageUrl)
                }
                
                UserDefaults.standard.setValue(userId, forKey: UserDefaultsConstants.userId)
                UserDefaults.standard.setValue(username, forKey: UserDefaultsConstants.username)
                UserDefaults.standard.setValue(profileImageUrlString, forKey: UserDefaultsConstants.profileImage)
                
                let user = User(
                    id: userId,
                    email: nil,
                    introduction: nil,
                    address: "wallet_address", //TODO: 생성된 실제 지갑 address 사용.
                    nickname: username,
                    profileImagePath: profileImageUrlString,
                    profilePageUrl: FirestoreConstants.urlPrefix + userId
                )
                try firestoreManager.saveUser(user)
            }
            catch {
                print("Error saving user: \(error.localizedDescription)")
            }
        }
    }
    
}

