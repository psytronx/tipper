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
    @IBOutlet weak var billSubAmountField: UITextField!
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
        
        refreshBillAmount()
        refreshBillSubAmount()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        
        // Reload settings and refresh UI elements as needed
        var settingsChanged = false
        let settings = getSettings()
        if taxRate != settings.taxRate{
            taxRate = settings.taxRate
            refreshBillAmount()
            settingsChanged = true
        }
        if defaultTipIndex != settings.defaultTipIndex {
            defaultTipIndex = settings.defaultTipIndex
            tipControl.selectedSegmentIndex = defaultTipIndex
            settingsChanged = true
        }
        if settingsChanged {
            refreshTipAndTotal()
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onBillEditingChanged(sender: AnyObject) {
        
        refreshBillSubAmount()
        refreshTipAndTotal()
        
    }
    
    @IBAction func onBillSubAmountEditingChanged(sender: AnyObject) {
    
        refreshBillAmount()
        refreshTipAndTotal()
        
    }
    
    @IBAction func onTipValueChanged(sender: AnyObject) {
        
        refreshTipAndTotal()
        
    }
    
    @IBAction func onIncludeTaxSwitchChanged(sender: AnyObject) {
        
        refreshTipAndTotal()
        
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
    
    func refreshBillSubAmount(){
        
        let newBillSubAmount = (billField.text as NSString).doubleValue / (taxRate + 1)
        billSubAmountField.text = NSString(format: "%.2f", newBillSubAmount)
        
    }
    
    func refreshBillAmount(){
        
        let newBillAmount = (billSubAmountField.text as NSString).doubleValue * (1 + taxRate)
        billField.text = NSString(format: "%.2f", newBillAmount)
        
    }
    
    func refreshTipAndTotal() {
        
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

