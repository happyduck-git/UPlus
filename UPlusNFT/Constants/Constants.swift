//
//  LoginConstants.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/06/20.
//

import Foundation

struct UPlusServiceInfoConstant {
    static let startDay: String = "2023-07-31"
    static let totalMembers: Int = 700
}

struct UserDefaultsConstants {
    static let currentUser: String = "currentUser"
    static let userId: String = "userId"
    static let username: String = "username"
    static let profileImage: String = "profileImage"
    static let noUserFound: String = "no user found"
    static let level: String = "level"
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
    static let emailComponent: String = "@"
    static let emailLabel: String = "사내 이메일"
    static let passwordLabel: String = "비밀번호"
    static let passwordCheckLabel: String = "비밀번호 확인"
    static let nicknameLabel: String = "닉네임"
    static let register: String = "가입 완료하기"
    static let authenticate: String = "이메일 인증하기"
    static let authCompleted: String = "이메일 인증이 완료되었습니다."
    static let emailSuffix: String = "@gmail.com" //"@platfarm.net" //"@gmail.com" //"@uplus.net"
    static let deeplinkDomain: String = "https://DEV-LGUplus-NFT-Platfarm.firebaseapp.com"
    static let passwordRegex: String = "^(?=.*\\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[a-zA-Z]).{8,}$"
    static let textFieldDebounce: RunLoop.SchedulerTimeType.Stride = 0.2
    static let sinUpSuccessLabel: String = "회원가입이 완료되었습다."
    static let emailCorrectFormat: String = "가입 가능한 이메일입니다."
    static let passwordValidation: String = "비밀번호는 6자 이상 입력하여야 합니다."
    static let passwordCheckValidation: String = "비밀번호가 일치하지 않습니다."
    
    static let greetings: String = "님의\nNFT 멤버십이 시작됐어요"
    static let desctiptions: String = "서태호와 함께 멤버십을 즐겨보세요"
    static let nftInfo: String = "서태호 NFT는 한 사람 당 하나만 발급받을 수 있어요."
    static let redeemGift: String = "웰컴 선물 받기"
    
    static let vipHolderInitialPoint: Int64 = 400
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
    static let inputComment: String = "댓글을 입력해주세요."
    static let writeButton: String = "작성하기"
    static let addComment: String = "답글 달기"
    static let showComment: String = "답글 보기"
}

struct SideMenuConstants {
    static let home: String = "홈"
    static let wallet: String = "월렛"
    static let rankBoard: String = "랭킹 게시판"
    static let popGame: String = "팝 게임"
    static let notice: String = "공지사항"
    static let faq: String = "FAQ 및 문의"
    static let resetPassword: String = "비밀번호 수정"
    static let logout: String = "로그아웃"
}

struct MyPageConstants {
    static let goToMission: String = "미션 하러가기"
    static let ownedRewards: String = "보유한 경품"
    static let levelUp: String = "Lv.%d 달성"
    static let benefit: String = "특별 BONUS 혜택"
    static let eventOpened: String = "이벤트 오픈"
    static let redeemLevelUpBenefits: String = "레벨업 보상 받기"
}

struct RewardsConstants {
    static let ownedRewards: String = "보유 경품"
    static let info: String = "경품 사용 안내"
    static let usage: String = "사용 방법"
    static let period: String = "경품 사용 기간"
    static let empty: String = " "
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
    static let missionParticipated: String = "미션 참여 완료"
    static let missionCompleted: String = "미션 완주"
    static let redeemPoint: String = "%dP 포인트 받기"
    static let missionProgress: String = "%d회 성공 /15회차"
    static let dailyMissionComplete: String = "15일 챌린지 완주를 축하해요!"
    static let routineMissionLimit: Int = 3
    static let redeemReward: String = "완주 보상 보기"
    static let bonusStage: String = "보너스 스테이지"
    static let pointInfo: String = "최대 600P 획득 기회"
    static let bonusMissionLimit: Int = 6
    static let certificate: String = "경험인증서 NFT"
    static let certiPath: String = "TODO 루틴미션"
    static let slackInfo: String = "Slack에 인증해서 경품 응모권을 받으세요!"
    static let shareOnSlack: String = "Slack에 자랑하기"
    static let slackScheme: String = "slack://"
    static let rewardRedeemed: String = "보상 획득 완료"
    static let reupload: String = "재업로드"
    
    static let numberOfTexts: String = "%d글자"
    static let hintDescription: String = "밑줄에 들어갈 단어를 맞춰보세요"
    
    static let watchVideo: String = "영상을 시청해주세요"
    static let watchVideoDescription: String = "영상 시청 후 다음 페이지에서 답을 맞춰보세요."
    static let next: String = "다음"
    static let upload: String = "인증 사진 올리기"
    static let submit: String = "제출하기"
    static let inputAnswer: String = "답변을 입력하세요"
    static let progressSuffix: String = "%.0f%%"
    static let resultDidCheck: String = "결과보기 완료"
    
    static let reselect: String = "앗! 다시 한번 선택해보세요"
    static let buttonBorderWidth: CGFloat = 2.0
    
    static let readCompleted: String = "읽기 완료"
    static let eventCompleted: String = "이벤트 참여 완료"
    
    static let congrats: String = "축하해요"
    static let weeklyCompleted: String = "여정 완료"
    static let redeemNft: String = "NFT 보상 받기"
}

struct RankingConstants {
    static let rank: String = "랭킹"
    static let todayRank: String = "일일 랭킹"
    static let totalRank: String = "누적 랭킹"
    static let topOneHundred: String = "TOP100"
    static let myRank: String = "내 순위"
}

