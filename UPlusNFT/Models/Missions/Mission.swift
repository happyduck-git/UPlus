//
//  Mission.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/08/12.
//

import Foundation
import FirebaseFirestore

protocol Mission {
    var missionId: String { get set }
    var missionTopicType: String { get set }
    var missionSubTopicType: String { get set }
    var missionFormatType: String { get set }
    var missionSubFormatType: String { get set }
    var missionContentTitle: String? { get set }
    var missionContentText: String? { get set }
    var missionContentImagePaths: [String]? { get set }
    var missionCreationTime: Timestamp { get set }
    var missionStartTime: Timestamp { get set } //주간 퀴즈미션 weekly_quiz 은 항상 일요일
    var missionUserStateMap: [String: String]? { get set }
    var missionRewardPoint: Int64 { get set }
    var missionPermitAvatarLevel: Int64 { get set }
}

enum MissionType: String {
    case dailyExpAthlete = "daily_exp__athlete"
    case dailyExpGoodWorker = "daily_exp__good_worker"
    case dailyExpEnvironmentalist = "daily_exp__environmentalist"
    
    case weeklyQuiz1 = "weekly_quiz__1"
    case weeklyQuiz2 = "weekly_quiz__2"
    case weeklyQuiz3 = "weekly_quiz__3"

    case eventRegularMission = "event_mission__regular"
    case eventLevelMission = "event_mission__level"
    
    var storagePathFolderName: String {
        return self.rawValue + "__mission_set"
    }
    
    var displayName: String {
        switch self {
        case .dailyExpAthlete:
            return "걷기 루틴 미션"
        case .dailyExpGoodWorker:
            return "오늘 할 일 정하기"
        case .dailyExpEnvironmentalist:
            return "업무 루틴 미션"
        case .eventRegularMission:
            return "콘테스트"
        case .eventLevelMission:
            return "스페셜 이벤트"
        default:
            return "주간 퀴즈"
        }
    }
    
    var description: String {
        switch self {
        case .dailyExpAthlete:
            return "매일 6000보 걷기 인증"
        case .dailyExpGoodWorker:
            return "체계적으로 일해 최고의 CEO가 되자"
        case .dailyExpEnvironmentalist:
            return "매일 TODO 리스트 작성하기 인증"
        case .eventRegularMission, .eventLevelMission:
            return "이벤트 미션"
        default:
            return "주간 퀴즈"
        }
    }
}

enum MissionTopicType: String {
    case dailyExp = "daily_exp"
    case weeklyQuiz = "weekly_quiz"
    case eventMission = "event_mission"
}

enum MissionFormatType: String {
    case photoAuth = "photo_auth"
    case choiceQuiz = "choice_quiz"
    case answerQuiz = "answer_quiz"
    case contentReadOnly = "content_read_only"
    case shareMediaOnSlack = "share_media_on_slack"
    case governanceElection = "governance_election"
    case userComment = "user_comment"
}

enum MissionSubFormatType: String {
    case photoAuthNoManagement = "photo_auth__no_management"
    case photoAuthManagement = "photo_auth__management"
    case choiceQuizOX = "choice_quiz__ox"
    case choiceQuizMore = "choice_quiz__more"
    case choiceQuizVideo = "choice_quiz__video"
    case answerQuizSingular = "answer_quiz__singular"
    case answerQuizPlural = "answer_quiz__plural"
    case contentReadOnly = "content_read_only"
    case shareMediaOnSlack = "share_media_on_slack"
    case governanceElection = "governance_election"
    case userComment = "user_comment"
}

enum MissionUserState: String {
    case pending
    case succeeded
    case failed
    case notParticipated
}

struct MissionModel: Mission, Codable {
    var missionId: String
    
    var missionTopicType: String
    
    var missionSubTopicType: String
    
    var missionFormatType: String
    
    var missionSubFormatType: String
    
    var missionContentTitle: String?
    
    var missionContentText: String?
    
    var missionContentImagePaths: [String]?
    
    var missionCreationTime: Timestamp
    
    var missionStartTime: Timestamp
    
    var missionUserStateMap: [String : String]?
    
    var missionRewardPoint: Int64
    
    var missionPermitAvatarLevel: Int64
    
    
}

// MARK: - Model for MyPageVC Event Part
struct MissionWithLevel: Mission {

    var level: Int
    
    var missionId: String

    var missionTopicType: String
    
    var missionSubTopicType: String
    
    var missionFormatType: String
    
    var missionSubFormatType: String
    
    var missionContentTitle: String?
    
    var missionContentText: String?
    
    var missionContentImagePaths: [String]?
    
    var missionCreationTime: Timestamp
    
    var missionStartTime: Timestamp
    
    var missionUserStateMap: [String : String]?
    
    var missionRewardPoint: Int64
    
    var missionPermitAvatarLevel: Int64
    
    
}
