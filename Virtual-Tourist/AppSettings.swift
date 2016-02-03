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

        ]
        return settingsDict
    }
    
    func fetchAppSettings() {
        /* Initialize the settings here so that it runs the first time we perform the action */
        var settings = Settings(dictionary: dictionaryForSettings(), context: sharedContext)
        
        let fetchRequest =  NSFetchRequest (entityName: "Settings")
        let sortDesciptors = NSSortDescriptor(key: "timeStamp", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDesciptors]
        
        do {
            /* Type cast the settings array to bridge gap between NS and Swift */
            var settingsArray: [Settings] = [Settings]()
            settingsArray = try sharedContext.executeFetchRequest(fetchRequest) as! [Settings]
            settings = settingsArray[0]
            print(settings)
        } catch let error as NSError? {
            print(error)
        }
        
        AppSettings.GlobalConfig.Settings.funMode = Bool(settings.funMode)
    
    }
    
    /* Get our most recent settings from the fetchedResultsController */
    func executeFetch() {
        let fetchRequest = NSFetchRequest(entityName: "Settings")
        
            do {
                let fetchedResults = try self.sharedContext.executeFetchRequest(fetchRequest) as? [Settings]
                for setting in fetchedResults! {
                    sharedContext.deleteObject(setting)
                }
            
            } catch let error as NSError {
                print(error)
            }
    }
    
    /* Saves the settings to core data, bridging the gap between our model classes */
    func saveSettings (){
        
        let settingsDict = dictionaryForSettings()
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
