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
    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    
    /* Access to view for transformation */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        modalView.transform = CGAffineTransformMakeTranslation(-300, 0)
        updateSettingsView()
    }

    @IBAction func didTapFunModeToggleUpInside(sender: AnyObject) {
        appDelegate.appSettings.funMode = true
        appDelegate.saveSettingsState()
    }
    
    /* A little transition to make it look nice */
    override func viewDidAppear(animated: Bool) {
        modalView.animate()
        
        self.presentingViewController!.view.transformOut(self)
    }
    

    @IBAction func didTapClearUpInside(sender: AnyObject) {
        appDelegate.saveSettingsState()
        appDelegate.appSettings.needsUpdate = true
    }
    
    func updateSettingsView(){
        funModeToggle.on = appDelegate.appSettings.funMode
        savedPhotosLabel.text = String(appDelegate.appSettings.numPhotos)
    }
    
    func shouldChangeSetings() {
        if appDelegate.appSettings.needsUpdate {
            delegate?.didChangeSettings(appDelegate.appSettings.funMode, deleteAll: appDelegate.appSettings.deleteAll)
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
    
}
