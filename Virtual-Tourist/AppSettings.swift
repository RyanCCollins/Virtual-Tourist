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
    var funMode: Bool = false
    var loadingIndicator: Bool = true
    
    struct GlobalConfig {
        static var Settings = AppSettings()
    }
    
    func dictionaryForSettings() -> [String: AnyObject] {
        let settingsDict: [String : AnyObject] = [
            
            /* Need to do a bit of core data sorcery here in order to avoid bad access issue:
            * See here:http://stackoverflow.com/questions/24333507/swift-coredata-can-not-set-a-bool-on-nsmanagedobject-subclass-bug?lq=1
            */
            "funMode": NSNumber(bool: AppSettings.GlobalConfig.Settings.funMode),
            "loadingIndicator": NSNumber(bool: AppSettings.GlobalConfig.Settings.loadingIndicator)
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
                AppSettings.GlobalConfig.Settings.funMode = Bool(settings.funMode)
                print("Executed fetch request")
                AppSettings.GlobalConfig.Settings.loadingIndicator = Bool(settings.loadingIndicator)
            }
        } catch let error {
            print(error)
        }
        
    }
    

    func saveSettings (){
        
        let fetchRequest = NSFetchRequest(entityName: "Settings")
        
        sharedContext.performBlockAndWait({
    
        })
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
        sharedContext.performBlockAndWait({
            let settings = Settings(dictionary: settingsDict, context: self.sharedContext)
        })
        
        CoreDataStackManager.sharedInstance().saveContext()
        
    }
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }

}
