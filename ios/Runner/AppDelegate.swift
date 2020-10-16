import UIKit
import Flutter
import GoogleMaps
import torus_direct

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSyAa0iA6PW7eyis0TYHxSwsF5y-SqSLklkk")
    InitArgs(CommandLine.argc, CommandLine.unsafeArgv)
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

   override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    TorusSwiftDirectSDK.handle(url: url)
    return true
  }
}
