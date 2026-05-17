
import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    
    var window: UIWindow?
    
    lazy var coreDataStack = CoreDataStack(modelName: "MyPlaces")
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
            
       
        
        // Передаем контекст в MainViewController
            if let navController = window?.rootViewController as? UINavigationController,
               let mainVC = navController.viewControllers.first as? MainViewController {
                // Передаем контекст из стека
                mainVC.context = coreDataStack.persistentContainer.viewContext
            }
            
            return true
        }

        func applicationWillTerminate(_ application: UIApplication) {
            // Сохраняем данные при закрытии
            coreDataStack.saveContext()
        }

        // MARK: - UISceneSession Lifecycle
        //  передача контекста должна быть в SceneDelegate
        
        func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
            return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        }
    }

