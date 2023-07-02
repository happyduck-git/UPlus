//
//  SceneDelegate.swift
//  UPlusNFT
//
//  Created by Platfarm on 2023/06/20.
//

import UIKit
import FirebaseAuth
import OSLog

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    let logger = Logger()
    
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
      
        /*
        if Auth.auth().currentUser != nil {
            logger.info("User is logged in.")
            let loginVM = LoginViewViewModel()
            let loginVC = LoginViewController(vm: loginVM)
            
            let postVM = PostViewViewModel()
            let postVC = PostViewController(vm: postVM)
            loginVC.navigationController?.addChild(postVC)
            window?.rootViewController = UINavigationController(rootViewController: postVC)
        } else {
            logger.info("User is not logged in.")
            let loginVM = LoginViewViewModel()
            let loginVC = LoginViewController(vm: loginVM)
            window?.rootViewController = UINavigationController(rootViewController: loginVC)
        }
*/
        // Check PostVC
//        let vm = WritePostViewViewModel()
//        let vc = WritePostViewController(type: .newPost, vm: vm)
//        window?.rootViewController = UINavigationController(rootViewController: vc)
        
        // Check PostDetailVC
        let vm = PostDetailViewViewModel(
            userId: "User ID",
            postId: "Post ID",
            postTitle: "Test Title",
            postContent: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum./nLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
            imageList: ["image1", "Image2"],
            likeUserCount: 98,
            comments: [
                Comment(
                commentAuthorUid: "Author ID",
                commentContentImagePath: "image path",
                commentContentText: "Test Comment Text",
                commentCreatedTime: Date(),
                commentId: "Comment ID",
                commentLikedUserUidList: ["UserID#1"]),
                
                Comment(
                commentAuthorUid: "Author ID",
                commentContentImagePath: "image path",
                commentContentText: "Test Comment Text",
                commentCreatedTime: Date(),
                commentId: "Comment ID",
                commentLikedUserUidList: ["UserID#1"]),
                Comment(
                commentAuthorUid: "Author ID",
                commentContentImagePath: "image path",
                commentContentText: "Test Comment Text",
                commentCreatedTime: Date(),
                commentId: "Comment ID",
                commentLikedUserUidList: ["UserID#1"]),
                
                Comment(
                commentAuthorUid: "Author ID",
                commentContentImagePath: "image path",
                commentContentText: "Test Comment Text",
                commentCreatedTime: Date(),
                commentId: "Comment ID",
                commentLikedUserUidList: ["UserID#1"]),
                Comment(
                commentAuthorUid: "Author ID",
                commentContentImagePath: "image path",
                commentContentText: "Test Comment Text",
                commentCreatedTime: Date(),
                commentId: "Comment ID",
                commentLikedUserUidList: ["UserID#1"]),
                
                Comment(
                commentAuthorUid: "Author ID",
                commentContentImagePath: "image path",
                commentContentText: "Test Comment Text",
                commentCreatedTime: Date(),
                commentId: "Comment ID",
                commentLikedUserUidList: ["UserID#1"]),
                Comment(
                commentAuthorUid: "Author ID",
                commentContentImagePath: "image path",
                commentContentText: "Test Comment Text",
                commentCreatedTime: Date(),
                commentId: "Comment ID",
                commentLikedUserUidList: ["UserID#1"]),
                Comment(
                commentAuthorUid: "Author ID",
                commentContentImagePath: "image path",
                commentContentText: "Test Comment Text",
                commentCreatedTime: Date(),
                commentId: "Comment ID",
                commentLikedUserUidList: ["UserID#1"]),
                
                Comment(
                commentAuthorUid: "Author ID",
                commentContentImagePath: "image path",
                commentContentText: "Test Comment Text",
                commentCreatedTime: Date(),
                commentId: "Comment ID",
                commentLikedUserUidList: ["UserID#1"])
            ]
        )
        
        let vc = PostDetailViewController(vm: vm)
        window?.rootViewController = UINavigationController(rootViewController: vc)
        window?.makeKeyAndVisible()
        
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        /// 이메일에서 sigin in 확인 후 앱으로 돌아온 후
        guard let webpageURL = userActivity.webpageURL else { return }
        let link = webpageURL.absoluteString
        if Auth.auth().isSignIn(withEmailLink: link) {
            UserDefaults.standard.set(link, forKey: FirebaseAuthConstants.firebaseAuthLinkKey)
            NotificationCenter.default.post(name: NSNotification.Name.signIn, object: nil)
        }
        
    }

}

