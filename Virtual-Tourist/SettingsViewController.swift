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
    @IBOutlet weak var loadingIndicatorToggle: UISwitch!

    @IBOutlet weak var funModeToggle: UISwitch!
    
    var delegate: SettingsPickerDelegate?
    
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
        if sender.on == true {
            AppSettings.GlobalConfig.Settings.funMode = true
        } else {
            AppSettings.GlobalConfig.Settings.funMode = false
        }
        
        AppSettings.GlobalConfig.Settings.saveSettings()
    }
    
    @IBAction func didToggleLoadingIndicator(sender: UISwitch) {
        if sender.on == true {
            AppSettings.GlobalConfig.Settings.loadingIndicator = true
        } else {
            AppSettings.GlobalConfig.Settings.loadingIndicator = false
        }
        AppSettings.GlobalConfig.Settings.saveSettings()
    }
    
    /* When you tap the clear button, we need to tell the global seetins that we need to clear the data */
    @IBAction func didTapClearUpInside(sender: AnyObject) {

        delegate?.didDeleteAll()
        closeSettingsView()
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
        funModeToggle.on = AppSettings.GlobalConfig.Settings.funMode
        loadingIndicatorToggle.on = AppSettings.GlobalConfig.Settings.loadingIndicator
    }
    
    
    @IBAction func didTapViewToClose(sender: AnyObject) {
        closeSettingsView()
    }
    
}
