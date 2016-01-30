//
//  AppSettings.swift
//  Virtual-Tourist
//
//  Created by Ryan Collins on 1/30/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit
import CoreData

/* Create an intermediary class and singleton for storing the app settings.
 * Note: the Settings class is an NSManagedObject class and the AppSettings class helps bridge the gap
 * for storing the AppSettings globally while avoiding memory and thread issues.
*/
class AppSettings: NSObject {
    var numberOfPhotos: NSNumber = 0
    var numberOfPins: NSNumber = 0
    
    struct GlobalConfig {
        static var Settings = AppSettings()
    }
    
    func dictionaryForSettings() -> [String: AnyObject] {
        let settingsDict: [String : AnyObject] = [
            "numberOfPhotos": AppSettings.GlobalConfig.Settings.numberOfPhotos,
            "numberOfPins": AppSettings.GlobalConfig.Settings.numberOfPins
        ]
        return settingsDict
    }
    
    func fetchAppSettings() {
        /* Initialize the settings here so that it runs the first time we perform the action */
        var settings = Settings(dictionary: dictionaryForSettings(), context: sharedContext)
        
        let fetchRequest =  NSFetchRequest (entityName: "Settings")
        
        
        do {
            if let fetchedResults = try sharedContext.executeFetchRequest(fetchRequest) as? [Settings] {
                settings = fetchedResults[0]
                AppSettings.GlobalConfig.Settings.numberOfPins = settings.numberOfPins
                AppSettings.GlobalConfig.Settings.numberOfPhotos = settings.numberOfPhotos
            }
        } catch let error {
            print(error)
        }
        
    }

    func saveSettings (){
        
        let fetchRequest = NSFetchRequest(entityName: "Settings")
        
        do {
            if let fetchedResults = try sharedContext.executeFetchRequest(fetchRequest) as? [Settings] {
                for setting in fetchedResults {
                    print("Deleting an object at")
                    sharedContext.deleteObject(setting)
                    
                    CoreDataStackManager.sharedInstance().saveContext()
                }
            }
            
        } catch let error {
            print(error)
        }

        
        let settingsDict = dictionaryForSettings()
        
        let settings = Settings(dictionary: settingsDict, context: sharedContext)
        
        CoreDataStackManager.sharedInstance().saveContext()
        
    }
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }

}
