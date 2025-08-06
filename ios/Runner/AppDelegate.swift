import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // ✅ This method must return true to tell iOS the app handled the link
  override func application(
    _ application: UIApplication,
    continue userActivity: NSUserActivity,
    restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
  ) -> Bool {
    print("➡️ iOS received universal link: \(String(describing: userActivity.webpageURL))")
    
    // This passes the link handling to Flutter/AppLinks
    return super.application(application, continue: userActivity, restorationHandler: restorationHandler)
  }
}
