

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard (scene is UIWindowScene) else { return }
        
        
        // Находим MainViewController в иерархии
            if let navController = window?.rootViewController as? UINavigationController,
               let mainVC = navController.viewControllers.first as? MainViewController {
                
                // Создаем стек и передаем контекст
                let coreDataStack = CoreDataStack(modelName: "MyPlaces")
                mainVC.context = coreDataStack.context
            }
        }

    func sceneDidDisconnect(_ scene: UIScene) {

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
        
        let delegate = UIApplication.shared.delegate as? AppDelegate
            delegate?.coreDataStack.saveContext()
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        (UIApplication.shared.delegate as? AppDelegate)?.coreDataStack.saveContext()
    }


}

    func sceneDidEnterBackground(_ scene: UIScene) {
        
        let delegate = UIApplication.shared.delegate as? AppDelegate
            delegate?.coreDataStack.saveContext()
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        (UIApplication.shared.delegate as? AppDelegate)?.coreDataStack.saveContext()
    }



