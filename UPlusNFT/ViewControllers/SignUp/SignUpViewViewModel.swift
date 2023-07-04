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
    
    var fullEmail = ""
    @Published var email = "" {
        didSet {
            fullEmail = self.email + "@gmail.com"
        }
    }
    @Published var password = ""
    @Published var passwordCheck = ""
//    @Published var nickname = ""
    @Published var errorDescription = ""
    
    var isAuthenticated = PassthroughSubject<Bool, Never>()
    var isUserCreated = PassthroughSubject<Bool, Never>()
    var isEmailSent = PassthroughSubject<Bool, Never>()
    
    private(set) lazy var isEmailValid = $email.map {
//        $0.hasSuffix(SignUpConstants.emailSuffix)
        $0.count > 5 //TODO: 유효한 이메일 규칙 필요
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

    private(set) lazy var isAllInfoChecked = Publishers.CombineLatest3(isEmailValid, isPasswordValid, isPasswordSame)
        .map {
            return $0 && $1 && $2
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
        self.isEmailSent.send(true)
        /*
        let actionCodeSettings = ActionCodeSettings()
        actionCodeSettings.url = URL(string: SignUpConstants.deeplinkDomain)
        actionCodeSettings.handleCodeInApp = true
        guard let bundleIdentifier = Bundle.main.bundleIdentifier else { return }
        actionCodeSettings.setIOSBundleID(bundleIdentifier)
        
        Task {
            do {
                try await Auth.auth()
                    .sendSignInLink(
                        toEmail: self.fullEmail,
                        actionCodeSettings: actionCodeSettings
                    )
                self.logger.info("Successfully sent email sign in link to \(self.fullEmail).")
                self.isEmailSent.send(true)
            }
            catch {
                self.logger.error("Error sending sign in link: \(error.localizedDescription).")
                self.isEmailSent.send(false)
            }
        }
         */
    }
    
    func createNewUser() {
        Task {
            do {
                try await Auth.auth()
                    .createUser(
                        withEmail: self.fullEmail,
                        password: self.password
                    )
                self.logger.info("User created.")
                
                // NOTE: Nickname related logic.
                /*
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.displayName = self.nickname
                try await changeRequest?.commitChanges()
                self.logger.info("Changed nickname.")
                */
                
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


