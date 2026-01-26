import Flutter
import UIKit
import FirebaseCore
import FirebaseMessaging
import flutter_local_notifications
@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    
    FirebaseApp.configure()
      FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
      GeneratedPluginRegistrant.register(with: registry)
      }

      if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
      }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
// ADD THIS METHOD BELOW:
  override func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
    
    // Check if the activity is a Universal Link (webpageURL)
    if userActivity.activityType == NSUserActivityTypeBrowsingWeb,
       let url = userActivity.webpageURL {
        
        print("Native DEBUG: Universal Link received: \(url.absoluteString)")
        
        // This tells iOS the app is handling the link. 
        // Returning true stops the "bounce" to Safari.
        let handled = super.application(application, continue: userActivity, restorationHandler: restorationHandler)
        return handled || true 
    }
    
    return super.application(application, continue: userActivity, restorationHandler: restorationHandler)
  }
}
