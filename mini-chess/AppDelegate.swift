import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print("AppDelegate didFinishLaunchingWithOptions 호출됨")

        // Create window
        window = UIWindow(frame: UIScreen.main.bounds)
        print("Window 생성됨 - frame: \(window?.frame ?? .zero)")

        // Create GameViewController
        let viewController = GameViewController()
        print("GameViewController 생성됨")

        // Set as root view controller
        window?.rootViewController = viewController
        print("rootViewController 설정됨")

        // Make window visible
        window?.makeKeyAndVisible()
        print("window makeKeyAndVisible 호출됨")

        return true
    }
}
