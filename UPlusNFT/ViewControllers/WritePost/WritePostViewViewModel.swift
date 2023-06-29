//
//  WritePostViewViewModel.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/06/29.
//

import UIKit.UIImage
import FirebaseAuth
import FirebaseStorage
import Combine

final class WritePostViewViewModel {
    
    // MARK: - Dependency
    private let firestoreRepository = FirestoreManager.shared
    
    // MARK: - Property
    let postId: String?
    let imageUrl: String?
    @Published var titleText: String = ""
    @Published var postText: String = ""
    
    var selectedImages: [UIImage?] = []
    var userId: String = ""
    
    /*
    var isImageChangedRx: Observable<Bool> = Observable.just(false)
    var isTextChangedRx: PublishSubject<Bool> = PublishSubject()
    */
    
    // MARK: - Init
    init(
        postId: String? = nil,
        imageUrl: String? = nil
    ) {
        self.postId = postId
        self.imageUrl = imageUrl
        
        self.userId = Auth.auth().currentUser?.uid ?? ""
    }
    
}

extension WritePostViewViewModel {
    
    func saveImages(_ imageData: [Data]) async -> [String] {
        await withCheckedContinuation({ continuation in
            firestoreRepository.saveImage(
                postId: UUID().uuidString,
                images: imageData) { urls in
                    continuation.resume(returning: urls)
                }
        })
    }
    
    func savePost(imageUrls: [String]) {
        
        let postId = UUID().uuidString
        
        let post = Post(
            id: postId,
            url: "https://platfarm.net/thread/\(postId)",
            cachedType: PostType.article.rawValue,
            title: self.titleText,
            contentText: self.postText,
            contentImagePathList: imageUrls,
            authorUid: userId,
            createdTime: Date(),
            likedUserIdList: nil,
            cachedBestCommentIdList: nil
        )
        
        do {
            try self.firestoreRepository.savePost(post)
        }
        catch {
            print("Error saving post --- \(error)")
        }
        
    }
}

// MARK: - Enums
extension WritePostViewViewModel {
    enum PostType: String {
        case article
        case campaignQuizChoice = "campaign_quiz_choice"
        case campaignQuizAnswer = "campaign_quiz_answer"
        case campaignBestComment = "campaign_best_comment"
    }
}
