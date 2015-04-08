//
//  SettingsViewController.swift
//  Tipper
//
//  Created by psytronx on 4/7/15.
//  Copyright (c) 2015 Roger Hom. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var defaultTipControl: UISegmentedControl!
    @IBOutlet weak var taxRateField: UITextField!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Get settings
        let settings = NSUserDefaults.standardUserDefaults()
        let defaultTipIndex = settings.integerForKey("defaultTipIndex")
        let taxRate = String(format:"%.2f", settings.doubleForKey("taxRate") * 100)
        defaultTipControl.selectedSegmentIndex = defaultTipIndex
        taxRateField.text = taxRate
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    @IBAction func onGoBackClick(sender: AnyObject) {
        
        if let navController = self.navigationController {
            navController.popViewControllerAnimated(true)
        }
        
    }
    
    @IBAction func onDefaultTipChanged(sender: AnyObject) {
        
        // Save settings
        var settings = NSUserDefaults.standardUserDefaults()
        settings.setInteger(defaultTipControl.selectedSegmentIndex, forKey: "defaultTipIndex")
        settings.synchronize()
        
    }
    
    @IBAction func onTaxRateChange(sender: AnyObject) {
        
        // Save settings
        var settings = NSUserDefaults.standardUserDefaults()
        settings.setDouble((taxRateField.text as NSString).doubleValue/100, forKey: "taxRate")
        settings.synchronize()
        
    }
    
    @IBAction func onTap(sender: AnyObject) {
        
        view.endEditing(true)
        
    }
}
