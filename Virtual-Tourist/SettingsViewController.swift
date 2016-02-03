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
    func didDeleteAll()
}

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var modalView: SpringView!

    @IBOutlet weak var funModeToggle: UISwitch!
    
    /* Access to view for transformation */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        modalView.transform = CGAffineTransformMakeTranslation(-300, 0)
        updateSettingsView()
    }
    
    /* A little transition to make it look nice */
    override func viewDidAppear(animated: Bool) {
        modalView.animate()
        
        self.presentingViewController!.view.transformOut(self)
    }
    
    /* Toggle the two different settings and then save to core data 
     * Note: we are determining whether the sender is on or not
     * because just setting the value equal to sender.on was causing issues
    */
    @IBAction func didToggleFunMode(sender: UISwitch) {

        AppSettings.sharedSettings().saveSettings(funModeToggle.on)
        sharedContext.performBlockAndWait({
            CoreDataStackManager.sharedInstance().saveContext()
        })
    }
    
    func closeSettingsView() {
        self.presentingViewController!.view.transformIn(self)
        modalView.animation = "slideRight"
        modalView.animateFrom = false
        modalView.animateToNext({
            self.dismissViewControllerAnimated(false, completion: nil)
        })
    }
    
    func updateSettingsView(){
        
        if let appSettings = AppSettings.sharedSettings().fetchAppSettings() {
            
            funModeToggle.on = Bool(appSettings.funMode)
        } else {
            /* Setup initial settings */
            AppSettings.sharedSettings().saveSettings(false)
            funModeToggle.on = false
        }
  
    }
    
    /* Convenience for getting the managedObjectContext singleton */
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    
    @IBAction func didTapViewToClose(sender: AnyObject) {
        closeSettingsView()
    }
    
}

