//
//  LoginConstants.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/06/20.
//

import Foundation

struct UPlusServiceInfoConstant {
    static let startDay: String = "2023-07-26"
    static let totalMembers: Int = 700
}

struct UserDefaultsConstants {
    static let currentUser: String = "currentUser"
    static let userId: String = "userId"
    static let username: String = "username"
    static let profileImage: String = "profileImage"
    static let noUserFound: String = "no user found"
}

struct OnBoardingConstants {
    static let showMore: String = "PoC 소개 더 보기"
    static let start: String = "시작하기"
}

struct LoginConstants {
    static let emailLabel: String = "사내 이메일"
    static let passwordLabel: String = "비밀번호"
    static let keepSignedIn: String = " 로그인 상태 유지"
    static let loginButtonTitle: String = "로그인하기"
    static let logoutButtonTitle: String = "Log Out"
    static let photoButtonTitle: String = "Photo"
    static let singInButtonTitle: String = "회원가입하기"
    static let changePassword: String = "비밀번호 찾기"
    static let emailSentLabel: String = "이메일을 확인하여 비밀번호를 변경해주세요."
    static let stackSpacing: CGFloat = 1.0
}

struct SignUpConstants {
    static let emailLabel: String = "사내 이메일 인증"
    static let passwordLabel: String = "비밀번호"
    static let passwordCheckLabel: String = "비밀번호 확인"
    static let nicknameLabel: String = "닉네임"
    static let register: String = "가입 완료하기"
    static let authenticate: String = "이메일 인증하기"
    static let authCompleted: String = "이메일 인증이 완료되었습니다."
    static let emailSuffix: String = "@gmail.com" //"@uplus.net"
    static let deeplinkDomain: String = "https://DEV-LGUplus-NFT-Platfarm.firebaseapp.com"
    static let emailRegex: String = "^(?=.*\\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[a-zA-Z]).{8,}$"
    static let textFieldDebounce: RunLoop.SchedulerTimeType.Stride = 0.2
    static let sinUpSuccessLabel: String = "회원가입이 완료되었습다."
    static let emailCorrectFormat: String = "가입 가능한 이메일입니다."
    static let passwordValidation: String = "비밀번호에 영문, 숫자를 포함해주세요."
    static let passwordCheckValidation: String = "비밀번호가 일치하지 않습니다."
    
    static let greetings: String = "님의\nNFT 멤버십이 시작됐어요"
    static let desctiptions: String = "서태호와 함께 멤버십을 즐겨보세요"
    static let nftInfo: String = "서태호 NFT는 한 사람 당 하나만 발급받을 수 있어요."
    static let redeemGift: String = "웰컴 선물 받기"
}

struct ResetPasswordConstants {
    static let sendButton: String = "비밀번호 재설정"
    static let backToLoginButton: String = "로그인하기"
}

struct WritePostConstants {
    static let submitButtonTitle: String = "작성하기"
    static let title: String = "제목"
    static let content: String = "내용"
    static let titlePlaceholder: String = "제목"
    static let contentPlaceholder: String = "게시물 내 텍스트"
}

struct PostConstants {
    static let tempMissionSentence: String = "미션 문구"
    static let submitButton: String = "제출하기"
    static let inputAnswer: String = "답변을 입력해주세요."
    static let inputComment: String = "댓글을 입력해주세요."
    static let writeButton: String = "작성하기"
    static let addComment: String = "답글 달기"
    static let showComment: String = "답글 보기"
}

struct SideMenuConstants {
    static let home: String = "홈"
    static let mission: String = "미션"
    static let rankBoard: String = "랭킹 게시판"
    static let resetPassword: String = "비밀번호 수정"
}

struct MyPageConstants {
    static let goToMission: String = "미션 하러가기"
    static let ownedRewards: String = "보유한 경품"
}

struct RewardsConstants {
    static let ownedRewards: String = "보유 경품"
    static let rewardsUnit: String = "개"
}

