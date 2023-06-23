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
    static let changePassword: String = "비밀번호 변경하기"
    static let emailSentLabel: String = "이메일을 확인하여 비밀번호를 변경해주세요."
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
    static let emailRegex: String = "^(?=.*\\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[a-zA-Z]).{8,}$"
    static let textFieldDebounce: RunLoop.SchedulerTimeType.Stride = 0.3
    static let sinUpSuccessLabel: String = "회원가입이 완료되었습다."
}

struct ResetPasswordConstants {
    static let sendButton: String = "비밀번호 재설정"
    static let backToLoginButton: String = "로그인하기"
}

struct FirebaseAuthConstants {
    static let firebaseAuthLinkKey: String = "Link"
}

struct FirestoreConstants {
    static let threadSetCollection = "thread_set"
    
    /* Post */
    static let id = "id"
    static let authorUid = "author_uid"
    static let noUserUid = "no_user_uid"
    static let cachedBestCommentIdList = "cached_best_comment_id_list"
    static let cachedType = "cached_type"
    static let contentText = "content_text"
    static let createdTime = "created_time"
    static let likedUserIdList = "liked_user_id_list"
    static let title = "title"
    static let url = "url"
    static let contentImagePathList = "content_image_path_list"
    static let campaignMetadataBundle = "campaign_metadata_bundle"

    /* Comment */
    static let commentSet = "comment_set"
    static let commentAuthorUid = "comment_author_uid"
    static let commentContentImagePath = "comment_content_image_path"
    static let commentContentText = "comment_content_text"
    static let commentCreatedTime = "comment_created_time"
    static let commentId = "comment_id"
    static let commentLikedUserUidList = "comment_liked_user_uid_list"

    /* Recomment */
    static let recommentSet = "recomment_set"
    static let recommentAuthorUid = "recomment_author_uid"
    static let recommentContentText = "recomment_content_text"
    static let recommentCreatedTime = "recomment_created_time"
    static let recommentId = "recomment_id"
    
}
