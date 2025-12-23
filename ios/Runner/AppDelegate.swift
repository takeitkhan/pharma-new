import UIKit
import Flutter
import Firebase
import FirebaseMessaging
import UserNotifications

//// >>> ADDED FOR APPLE ATT
import AppTrackingTransparency
import AdSupport
//// <<< END ATT ADDITION

@main
@objc class AppDelegate: FlutterAppDelegate {

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    FirebaseApp.configure()
    GeneratedPluginRegistrant.register(with: self)

    UNUserNotificationCenter.current().delegate = self
    application.registerForRemoteNotifications()

    // Ask permission to show notifications
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
      if let error = error {
        print("Error requesting notification permission: \(error)")
      }
      print("Notification permission granted: \(granted)")
    }

    //// >>> ADDED FOR APPLE ATT — CREATE METHOD CHANNEL
    let controller = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(
        name: "app.tracking",
        binaryMessenger: controller.binaryMessenger
    )

    channel.setMethodCallHandler { (call, result) in
        if call.method == "requestTracking" {
            self.requestAppTracking(result: result)
        }
    }
    //// <<< END ATT ADDITION

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    Messaging.messaging().apnsToken = deviceToken
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }

  //// >>> ADDED FOR APPLE ATT — FUNCTION TO REQUEST PERMISSION
  private func requestAppTracking(result: @escaping FlutterResult) {
    if #available(iOS 14, *) {
      ATTrackingManager.requestTrackingAuthorization { status in
        if status == .authorized {
          result(1)
        } else {
          result(0)
        }
      }
    } else {
      result(1)
    }
  }
  //// <<< END ATT ADDITION
}



/** import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
**/
