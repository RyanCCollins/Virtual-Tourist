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
    var appSettings: Settings!
    

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        restoreSettingsState()
        
        return true
    }
    
    func handleLoadingNotifications(){
        
    }
    
    func restoreSettingsState() {
        
        if let settingsDictionary = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as? [String : AnyObject] {
            
            appSettings = Settings(dictionary: settingsDictionary, context: sharedContext)
            
        } else {
            
            /* Initialize the defaults if settings don't exist */
            let dictionary: [String: AnyObject] = ["funMode" : false, "deleteAll": false, "numPhotos": 0]
            sharedContext.performBlockAndWait({
                self.appSettings = Settings(dictionary: dictionary, context: self.sharedContext)
                CoreDataStackManager.sharedInstance().saveContext()
            })
            
        }
        
    }
    
    /* Save the number of photos and funmode toggle settings */
    func saveSettingsState() {
    
        let dictionary: [String:AnyObject] = [
            "funMode": appSettings.funMode,
            "deleteAll": appSettings.deleteAll,
            "numPhotos": appSettings.numPhotos!
        ]
        
        NSKeyedArchiver.archiveRootObject(dictionary, toFile: filePath)
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

