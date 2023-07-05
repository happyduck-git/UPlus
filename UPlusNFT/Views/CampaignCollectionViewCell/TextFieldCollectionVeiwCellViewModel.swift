//
//  TextFieldCollectionVeiwCellViewModel.swift
//  UPlusNFT
//
//  Created by HappyDuck on 2023/07/05.
//

import UIKit.UIImage
import Combine
import FirebaseFirestore

final class TextFieldCollectionVeiwCellViewModel {
    
    //MARK: - Dependency
    private let firestoreManager = FirestoreManager.shared
    
    //MARK: - Property
    let postId: String
    @Published var commentText: String = ""
    @Published var selectedImage: UIImage?
    var isButtonTapped: Bool = false
    
    //MARK: - Init
    init(postId: String) {
        self.postId = postId
    }
    
}

extension TextFieldCollectionVeiwCellViewModel {
    
    func numberOfItems() -> Int {
        return self.selectedImage == nil ? 0 : 1
    }
    
    func imageForItem() -> UIImage? {
        return selectedImage == nil ? nil : self.selectedImage
    }
    
}

extension TextFieldCollectionVeiwCellViewModel {
    
    func saveComment(postId: String) {
        
        Task {
            do {
                let path = try await firestoreManager.saveCommentImage(
                    to: postId,
                    image: selectedImage?.jpegData(compressionQuality: 0.75)
                )
                
                let userId = UserDefaults.standard.string(forKey: UserDefaultsConstants.userId) ?? UserDefaultsConstants.userId
                
                let comment = Comment(
                    commentAuthorUid: userId,
                    commentContentImagePath: path,
                    commentContentText: commentText,
                    commentCreatedTime: Timestamp(),
                    commentId: UUID().uuidString,
                    commentLikedUserUidList: nil
                )
                
                try await firestoreManager.saveComment(
                    to: postId,
                    comment
                )
            }
            catch {
                print("Error saving comment -- \(error.localizedDescription)")
            }
            
        }
        
       
    }
    
}
