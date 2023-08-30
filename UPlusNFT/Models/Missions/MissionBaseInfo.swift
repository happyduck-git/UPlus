//
//  MissionBaseInfo.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/08/31.
//

import Foundation
import FirebaseFirestore

struct MissionBaseInfo: Codable {
    let extraDailyExpGoodWorker: [String: Int64]
    let extraWeeklyQuiz1: EpisodeDetailData
    let extraWeeklyQuiz2: EpisodeDetailData
    let extraWeeklyQuiz3: EpisodeDetailData
    let missionsBeginEndTimeMap: [String: [Timestamp]]
    
    enum CodingKeys: String, CodingKey {
        case extraDailyExpGoodWorker = "extra__daily_exp__good_worker"
        case extraWeeklyQuiz1 = "extra__weekly_quiz__1"
        case extraWeeklyQuiz2 = "extra__weekly_quiz__2"
        case extraWeeklyQuiz3 = "extra__weekly_quiz__3"
        case missionsBeginEndTimeMap = "missions_begin_end_time_map"
    }
}

struct EpisodeDetailData: Codable {
    let episodeDescriptionCurrent: String
    let episodeDescriptionPast: String
    let episodeTitle: String
    
    enum CodingKeys: String, CodingKey {
        case episodeDescriptionCurrent = "episode_description__current"
        case episodeDescriptionPast = "episode_description__past"
        case episodeTitle = "episode_title"
        
    }
    
}