struct WalletConstants {
    static let wallet: String = "웰렛"
    static let myNfts: String = "My NFTs"
    static let showAll: String = "전체보기"
    static let rewardsUnit: String = "개"
    static let walletAddress: String = "내 지갑 주소"
    static let copy: String = "복사하기"
    static let warning: String = "주소 공유 시 주의사항 한 줄"
    static let totalNfts: String = "총 %d개"
    static let videoGenerateTitle: String = "NFT 이미지 자랑하기"
    static let owner: String = "소유자"
    static let idCard: String = "ID Card"
}

struct LottieConstants {
    static let description: String = "%@ 님의 NFT를 주변에 자랑하세요!\n모두가 주목할 거예요. 🗝️"
    static let idCard: String = "ID Card"
    static let gif: String = "GIF"
    static let download: String = "다운로드"
    static let share: String = "공유하기"
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

}

struct ImageAsset {
    static let speaker: String = "speaker"
    static let pointSticker: String = "point-sticker"
    static let trophy: String = "trophy"
    static let xMarkBlack: String = "xmark-black"
    static let levelBadge: String = "level-star-badge"
    
    static let share: String = "share-arrow-up"
    
    static let arrowHeadDown: String = "arrow-head-down"
    static let arrowHeadUp: String = "arrow-head-up"
    static let arrowHeadRight: String = "arrow-head-right"
    
    /* Side Menu */
    static let home: String = "home-mint"
    static let wallet: String = "wallet-mint"
    static let ranking: String = "tropy-mint"
    static let notice: String = "speaker-mint"
    static let questionCircle: String = "question-circle"
    
    /* HomeVC */
    static let questionBox: String = "question-box"
    static let point: String = "point-silver"
    
    /* MissionVC */
    static let skeletonNft: String = "uplus-nft-skeleton"
    static let coloredNft: String = "uplus-nft-color"
    static let pointShadow: String = "point-shadow"
    static let confetti: String = "confetti"
    static let checkBlack: String = "check-black"
    static let padlock: String = "padlock"
    
    /* WalletVC */
    static let walletGray: String = "wallet-gray"
    
    /* RewardVC */
    static let bellGray: String = "bell-gray"
    
    static let dummyNftImageUrl: String = "https://i.seadn.io/gae/lW22aEwUE0IqGaYm5HRiMS8DwkDwsdjPpprEqYnBqo2s7gSR-JqcYOjU9LM6p32ujG_YAEd72aDyox-pdCVK10G-u1qZ3zAsn2r9?auto=format&dpr=1&w=200"
}

// MARK: - Firebase

struct FirebaseAuthConstants {
    static let firebaseAuthLinkKey: String = "Link"
}

struct FirestoreConstants {
    static let nftImagePathSuffix = "dev_threads2/nfts/nft_set/"
    
    static let devThreads = "dev_threads"
    static let threads = "threads"
    static let threadSetCollection = "thread_set"
    static let users = "users"
    static let userSetCollection = "user_set"
    static let userEmail = "user_email"
    static let userUid = "user_uid"
    static let userNickname = "user_nickname"
    static let userPointHistory = "user_point_history"
    static let userPointCount = "user_point_count"
    static let userPointMissions = "user_point_missions"
    static let userPointTime = "user_point_time"
    static let userTypeMissionArrayMap = "user_type_mission_array_map"
    static let userTotalPoint = "user_total_point"
    static let userNfts = "user_nfts"
    static let accountCreationTime = "user_account_creation_time"
    static let devThreads2 = "dev_threads2"
    static let configuration = "configuration"
    static let missions = "missions"
    static let nfts = "nfts"
    static let nftSet = "nft_set"
    static let rewards = "rewards"
    static let rewardSetCollection = "reward_set"
    static let missionSetCollection = "mission_set"
    static let dailyAttendanceMission = "daily_attendance_mission_set"
    static let athleteMission = "daily_exp__athlete__mission_set"
    static let environmentalistMission = "exp_environmentalist_mission_set"
    static let goodWorkerMission = "exp_good_worker_mission_set"
    static let suddenMission = "sudden_mission_set"
    static let missionTimelineMap = "missions_begin_end_time_map"
    
    /* Configuration */
    static let accountableEmails = "accountable_emails"
    static let vipNftHolderEmails = "vip_nft_holder_emails"
    
    /* User */
    static let urlPrefix = "https://platfarm.net/"
    static let defaultUserProfile =  "https://i.seadn.io/gcs/files/45d4a23d5b8d448561cdb14257e044ad.png?auto=format&dpr=1&w=300"
    static let selectedMissionTopic = "user_selected_mission_daily_exp_topic_type"
    static let selectedMissionSubTopic = "mission_sub_topic_type"
    
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
    static let missionPhotoTaskSet = "mission_photo_task_set"
    static let missionTopicType = "mission_topic_type"
    static let missionFormatType = "mission_format_type"
    static let missionSubFormatType = "mission_sub_format_type"
    static let missionContentTitle = "mission_content_title"
    static let missionRewardPoint = "mission_reward_point"
    static let missionsBeginEndTimeMap = "missions_begin_end_time_map"
    
    /* Event */
    static let governanceElectionUserMap = "governance_election_user_map"
    static let shareMediaOnSlackDownloadedUsers = "share_media_on_slack_downloaded_users"
    
    static let commentCountMap = "comment_count_map"
    static let commentUserRecents = "comment_user_recents"
    static let dailyPointHistorySet = "daily_point_history_set"
    static let pointHistoryUserCountMap = "point_history_user_count_map"
    static let usersPointUserCountMap = "users_point_user_count_map"
    
    /* Reward */
    static let rewardUser = "reward_user"
}

struct AlertConstants {
    static let slackShareFail: String = "Slack 공유 실패"
    static let retryMessage: String = "다시 시도해 주시기 바랍니다."
    static let confirm: String = "확인"
}
