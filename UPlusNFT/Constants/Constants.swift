//
//  LoginConstants.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/06/20.
//

import Foundation

struct LoginConstants {
    static let emailLabel:String = "Email"
    static let passwordLabel:String = "Password"
    static let loginButtonTitle:String = "Log In"
    static let logoutButtonTitle:String = "Log Out"
    static let photoButtonTitle:String = "Photo"
    static let singInButtonTitle: String = "가입하기"
    static let stackSpacing: CGFloat = 1.0
}

struct SignUpConstants {
    static let emailLabel:String = "사내 이메일"
    static let passwordLabel:String = "비밀번호"
    static let passwordCheckLabel:String = "비밀번호 재확인"
    static let nicknameLabel: String = "닉네임"
    static let register: String = "가입하기"
    static let authenticate: String = "인증하기"
    static let authCompleted: String = "인증완료"
    static let emailSuffix: String = "@gmail.com"
    static let deeplinkDomain: String = "https://aftermint-popcat-demo.firebaseapp.com"
}

struct FirebaseConstants {
    static let firebaseAuthLinkKey: String = "Link"
}
