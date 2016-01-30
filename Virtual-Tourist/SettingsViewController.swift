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
    @IBOutlet weak var savedPhotosLabel: UILabel!
    @IBOutlet weak var savedPinsLabel: UILabel!
    
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
    
    /* When you tap the clear button, we need to tell the global seetins that we need to clear the data */
    @IBAction func didTapClearUpInside(sender: AnyObject) {
        AppSettings.GlobalConfig.Settings.numberOfPhotos = 0
        AppSettings.GlobalConfig.Settings.numberOfPins = 0
        AppSettings.GlobalConfig.Settings.saveSettings()
        delegate?.didDeleteAll()
    }
    
    func updateSettingsView(){
        savedPhotosLabel.text = String(AppSettings.GlobalConfig.Settings.numberOfPhotos)
        savedPinsLabel.text = String(AppSettings.GlobalConfig.Settings.numberOfPins)
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
