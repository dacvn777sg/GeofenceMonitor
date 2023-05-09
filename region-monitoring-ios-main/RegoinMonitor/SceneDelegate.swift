//
//  SceneDelegate.swift
//  RegoinMonitor
//
//  Created by Dac Vu on 08/05/2023.
//

import UIKit
import SwiftUI
import CoreLocation
import AVKit

class AlertSettings: ObservableObject {
    @Published var showAlert = false
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    var settings = AlertSettings()
    let locationManager = CLLocationManager()
    var player: AVAudioPlayer?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView()
        playSound()
        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView:  contentView.environmentObject(settings))
            self.window = window
            window.makeKeyAndVisible()
        }
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization() // Make sure to add necessary info.plist entries
        monitorRegionAtLocation()
//        let locationCoordinates = CLLocationCoordinate2D(latitude: 10.8033210, longitude:  106.7145378) // Home
//        monitorRegionAtLocation(center: locationCoordinates, identifier: "Home Dac")
        //        let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: 10.7790782, longitude:  106.7228071), radius: 100, identifier: "Apple Campus")
        //        locationManager.startMonitoring(for: region)


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
    
    func monitorRegionAtLocation() {
        
        // Make sure the devices supports region monitoring.
        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            
            let maxDistance = locationManager.maximumRegionMonitoringDistance
            // For the sake of this tutorial we will use the maxmimum allowed distance.
            // When you are going production, it is recommended to optimize this value according to your needs to be less resource intensive
            
            // Register the region.
//            let region = CLCircularRegion(center: center,
//                                          radius: 100.0, identifier: identifier)
            let regions: [CLCircularRegion] = [
                CLCircularRegion(center: CLLocationCoordinate2D(latitude: 10.8033210, longitude: 106.7145378), radius: 100, identifier: "home"),
                CLCircularRegion(center: CLLocationCoordinate2D(latitude: 10.8015047, longitude: 106.7151353), radius: 100, identifier: "dauduong"),
                CLCircularRegion(center: CLLocationCoordinate2D(latitude: 10.7940724, longitude: 106.7018899), radius: 100, identifier: "thapdongho"),
                CLCircularRegion(center: CLLocationCoordinate2D(latitude: 10.7915302, longitude: 106.6964403), radius: 100, identifier: "vothisau"),
                CLCircularRegion(center: CLLocationCoordinate2D(latitude: 10.7851695, longitude: 106.6902156), radius: 100, identifier: "namkikhoinghia"),
                CLCircularRegion(center: CLLocationCoordinate2D(latitude: 10.7781524, longitude: 106.6838211), radius: 100, identifier: "maikhoi"),
            ]
            
//            region.notifyOnEntry = true
//            region.notifyOnExit = true
            
            
            for region in regions {
                locationManager.startMonitoring(for: region)
            }
//            locationManager.startMonitoring(for: region)
        }
    }
    
    
}

extension SceneDelegate : CLLocationManagerDelegate {

    func playSound() {


    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        
        settings.showAlert = true
        
        if UIApplication.shared.applicationState == .active {
            
        } else {
            
            player?.stop()
            do {
                sleep(2)
            }
            var url: URL!
            switch region.identifier {
            case "home":
                url = Bundle.main.url(forResource: "helix_song", withExtension: "mp3")
            case "thapdongho":
                url = Bundle.main.url(forResource: "emergency_evacuation", withExtension: "mp3")
            case "maikhoi":
                url = Bundle.main.url(forResource: "SoundHelix-Song-2", withExtension: "mp3")
            default:
                url = Bundle.main.url(forResource: "SoundHelix-Song-3", withExtension: "mp3")
            }
//            guard let url = Bundle.main.url(forResource: "helix_song", withExtension: "mp3") else { return }
            do {
                player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)

                guard let player = player else { return }
                player.play()
            } catch let error {
                print(error.localizedDescription)
            }
            print("You arrived at " + region.identifier)
            let body = "You arrived at " + region.identifier
            let notificationContent = UNMutableNotificationContent()
            notificationContent.body = body
            notificationContent.sound = .default
            notificationContent.badge = UIApplication.shared.applicationIconBadgeNumber + 1 as NSNumber
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(
                identifier: "location_arr",
                content: notificationContent,
                trigger: trigger)
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error: \(error)")
                }
            }
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        
        settings.showAlert = false
        
        if UIApplication.shared.applicationState == .active {
            
        } else {
//            player?.stop()
//            guard let url = Bundle.main.url(forResource: "SoundHelix-Song-2", withExtension: "mp3") else { return }
//            do {
//                player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
//
//                guard let player = player else { return }
//                player.play()
//            } catch let error {
//                print(error.localizedDescription)
//            }
            print("You left " + region.identifier)
            let body = "You left " + region.identifier
            let notificationContent = UNMutableNotificationContent()
            notificationContent.body = body
            notificationContent.sound = .default
            notificationContent.badge = UIApplication.shared.applicationIconBadgeNumber + 1 as NSNumber
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(
                identifier: "location_change",
                content: notificationContent,
                trigger: trigger)
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error: \(error)")
                }
            }
        }
    }
}


