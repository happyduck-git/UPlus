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
    static let start: String = "월드클래스 기업 만들기"
    static let membersInfo: String = "이미 %d명의 마스터님이 회사를 운영하고 있어요"
    static let numOfMembers: String = "%d명의 마스터님이"
}

struct LoginConstants {
    static let emailLabel: String = "사내 이메일"
    static let passwordLabel: String = "비밀번호"
    static let keepSignedIn: String = " 로그인 상태 유지"
    static let loginButtonTitle: String = "로그인하기"
    static let logoutButtonTitle: String = "Log Out"
    static let photoButtonTitle: String = "Photo"
    static let singInButtonTitle: String = "회원가입하기"
    static let wrongCredential: String = "이메일 혹은 비밀번호가 올바르지 않습니다."
    static let changePassword: String = "비밀번호를 잊으셨나요?"
    static let emailSentLabel: String = "이메일을 확인하여 비밀번호를 변경해주세요."
    static let stackSpacing: CGFloat = 1.0
    static let textFieldHeight: CGFloat = 56.0
    static let buttonHeight: CGFloat = 56.0
    static let uplusEmailSuffix: String = "@lguplus.co.kr"
    static let createAccount: String = "아직 계정이 없으신가요?"
}

struct LogoutConstants {
    static let logout: String = "로그아웃"
    static let logoutDesc: String = "로그아웃 하시겠어요?"
    static let cancel: String = "취소"
    static let doLogout: String = "로그아웃하기"
}

struct SignUpConstants {
    static let signUp: String = "회원가입"
    static let emailComponent: String = "@"
    static let emailLabel: String = "사내 이메일"
    static let passwordLabel: String = "비밀번호"
    static let passwordCheckLabel: String = "비밀번호 확인"
    static let star: String = "*"
    
    static let nicknameLabel: String = "닉네임"
    static let register: String = "가입하기"
    static let authenticate: String = "이메일 인증하기"
    static let authCompleted: String = "이메일 인증이 완료되었습니다."
    static let emailSuffix: String = "@platfarm.net" //"@platfarm.net" //"@gmail.com" //"@uplus.net"
    static let deeplinkDomain: String = "https://DEV-LGUplus-NFT-Platfarm.firebaseapp.com"
    static let passwordRegex: String = "^(?=.*\\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[a-zA-Z]).{8,}$"
    static let textFieldDebounce: RunLoop.SchedulerTimeType.Stride = 0.2
    static let sinUpSuccessLabel: String = "회원가입이 완료되었습다."
    static let emailCorrectFormat: String = "가입 가능한 이메일입니다."
    static let passwordValidation: String = "비밀번호는 6자 이상 입력하여야 합니다."
    static let passwordMatch: String = "비밀번호가 일치합니다."
    static let passwordNotMatch: String = "비밀번호가 일치하지 않습니다."
    
    static let personalInfo: String = "개인정보 수집 이용에 동의합니다."
    static let required: String = "(필수)"
    static let showAll: String = "전문보기"
    
    static let greetings: String = "마스터님의\nNFT 멤버십이 시작됐어요"
    static let startDescription: String = "미션을 수행하며 월드클래스 기업으로 성장시켜보세요"
    static let worldClass: String = "월드클래스"
    static let startMembership: String = "NFT 받고 도전하기"
    
    static let vipHolderInitialPoint: Int64 = 400
}

struct ResetPasswordConstants {
    static let findPassword: String = "비밀번호 찾기"
    static let findInfo: String = "비밀번호 재설정 안내"
    static let findDescription: String = "를 위해\n가입 시 등록한 사내 이메일을 입력해주세요."
    static let checkEmail: String = "이메일을 다시 한번 확인해주세요"
    static let sendEmailButton: String = "안내 메일 받기"
    static let checkMailBox: String = "사내 메일함을 확인해주세요"
    static let emailSent: String = "입력하신 사내 이메일로 안내 메일을 전송했습니다."
    static let login: String = "로그인하기"
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
    static let agreement: String = "개인정보수집동의"
}