struct MissionConstants {
    static let pointSuffix: String = "pt"
    static let level: String = "Level"
    static let levelPrefix: String = "LV."
    static let levelUp: String = "레벨업하기"
    static let todayMission: String = "오늘의 미션"
    static let dailyAttendanceMission: String = "데일리 퀴즈"
    static let expMission: String = "갓생 인증 미션"
    static let missionUnit: String = "개"
    static let pointUnit: String = "P"
    static let timeLeftSuffix: String = "시간 남음"
    static let details: String = "자세히 보기"
    /* Daily Quiz Mission */
    static let quizMission: String = "퀴즈 미션"
    static let checkAnswer: String = "정답 확인하기"
    static let confirm: String = "확인"
    static let missionSuccess: String = "미션 성공\n정답"
    static let missionComplete: String = "미션 참여\n완료"
    static let redeemPointSuffix: String = " 받아요"
}

struct RankingConstants {
    static let rank: String = "랭킹"
    static let todayRank: String = "일일 랭킹"
    static let totalRank: String = "누적 랭킹"
    static let topOneHundred: String = "TOP100"
    static let myRank: String = "내 순위"
}

struct EditUserInfo {
    static let editVCTitle: String = "비밀번호 수정"
    static let confirm: String = "수정완료"
}

// MARK: - Assets
struct SFSymbol {
    static let camera: String = "camera.fill"
    static let cameraViewFinder: String = "camera.viewfinder"
    static let cameraFill: String = "camera.circle.fill"
    static let photoLibrary: String = "photo.on.rectangle.angled"
    static let edit: String = "pencil"
    static let delete: String = "trash"
    static let defaultProfile: String = "person.circle.fill"
    static let comment: String = "text.bubble"
    static let heartFill: String = "heart.fill"
    static let heart: String = "heart"
    
    static let arrowDown: String = "arrowtriangle.down.fill"
    static let arrowUp: String = "arrowtriangle.up.fill"
    static let arrowLeft: String = "arrow.left"
    static let arrowRight: String = "arrow.right"
    static let arrowTriangleRight: String = "arrowtriangle.right.fill"
    
    static let info: String = "info.circle"
    static let infoFill: String = "info.circle.fill"
    static let list: String = "list.bullet"
    
    static let circledCheckmark: String = "checkmark.circle"
    static let circleFilledCheckmark: String = "checkmark.circle.fill"
    
    static let mission: String = "figure.baseball"
    static let circledPerson: String = "person.crop.circle"
    static let medalFill: String = "medal.fill"
    static let point: String = "parkingsign.circle.fill"
}

struct ImageAsset {
    static let speaker: String = "speaker"
    static let pointSticker: String = "point-sticker"
    static let trophy: String = "trophy"
    static let xMark: String = "xmark-black"
    static let levelBadge: String = "level-star-badge"
    
    static let share: String = "share-arrow-up"
    
    static let arrowHeadDown: String = "arrow-head-down"
    static let arrowHeadUp: String = "arrow-head-up"
    
    static let dummyNftImageUrl: String = "https://i.seadn.io/gae/lW22aEwUE0IqGaYm5HRiMS8DwkDwsdjPpprEqYnBqo2s7gSR-JqcYOjU9LM6p32ujG_YAEd72aDyox-pdCVK10G-u1qZ3zAsn2r9?auto=format&dpr=1&w=200"
}

// MARK: - Firebase

struct FirebaseAuthConstants {
    static let firebaseAuthLinkKey: String = "Link"
}

struct FirestoreConstants {
    static let devThreads = "dev_threads"
    static let threads = "threads"
    static let threadSetCollection = "thread_set"
    static let users = "users"
    static let userSetCollection = "user_set"
    static let userEmail = "user_email"
    static let userUid = "user_uid"
    static let userPointHistory = "user_point_history"
    static let accountCreationTime = "user_account_creation_time"
    static let devThreads2 = "dev_threads2"
    static let configuration = "configuration"
    static let missions = "missions"
    static let nfts = "nfts"
    static let rewards = "rewards"
    static let rewardSetCollection = "reward_set"
    static let missionSetCollection = "mission_set"
    static let dailyAttendanceMission = "daily_attendance_mission_set"
    static let athleteMission = "daily_exp__athlete__mission_set"
    static let environmentalistMission = "exp_environmentalist_mission_set"
    static let goodWorkerMission = "exp_good_worker_mission_set"
    static let suddenMission = "sudden_mission_set"
    
