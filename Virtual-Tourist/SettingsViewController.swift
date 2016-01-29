//
//  SettingsViewController.swift
//  
//
//  Created by Ryan Collins on 1/8/16.
//
//

import UIKit
import CoreData
import Spring

/* Settings delegate for changing settings externally and applying coredata changes appwide */
protocol SettingsPickerDelegate {
    func didChangeSettings(settings: Settings)
    func shouldDeleteAllSavedData()
    func shouldUpdateSettings(settings: Settings)
}

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var modalView: SpringView!
    @IBOutlet weak var funModeToggle: UISwitch!
    @IBOutlet weak var savedPhotosLabel: UILabel!
    
    
    var delegate: SettingsPickerDelegate?

    
    /* Access to view for transformation */

    override func viewDidLoad() {
        super.viewDidLoad()
        
        modalView.transform = CGAffineTransformMakeTranslation(-300, 0)
        restoreSettingsState()
        funModeToggle.enabled = true
        
    }
    
    /* A little transition to make it look nice */
    override func viewDidAppear(animated: Bool) {
        modalView.animate()
        
        self.presentingViewController!.view.transformOut(self)
    }
    
    override func viewWillDisappear(animated: Bool) {
        saveSettingsState()
    }
    
    @IBAction func didTapClearUpInside(sender: AnyObject) {
        var settings = [
            "fun"
        ]

    }
    
    func changeSettings(settings: Settings) {
        delegate?.didChangeSettings(settings)
    }
    
    @IBAction func didTapViewToClose(sender: AnyObject) {
        self.presentingViewController!.view.transformIn(self)
        modalView.animation = "slideRight"
        modalView.animateFrom = false
        modalView.animateToNext({
            self.dismissViewControllerAnimated(false, completion: nil)
        })
    }

    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    var filePath : String {
        let manager = NSFileManager.defaultManager()
        let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first! as NSURL
        return url.URLByAppendingPathComponent("settings").path!
    }
    
    func restoreSettingsState() {
        
        if let settingsDictionary = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as? [String : AnyObject] {
            
            let funModeSetting = settingsDictionary["funMode"] as! Bool
            let numPhotos = settingsDictionary["numberOfPhotos"] as! Int
            
            funModeToggle.on = funModeSetting
            savedPhotosLabel.text = String(numPhotos)
            
            // Save the number of photos to the appDelegate automatically, so that we can access them app wide.
            Settings.SharedInstance.sharedSettings.numPhotos = numPhotos
            appDelegate.numPhotosLoaded = numPhotos
        }
        
        
    }
    
    /* Save the number of photos and funmode toggle settings */
    func saveSettingsState() {
        var numPhotos = 0
        if let num = appDelegate.numPhotosLoaded {
            numPhotos = num
        }
        
        let dictionary = [
            "funMode": funModeToggle.on,
            "numPhotos": numPhotos
        ]
        
        
        NSKeyedArchiver.archiveRootObject(dictionary, toFile: filePath)
    }
}
