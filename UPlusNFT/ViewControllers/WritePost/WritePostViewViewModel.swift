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
    
    @Published var selectedImages: [UIImage?] = []
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

//MARK: - CollectionView
extension WritePostViewViewModel {
    
    func numberOfItems(at section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return selectedImages.count
        }
    }
    
}

//MARK: - Save Post
extension WritePostViewViewModel {
    
    func saveImages(_ imageData: [Data]) async -> [String] {
        await withCheckedContinuation({ continuation in
            firestoreRepository.savePostImage(
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