    /* User */
    static let urlPrefix = "https://platfarm.net/"
    static let defaultUserProfile =  "https://i.seadn.io/gcs/files/45d4a23d5b8d448561cdb14257e044ad.png?auto=format&dpr=1&w=300"
    /* Post */
    static let id = "id"
    static let authorUid = "author_uid"
    static let noPostId = "no_post_uid"
    static let noUserUid = "no_user_uid"
    static let noUsername = "no_username"
    static let noUserEmail = "no_user_email"
    static let noUrl = "no_url"
    static let noTitle = "no_title"
    static let noContent = "no_content"
    static let noCachedType = "no_cached_type"
    static let cachedBestCommentIdList = "cached_best_comment_id_list"
    static let cachedType = "cached_type"
    static let contentText = "content_text"
    static let createdTime = "created_time"
    static let likedUserIdList = "liked_user_id_list"
    static let title = "title"
    static let url = "url"
    static let contentImagePathList = "content_image_path_list"
    static let campaignMetadataBundle = "campaign_metadata_bundle"
    static let documentLimit: Int = 6
    static let postUrlPrefix: String = "https://platfarm.net/thread/"
    static let cachedCommentCount: String = "cached_comment_count"
    static let cachedCommentLikedCount: String = "cached_comment_liked_count"
    static let cachedLikedCount: String = "cached_liked_count"
    
    /* Comment */
    static let commentSet = "comment_set"
    static let commentAuthorUid = "comment_author_uid"
    static let commentContentImagePath = "comment_content_image_path"
    static let commentContentText = "comment_content_text"
    static let commentCreatedTime = "comment_created_time"
    static let commentId = "comment_id"
    static let commentLikedUserUidList = "comment_liked_user_uid_list"
    static let bestCommentLimit = 5
    
    /* Recomment */
    static let recommentSet = "recomment_set"
    static let recommentAuthorUid = "recomment_author_uid"
    static let recommentContentText = "recomment_content_text"
    static let recommentCreatedTime = "recomment_created_time"
    static let recommentId = "recomment_id"
    
    /* Campaign Metadata */
    static let campaginConfiguration = "campaign_configuration"
    static let campaignBestCommentItems = "campaign_best_comment_items"
    static let campaignBestCommentItemSet = "campaign_best_comment_item_set"
    static let campaignItems = "campaign_items"
    static let campaignItemSet = "campaign_item_set"
    static let campaignUsers = "campaign_users"
    static let campaignUserSet = "campaign_user_set"
    static let cachedItemUserCount = "cached_item_user_count"
    static let isRightItem = "is_right_item"
    static let itemCaption = "item_caption"
    static let itemId = "item_id"
    static let itemRewardCategoryId = "item_reward_category_id"
    static let beginTime = "begin_time"
    static let endTime = "end_time"
    static let hasUserReward = "has_user_reward"
    static let isUserSendRightAnswer = "is_user_send_right_answer"
    static let userAnsweredText = "user_answered_text"
    static let userSelectedItemId = "user_selected_item_id"
    static let bestCommentOrder = "best_comment_order"
    static let bestCommentRewardedUserUid = "best_comment_rewarded_user_uid"
    static let bestCommentRewardCategoryId = "best_comment_reward_category_id"
    
    /* Mission */
    static let missionUserStateMap = "mission_user_state_map"
    static let dailyExpAthleteMissionSet = "daily_exp__athlete__mission_set"
    
    /* Reward */
    static let rewardUser = "reward_user"
}
