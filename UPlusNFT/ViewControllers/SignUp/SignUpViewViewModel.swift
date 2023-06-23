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
import OSLog

class SignUpViewViewModel {
    
    let logger = Logger()
    
    @Published var email = ""
    @Published var password = ""
    @Published var passwordCheck = ""
    @Published var nickname = ""
    @Published var errorDescription = ""
    
    var isAuthenticated = PassthroughSubject<Bool, Never>()
    var isUserCreated = PassthroughSubject<Bool, Never>()
    var isEmailSent = PassthroughSubject<Bool, Never>()
    
    private(set) lazy var isEmailValid = $email.map {
        $0.hasSuffix(SignUpConstants.emailSuffix)
    }.eraseToAnyPublisher()
    
    private(set) lazy var isPasswordValid = $password.map {
        let regex = SignUpConstants.emailRegex
        if let range = $0.range(of: regex, options: .regularExpression) {
            return true
        } else {
            return false
        }
    }.eraseToAnyPublisher()
    
    private(set) lazy var isPasswordSame = Publishers.CombineLatest($password, $passwordCheck)
        .map {
            $0 == $1
        }.eraseToAnyPublisher()

    private(set) lazy var isAllInfoChecked = Publishers.CombineLatest4(isEmailValid, isPasswordValid, isPasswordSame, $nickname)
        .map {
            return $0 && $1 && $2 && !$3.isEmpty
        }.eraseToAnyPublisher()
    
    // MARK: - Init
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(emailAuthenticated), name: NSNotification.Name.signIn, object: nil)
    }
    
    @objc private func emailAuthenticated() {
        self.isAuthenticated.send(true)
    }
    
    // MARK: - Internal
    
    func sendEmailValification() {
        let actionCodeSettings = ActionCodeSettings()
        actionCodeSettings.url = URL(string: SignUpConstants.deeplinkDomain)
        actionCodeSettings.handleCodeInApp = true
        guard let bundleIdentifier = Bundle.main.bundleIdentifier else { return }
        actionCodeSettings.setIOSBundleID(bundleIdentifier)
        
        Task {
            do {
                try await Auth.auth()
                    .sendSignInLink(
                        toEmail: email,
                        actionCodeSettings: actionCodeSettings
                    )
                print("Successfully sent email sign in link to \(email).")
                self.isEmailSent.send(true)
            }
            catch {
                print("Error sending sign in link: \(error.localizedDescription).")
                self.isEmailSent.send(false)
            }
        }
    }
    
    func createNewUser() {
        Task {
            do {
                try await Auth.auth()
                    .createUser(
                        withEmail: self.email,
                        password: self.password
                    )
                self.logger.info("User created.")
                
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.displayName = self.nickname
                try await changeRequest?.commitChanges()
                self.logger.info("Changed nickname.")
                
                isUserCreated.send(true)
            }
            catch (let error) {
                let err = error as? AuthErrorCode
                switch err {
                case .none:
                    break
                case .some(let wrapped):
                    self.logger.error("Error creating new user \(wrapped.localizedDescription)")
                    switch wrapped.code {
                    case .emailAlreadyInUse:
                        self.errorDescription = "이미 등록된 이메일입니다."
                    default:
                        self.errorDescription = "\(wrapped.code)"
                    }
                    self.isUserCreated.send(false)
                }
                return
            }
        }
    }
    
}


