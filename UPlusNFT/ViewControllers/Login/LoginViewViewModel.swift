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
    @Published var todayRank: Int = RankingConstants.totalMembers
    
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
                self.errorDescription = "이메일/비밀번호를 확인해주세요."
                self.isLoginSuccess.send(false)
            }
        }
        
    }
    
    private func saveLocalUserBasicInfo() async {

            do {
                let userEmail = Auth.auth().currentUser?.email ?? FirestoreConstants.noUserEmail
                let currentUser = try await FirestoreManager.shared.getCurrentUserInfo(email: userEmail)
                
                if let encodedUserData = try? JSONEncoder().encode(currentUser) {
                    UserDefaults.standard.setValue(encodedUserData, forKey: UserDefaultsConstants.currentUser)
                    print("User Info Result: \(currentUser)")
                } else {
                    print("Error encoding user data -- \(errorDescription)")
                }

            }
            catch {
                switch error {
                case FirestoreErorr.userNotFound:
                    self.errorDescription = "가입되지 않은 사용자입니다."
                    print("User not found!")
                default:
                    print("Error fetching user -- \(error)")
                }
            }

    }
    
}

//MARK: - Fetch Data from FireStore
extension LoginViewViewModel {
    func getTodayRank(of userIndex: String) {
        Task {
            
            do {
                let results = try await firestoreManager.getAllUserTodayPoint()
                let rank = results.firstIndex {
                    return String(describing: $0.userIndex) == userIndex
                } ?? (RankingConstants.totalMembers - 1)
                self.todayRank = rank + 1
            }
            catch {
                print("Error getting today's points: \(error)")
            }
            
        }
    }
}
