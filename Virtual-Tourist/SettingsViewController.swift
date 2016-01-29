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
    func didChangeSettings(funMode: Bool, deleteAll: Bool)
}

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var modalView: SpringView!
    @IBOutlet weak var funModeToggle: UISwitch!
    @IBOutlet weak var savedPhotosLabel: UILabel!
    var settingsChanged = false
    
    var delegate: SettingsPickerDelegate?

    
    /* Access to view for transformation */

    override func viewDidLoad() {
        super.viewDidLoad()
        
        modalView.transform = CGAffineTransformMakeTranslation(-300, 0)
        
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
        Settings.SharedInstance.sharedSettings.deleteAll = true

    }
    
    func updateSettingsView(){
        funModeToggle.on = Settings.SharedInstance.sharedSettings.funMode
        savedPhotosLabel.text = String(Settings.SharedInstance.sharedSettings.numPhotos)
    }
    
    func shouldChangeSetings() {
        if Settings.SharedInstance.sharedSettings.needsUpdate {
            delegate?.didChangeSettings(Settings.SharedInstance.sharedSettings.funMode, deleteAll: Settings.SharedInstance.sharedSettings.deleteAll)
        }
        
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
    

    
    /* Save the number of photos and funmode toggle settings */
    func saveSettingsState() {

        
        let dictionary = [
            "funMode": funModeToggle.on,
            "deleteAll": Settings.SharedInstance.sharedSettings.deleteAll
        ]
        
        
        NSKeyedArchiver.archiveRootObject(dictionary, toFile: filePath)
    }
}
