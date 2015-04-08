//
//  ViewController.swift
//  Tipper
//
//  Created by psytronx on 4/7/15.
//  Copyright (c) 2015 Roger Hom. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // Outlets
    @IBOutlet weak var billField: UITextField!
    @IBOutlet weak var tipValueLabel: UILabel!
    @IBOutlet weak var totalValueLabel: UILabel!
    @IBOutlet weak var tipControl: UISegmentedControl!
    @IBOutlet weak var includeTaxSwitch: UISwitch!
    
    let tipPercentages = [0.15, 0.18, 0.20, 0.22]
    var defaultTipIndex = 0
    var taxRate = 0.0
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tipValueLabel.text = "$0.00"
        totalValueLabel.text = "$0.00"
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        
        // Reload settings
        var settingsChanged = false
        let settings = getSettings()
        if taxRate != settings.taxRate{
            taxRate = settings.taxRate
            settingsChanged = true
        }
        if defaultTipIndex != settings.defaultTipIndex {
            defaultTipIndex = settings.defaultTipIndex
            // If default changed in Settings, change it in tipper view
            tipControl.selectedSegmentIndex = defaultTipIndex
            settingsChanged = true
        }
        if settingsChanged {
            calculateTipAndTotal()
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onEditingChanged(sender: AnyObject) {
        
        calculateTipAndTotal()
        
    }
    
    @IBAction func onTap(sender: AnyObject) {
        
        view.endEditing(true)
        
    }
    
    // Helper methods
    
    func getSettings() -> (defaultTipIndex: Int, taxRate: Double) {
        
        let settings = NSUserDefaults.standardUserDefaults()
        let defaultTipIndex = settings.integerForKey("defaultTipIndex")
        let taxRate = settings.doubleForKey("taxRate")
        return (defaultTipIndex: defaultTipIndex, taxRate: taxRate)
        
    }
    
    func calculateTipAndTotal() {
        
        var billAmount = (billField.text as NSString).doubleValue
        let tipPercentage = tipPercentages[tipControl.selectedSegmentIndex]
        
        if !includeTaxSwitch.on {
            // Remove tax from tip calculation
            billAmount = billAmount/(taxRate + 1)
        }
        
        let tip = billAmount * tipPercentage
        let total = billAmount + tip
        
        tipValueLabel.text = String(format: "$%.2f", tip)
        totalValueLabel.text = String(format: "$%.2f", total)
        
    }
    
}

