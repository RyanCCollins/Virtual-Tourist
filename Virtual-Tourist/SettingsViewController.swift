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



class SettingsViewController: UIViewController {
    
    @IBOutlet weak var modalView: SpringView!
    @IBOutlet weak var funModeToggle: UISwitch!
    @IBOutlet weak var savedPhotosLabel: UILabel!
    
    /* Access to view for transformation */

    override func viewDidLoad() {
        super.viewDidLoad()
        
        modalView.transform = CGAffineTransformMakeTranslation(-300, 0)
        restoreSettingsState()
        funModeToggle.enabled = true
        
    }
    
    override func viewDidAppear(animated: Bool) {
        modalView.animate()
        
     self.presentingViewController!.view.transformOut(self)
    }
    
    override func viewWillDisappear(animated: Bool) {
        saveSettingsState()
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
            let saveAlbumsSetting = settingsDictionary["saveAlbums"] as! Bool
            let numPhotos = settingsDictionary["numberOfPhotos"] as! Int
            
            funModeToggle.on = funModeSetting
            savedPhotosLabel.text = String(numPhotos)
        }
        
        
    }
    
    
    func saveSettingsState() {
        
        let dictionary = [
            "funMode" : funModeToggle.on
        ]
        
        NSKeyedArchiver.archiveRootObject(dictionary, toFile: filePath)
    }
}
