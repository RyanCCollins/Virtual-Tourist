//
//  AppDelegate.swift
//  Virtual-Tourist
//
//  Created by Ryan Collins on 11/20/15.
//  Copyright © 2015 Tech Rapport. All rights reserved.
//

import UIKit
import CoreData


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var isLoading: Bool = false

    var numPhotosLoaded: Int?
    

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        restoreSettingsState()
        
        return true
        
    }
    
    func handleLoadingNotifications(){
        
    }
    
    func restoreSettingsState() {
        
        if let settingsDictionary = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as? [String : AnyObject] {
            Settings.SharedInstance.sharedSettings.funMode = settingsDictionary["funMode"] as! Bool
            Settings.SharedInstance.sharedSettings.numPhotos  = settingsDictionary["numberOfPhotos"] as! Int
            Settings.SharedInstance.sharedSettings.deleteAll = settingsDictionary["deletAll"] as! Bool
            
            
        } else {
            Settings.SharedInstance.sharedSettings.funMode = false
            Settings.SharedInstance.sharedSettings.numPhotos = 0
            Settings.SharedInstance.sharedSettings.deleteAll = true
        }
        
        
    }
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    var filePath : String {
        let manager = NSFileManager.defaultManager()
        let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first! as NSURL
        return url.URLByAppendingPathComponent("settings").path!
    }
}