struct MyPageConstants {
    static let usernameSuffix: String = "%@ 마스터님,\n오늘도 월드클래스를 향해 아자~!"
    static let dailyRank: String = "일일랭킹"
    static let rank: String = "%d위"
    static let goToMission: String = "미션 하러가기"
    static let ownedRewards: String = "보유한 경품"
    static let levelUp: String = "Lv.%d NFT"
    static let benefit: String = "특별 BONUS 혜택"
    static let vipBenefitTitle: String = "서태호 홀더 특별 혜택"
    static let coffee: String = "아메리카노"
    static let raffle: String = "래플권"
    static let eventOpened: String = "이벤트 오픈"
    static let redeemLevelUpBenefits: String = "레벨업 보상 받기"
    static let routineMissionProgress: String = "%d / 15회"
    static let routinMissionLimit: Int = 15
    static let pointLeftTillNextLevel: String = "다음 레벨 업까지 %dP"
    static let eventLevel: String = "레벨 %d"
    static let missionPoint: String = "+%dP"
    static let vipPoints: String = "400P"
    static let vipHolderGreeting: String = "서태호 NFT 홀더 %@님,\n특별 포인트를 드려요"
    static let noParticipate: String = "미션에 참여하지 않았습니다."
    static let makeTodoList: String = "오늘 할 일 정하기"
    static let missionCompleteMsg: String = "스타트업 마스터 되기 미션 완주를\n축하드려요!"
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
    static let receive: String = "받기"
    static let todayMission: String = "데일리 퀘스트"
    static let availableEvent: String = "참여 가능한 이벤트"
    static let dailyAttendanceMission: String = "데일리 퀴즈"
    static let expMission: String = "갓생 인증 미션"
    static let missionUnit: String = "개"
    static let pointUnit: String = "P"
    static let eventLeftSuffix: String = "%d개 남음"
    static let timeLeftSuffix: String = "%d시간 남음"
    static let details: String = "자세히 보기"
    static let difficulty: String = "난이도"
    
    static let level0Event: String = "콘테스트"
    static let otherLevelEvent: String = "스페셜 이벤트"
    
    static let quizMission: String = "퀴즈 미션"
    static let checkAnswer: String = "정답 확인하기"
    static let confirm: String = "확인"
    static let questCompleted: String = "퀘스트 완료"
    static let missionCompleted: String = "미션 완주"
    static let missionTerminated: String = "미션 종료"
    static let participated: String = "참여 완료"
    static let redeemPoint: String = "%dP 포인트 받기"
    static let routineProgress: String = "%d회 성공 /15회차"
    
    static let vote: String = "투표하기"
    
    /* Weekly Mission */
    static let timeLeft: String = "%d일 %d시간 후 종료"
    static let weeklyPoints: String = "600P+NFT"
    static let weeklyMissionProgress: String = "%d/15회"
    static let episodeCerti: String = "에피소드 인증서"
    static let weeklyTopTitle: String = "%d월 %d일까지 완주하고 에피소드 인증서를 받으세요!"
    static let episode1Desc: String = "천리길도 한걸음부터! 같이 일할 사원을 뽑아보아요."
    static let episode2Desc: String = "이번 주도 열심히! 서비스를 런칭해서 기업을 성장시켜요."
    static let episode3Desc: String = "기업 제휴로 월드클래스 기업까지 한발짝! 더 나아가요."
    
    /* Routine Mission */
    static let startupMaster: String = "스타트업 마스터 되기"
    static let masterCerti: String = "마스터 인증서"
    static let routineMissionInfo: String = "15회차를 완주하고 마스터 인증서를 받으세요!"
    static let routineDesc: String = "오늘 할 일 1가지를 적어 사진 인증을 해주세요!"
    static let routineTitle: String = "TO-DO 미션"
    static let routineSubTitle: String = "미션 완주하고 루틴 미션 완주 인증서를 받으세요!"
    static let dailyMissionComplete: String = "15일 챌린지 완주를 축하해요!"
    static let routineMissionLimit: Int = 15
    static let redeemReward: String = "완주 보상 보기"
    static let bonusStage: String = "보너스 스테이지"
    static let bonusStageInfo: String = "챌린지 완주 후 확인 가능"
    static let pointInfo: String = "최대 600P 획득 기회"
    static let info: String = "주의사항"
    static let infoDetail: String = "주의사항 내용 1번 주의사항입니다.\n2번 주의사항입니다.\n3번 주의사항입니다."
    static let photoEditWarning: String = "제출 이후엔 수정이 불가합니다"
    static let missionSubmissionNotice: String = "평가 완료 후 %dP 보상, 내일 중 지급될 수 있습니다"
    static let complete: String = "완료하기"
    static let mission5nCompleted: String = "스타트업 마스터 되기 %d회차 성공!\n특별 포인트를 드려요."
    
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
    static let goToQuiz: String = "문제 풀러 가기 (15초 뒤 활성화)"
    static let edit: String = "수정하기"
    static let submit: String = "제출하기"
    static let inputAnswer: String = "답변을 입력하세요"
    static let progressSuffix: String = "%.0f%%"
    static let resultDidCheck: String = "결과보기 완료"
    
