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
    var globalSettings: Settings?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        updateGlobalSettings()
        return true
        
    }
    
    /* Keeps the global settings in sync with core data */
    func updateGlobalSettings() {
        if let settingsDictionary = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as? [String : AnyObject] {
            if let numPhotos = settingsDictionary[Settings.Keys.numPhotos] as? Int {
                globalSettings?.numPhotos = numPhotos
            } else {
                globalSettings?.numPhotos = 24
            }
            globalSettings?.funMode = settingsDictionary[Settings.Keys.funMode] as! Bool
            globalSettings?.saveAlbums = settingsDictionary[Settings.Keys.saveAlbums] as! Bool
        }
    }
    /* Try to delete all photos here if setting is turned off for saving photo albums */
    func applicationWillTerminate(application: UIApplication) {
        
            if globalSettings?.saveAlbums != nil && globalSettings?.saveAlbums == true {
                let fetch1 = NSFetchRequest(entityName: "Pin")
                let fetch2 = NSFetchRequest(entityName: "Photo")
                if #available(iOS 9.0, *) {
                    let deleteRequestPhoto = NSBatchDeleteRequest(fetchRequest: fetch2)
                    let deleteRequestPin = NSBatchDeleteRequest(fetchRequest: fetch1)
                    
                    do {
                        try CoreDataStackManager.sharedInstance().persistentStoreCoordinator?.executeRequest(deleteRequestPin, withContext: self.sharedContext)
                        try CoreDataStackManager.sharedInstance().persistentStoreCoordinator?.executeRequest(deleteRequestPhoto, withContext: self.sharedContext)
                    } catch let error as NSError? {
                        print("Error deleting coredata objects")
                    }
                } else {
                    // Fallback on earlier versions
                }
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

