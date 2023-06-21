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

class SignUpViewViewModel {
    
    @Published var email = ""
    @Published var password = ""
    @Published var passwordCheck = ""
    @Published var nickname = ""
    
    var isValidated = PassthroughSubject<Bool, Never>()
    var isAuthenticated = PassthroughSubject<Bool, Never>()
    
    private(set) lazy var isEmailValid = $email.map {
        $0.hasSuffix(SignUpConstants.emailSuffix)
    }.eraseToAnyPublisher()
    
    private(set) lazy var isPasswordValid = $password.map {
        let regex = "(?=.*\\d)(?=.*[a-z]).{8,}"
        if let range = $0.range(of: regex, options: .regularExpression) {
            return true
        } else {
            return false
        }
    }.eraseToAnyPublisher()
    
    private(set) lazy var isPasswordSame = $passwordCheck.map { [weak self] in
        return $0 == self?.password
    }.eraseToAnyPublisher()
    
    private(set) lazy var isAllInfoChecked = Publishers.CombineLatest4(isEmailValid, isPasswordValid, isPasswordSame, $nickname)
        .map {
            return $0 && $1 && $2 && !$3.isEmpty
        }.eraseToAnyPublisher()
    
    func validateEmail(_ email: String) {
        if email.hasSuffix(SignUpConstants.emailSuffix) {
//            self.email = email
            self.isAuthenticated.send(true)
//            self.isValidated.send(true)
        }
        else {
            self.isAuthenticated.send(false)
//            self.isValidated.send(false)
        }
    }
    
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
            }
            catch {
                print("Error sending sign in link: \(error.localizedDescription).")
            }
        }
    }
}