    static let reselect: String = "앗! 다시 한번 선택해보세요"
    static let buttonBorderWidth: CGFloat = 2.0
    
    static let readCompleted: String = "읽기 완료"
    static let eventCompleted: String = "이벤트 참여 완료"
    
    static let congrats: String = "축하해요!"
    static let weeklyCompleted: String = "여정 완료"
    static let redeemNft: String = "NFT 보상 받기"
    static let redeemLevelUp: String = "레벨업 보상 받기"
    static let levelUpTitle: String = "LV.%d NFT"
    
    static let rewardPoint: String = "100P 보상"
    
    static let missionLevel: String = "난이도"
}

struct RankingConstants {
    static let rank: String = "랭킹"
    static let todayRank: String = "일일 랭킹"
    static let totalRank: String = "누적 랭킹"
    static let yesterdayRank: String = "어제의 랭킹"
    static let yesterdayRanker: String = "어제의 랭커"
    static let topOneHundred: String = "TOP100"
    static let myRank: String = "내 순위"
    static let top3: String = "TOP 3"
    static let top3Info: String = "TOP 3에게는 PoC 이후 특별한 보상을 드립니다."
}

struct WalletConstants {
    static let wallet: String = "웰렛"
    static let myNfts: String = "My NFTs"
    static let showAll: String = "전체보기"
    static let rewardsUnit: String = "%@개"
    static let walletAddress: String = "내 지갑 주소"
    static let copy: String = "복사하기"
    static let warning: String = "주소 공유 시 주의사항 한 줄"
    static let totalNfts: String = "총 %d개"
    static let videoGenerateTitle: String = "NFT 이미지 자랑하기"
    static let owner: String = "소유자"
    static let idCard: String = "ID Card"
    static let level: String = "레벨"
    static let ownedReward: String = "보유 경품"
    static let traits: String = "특징"
    static let episodeNft: String = "에피소드 NFT"
    static let goToMissionInfo: String = "월드클래스 기업 만들기에 참여해\n에피소드 NFT를 받으세요!"
    static let goToMission: String = "위클리 퀘스트 하러가기"
}

struct LottieConstants {
    static let description: String = "%@ 님의 NFT를 주변에 자랑하세요!\n모두가 주목할 거예요. 🗝️"
    static let idCard: String = "ID Card"
    static let gif: String = "GIF"
    static let download: String = "다운로드"
    static let share: String = "공유하기"
}

struct GiftConstants {
    static let receiver: String = "받는 사람"
    static let inputNickname: String = "닉네임을 입력해주세요"
    static let checkNickname: String = "닉네임을 다시 확인해주세요."
    static let info: String = "주의사항"
    static let infoDetail: String = "주의사항 내용 1번 주의사항입니다.\n2번 주의사항입니다.\n3번 주의사항입니다."
    static let sendGift: String = "선물하기"
    static let giftSent: String = "선물 완료"
    static let giftSentDescription: String = "%@ 님에게\n포인트 선물 완료!"
    static let sendInfo: String = "실제 선물 전송까지 약간의 시간이 소요될 수 있습니다."
    static let confirm: String = "완료하기"
    static let sendTo: String = "받는 사람"
    static let sentNft: String = "선물한 NFT"
}

struct EditPasswordConstants {
    static let emailInfo: String = "가입하신 사내 이메일 아이디입니다."
    static let editVCTitle: String = "비밀번호 수정"
    static let edit: String = "수정하기"
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
    
    static let eyeFilled: String = "eye.fill"

}

struct ImageAssets {
    static let level1InitialAvatar: String = "level4-avatar-initial"
    static let vipInitialBenefit: String = "vip-initial-benefit"
    
    static let pointSticker: String = "point-sticker"
    static let xMarkBlack: String = "xmark-black"
    static let levelBadge: String = "level-star-badge"
    
    static let share: String = "share-arrow-up"
    
    static let arrowHeadDown: String = "arrow-head-down"
    static let arrowHeadUp: String = "arrow-head-up"
    static let arrowHeadRight: String = "arrow-head-right"
    
    /* OnBoardingVC */
    static let onBoarding: String = "on-boarding"
    
    /* LoginVC */
    static let eyeOpened: String = "eye-open"
    static let eyeClosed: String = "eye-closed"
    static let infoRed: String = "info-red"
    static let infoBlue: String = "info-blue"
    
    /* LogoutVC */
    static let logoutFace: String = "logout-face"
    
