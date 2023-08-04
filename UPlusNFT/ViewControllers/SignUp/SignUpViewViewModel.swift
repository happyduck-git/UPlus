//
//  SignUpViewViewModel.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/06/20.
//

import Foundation
import Combine
import RegexBuilder
import FirebaseAuth
import FirebaseFirestore
import OSLog

final class SignUpViewViewModel {
    
    let logger = Logger()
    
    //MARK: - Dependency
    private let firestoreManager = FirestoreManager.shared
    private let firebaseAuthManager = FirebaseAuthManager.shared
    
    // MARK: - DataSource
    var fullEmail = ""
    @Published var email = "" {
        didSet {
            fullEmail = self.email + SignUpConstants.emailSuffix
        }
    }
    @Published var password = ""
    @Published var passwordCheck = ""
    var isUserCreated = PassthroughSubject<Bool, Never>()
    var isEmailSent = PassthroughSubject<Bool, Never>()
    
    var errorDescription = ""
    var isValidUser: Bool = false
    var isVip: Bool = false
    
    private(set) lazy var isPasswordValid = $password.map {
        if $0.count >= 6 {
            return true
        } else {
            return false
        }
    }.eraseToAnyPublisher()
    
    private(set) lazy var isPasswordSame = Publishers.CombineLatest($password, $passwordCheck)
        .map {
            $0 == $1
        }.eraseToAnyPublisher()
    
    private(set) lazy var isAllInfoChecked = Publishers.CombineLatest(isPasswordValid, isPasswordSame)
        .map {
            return $0 && $1
        }.eraseToAnyPublisher()
    
}

// MARK: - Internal
extension SignUpViewViewModel {
    
    // MARK: - Create User
    func createNewUser() async {
        
        do {
            // 1. Find out if it is accountable.
            let (isAccountable, isVip) = try await firestoreManager.isAccountable(email: self.fullEmail)
            
            if isAccountable {
                
                // 2. Create User Account
                self.isValidUser = isAccountable
                let createdAccount = try await firebaseAuthManager.createAccount(email: self.fullEmail,
                                                                                 password: self.password)
                
                // 3. Save userUId and creationTime to Firestore
                let uid = createdAccount.user.uid
                let creationDate = createdAccount.user.metadata.creationDate ?? Date()
                try await firestoreManager.saveUserInfo(email: self.fullEmail, uid: uid, creationTime: Timestamp(date: creationDate))
                
                if isVip {
                    self.isVip = isVip
                }
                
                // 4. Save user info to UserDefaults
                try await UPlusUser.saveCurrentUser(email: self.fullEmail)
                
                self.logger.info("User created.")
                isUserCreated.send(true)
                
            } else {
                self.errorDescription = "등록이 불가능한 이메일입니다."
                isUserCreated.send(false)
            }
        }
        catch (let error) {
            if error is AuthErrorCode {
                let err = error as? AuthErrorCode
                switch err {
                case .none:
                    break
                case .some(let wrapped):
                    self.logger.error("Error creating new user \(wrapped.localizedDescription)")
                    switch wrapped.code {
                    case .emailAlreadyInUse:
                        self.errorDescription = "이미 가입된 이메일입니다."
                    default:
                        self.errorDescription = String(describing: wrapped.code)
                    }
                    self.isUserCreated.send(false)
                }
            } else {
                print("Error saving user info -- \(error)")
            }
            
            return
        }
        
    }
    
}


