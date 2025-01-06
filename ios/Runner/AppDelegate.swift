import UIKit
import Flutter
import FirebaseDynamicLinks

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
    if let incomingURL = userActivity.webpageURL {
        let handled = DynamicLinks.dynamicLinks().handleUniversalLink(incomingURL) { dynamicLink, error in
            if let dynamicLink = dynamicLink, let deepLink = dynamicLink.url {
                // Handle the deep link in the app
                print("Deep link: \(deepLink.absoluteString)")
            }
        }
        return handled
    }
    return false
}