    /* SignupVC */
    static let checkBoxEmpty: String = "check-box-empty"
    static let checkBoxTicked: String = "check-box-ticked"
    
    /* SignupCompletedVC */
    static let backgroundStar: String = "star-background"
    static let initialNft: String = "avatar-welcome"
    static let reflectionNft: String = "avatar-reflection"
    
    /* ResetPWVC */
    static let emailBig: String = "mail-big"
    
    /* Side Menu */
    static let home: String = "home-mint"
    static let walletMint: String = "wallet-mint"
    static let ranking: String = "rank-mint"
    static let notice: String = "speaker-mint"
    static let questionMint: String = "question-mint"
    
    /* HomeVC */
    static let dailyTrophy: String = "daily-trophy"
    static let starButton: String = "star-button"
    static let infoGray: String = "info-gray"
    static let questionBox: String = "question-box"
    static let point: String = "point-silver"
    static let couponFrame: String = "coupon-frame"
    static let routineImage: String = "todo"
    static let clock: String = "clock"
    static let computer: String = "computer"
    static let lock: String = "lock"
    static let hand: String = "hand"
    static let hamburgerMenu: String = "hamburger-menu"
    static let wallet: String = "wallet"
    static let speaker: String = "speaker"
    
    static let level1Title: String = "level1-title"
    static let level2Title: String = "level2-title"
    static let level3Title: String = "level3-title"
    static let level4Title: String = "level4-title"
    static let level5Title: String = "level5-title"
    
    /* RankVC */
    static let bronzeMedal: String = "bronze-medal"
    static let silverMedal: String = "silver-medal"
    static let goldMedal: String = "golden-medal"
    static let goldTrophy: String = "golden-trophy"
    static let silverTrophy: String = "silver-trophy"
    static let bronzeTrophy: String = "bronze-trophy"
    static let top3Title: String = "top3-title"
    static let yesterdayTitle: String = "yesterday-title"
    
    /* MissionVC */
    static let skeletonNft: String = "uplus-nft-skeleton"
    static let coloredNft: String = "uplus-nft-color"
    static let confettiBackground: String = "confetti-wall"
    static let checkBlack: String = "check-black"
    static let checkWhite: String = "check-white"
    static let padlock: String = "padlock"
    static let stampGiftEmpty: String = "routine-gift-empty"
    static let stampPointEmpty: String = "routine-point-empty"
    static let stampGiftFill: String = "routine-gift-fill"
    static let stampPointFill: String = "routine-point-fill"
    
    static let titleBackground: String = "title-background"
    static let eventBackground: String = "event-wall"
    static let routineBackground: String = "routine-wall"
    static let routineTitle: String = "routine-title"
    static let routineInfo: String = "routine-info"
    static let pointBig: String = "point-big"
    static let pointShadow: String = "point-shadow"
    
    static let episode1Wall: String = "episode1-wall"
    static let episode2Wall: String = "episode2-wall"
    static let episode3Wall: String = "episode3-wall"
    
    static let episode1Sub: String = "episode1-sub"
    static let episode2Sub: String = "episode2-sub"
    static let episode3Sub: String = "episode3-sub"
    
    static let episode1Title: String = "episode1-title"
    static let episode2Title: String = "episode2-title"
    static let episode3Title: String = "episode3-title"
    
    static let episode1Empty: String = "episode1-empty"
    static let episode2Empty: String = "episode2-empty"
    static let episode3Empty: String = "episode3-empty"
    
    static let episode1Footer: String = "episode1-bottom"
    static let episode2Footer: String = "episode2-bottom"
    static let episode3Footer: String = "episode3-bottom"
    
    static let heartFill: String = "heart-fill"
    static let heartEmpty: String = "heart-empty"
    
    
    /* WalletVC */
    static let walletGray: String = "wallet-gray"
    static let walletWhite: String = "wallet-white"
    static let arrowRight: String = "arrow-right-mint"
    static let sparkle: String = "sparkle"
    static let walletBuilding: String = "wallet-building"
    static let buttonPattern: String = "pattern-rec"
    
    /* RewardVC */
    static let bellGray: String = "bell-gray"
    
    /* GiftVC */
    static let giftMultiColored: String = "gift-multi"
    
    /* VIPBottomVC*/
    static let vipPoint: String = "vip-point"
    
    /* NewNFTVC */
    static let raffle: String = "raffle"
    
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
    static let userRewards = "user_rewards"
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
    static let missionBeginEndTimeMap = "missions_begin_end_time_map"
    
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
