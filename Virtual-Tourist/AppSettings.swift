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
    
    class func sharedSettings() -> AppSettings {
        struct singleton {
            static var sharedInstance = AppSettings()
        }
        return singleton.sharedInstance
    }
    
    func dictionaryForSettings(funMode: Bool) -> [String: AnyObject] {
        let settingsDict: [String : AnyObject] = [
            
            /* Need to do a bit of core data sorcery here in order to avoid bad access issue:
            * See here:http://stackoverflow.com/questions/24333507/swift-coredata-can-not-set-a-bool-on-nsmanagedobject-subclass-bug?lq=1
            */
            "funMode": NSNumber(bool: funMode),
        ]
        return settingsDict
    }
    
    func fetchAppSettings() -> Settings? {
        
        if let newestSetting = performFetch() {
            return newestSetting
        } else {
            return nil
        }
    }
    
    
    /* Performs a fetch to get only the most recent setting */
    func performFetch() -> Settings? {
        let fetch = NSFetchRequest(entityName: "Settings")
        let entity = NSEntityDescription.entityForName("Settings", inManagedObjectContext: sharedContext)
        
        fetch.sortDescriptors = [NSSortDescriptor(key: "timeStamp", ascending: false)]
        
        fetch.entity = entity
        
        do {
            /* Find the results and delete all but the first / most recent one */
            if let results = try sharedContext.executeFetchRequest(fetch) as? [Settings] {
                
                /* Return nil if no settings are existing yet */
                guard results.count > 0 else {
                    return nil
                }
                
                let resultToReturn = results[0]
                
                /* Handle the computation on the main thread for saving to coredata */
                sharedContext.performBlockAndWait({
                    for result in results.enumerate() {
                        let settingToDelete = result.element
                        if result.index != 0 {
                            self.sharedContext.deleteObject(settingToDelete)
                        }
                        
                    }
                    CoreDataStackManager.sharedInstance().saveContext()
                })
                
                
                return resultToReturn
            }
            
        } catch {
            let fetchError = error as NSError
            print(fetchError)
            
        }
        return nil
    }
    
    func createInitialSettings() {
        saveSettings(false)
    }
    
    /* Saves the settings to core data, bridging the gap between our model classes */
    func saveSettings (funMode: Bool){
        
        let settingsDict = dictionaryForSettings(funMode)
        print(settingsDict)
        /* Keep all core data on a concurent thread */
        sharedContext.performBlockAndWait({
            
            let settings = Settings(dictionary: settingsDict, context: self.sharedContext)

        })

        CoreDataStackManager.sharedInstance().saveContext()
        
    }
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }

}
