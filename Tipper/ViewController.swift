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
    
    // State
    var defaultTipIndex = 0
    var taxRate = 0.0
    var isTaxIncluded = true
    var billSubAmount:Double = 0
    var billAmount:Double = 0
    var tipPercentage:Double = 0
    var tip:Double = 0
    var total:Double = 0
    
    // MARK: - UIViewController Methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tipValueLabel.text = "$0.00"
        totalValueLabel.text = "$0.00"
        
        tipPercentage = tipPercentages[defaultTipIndex]
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        
        // Reload settings and refresh UI elements as needed
        var settingsChanged = false
        let settings = getSettings()
        // Check if tax rate was changed
        if taxRate != settings.taxRate{
            taxRate = settings.taxRate
            recalcBillAmountFromSubAmount()
            calcTipAndTotal()
            settingsChanged = true
        }
        // Check if default tip percentage was changed
        if defaultTipIndex != settings.defaultTipIndex {
            defaultTipIndex = settings.defaultTipIndex
            tipControl.selectedSegmentIndex = defaultTipIndex
            tipPercentage = tipPercentages[tipControl.selectedSegmentIndex]
            calcTipAndTotal()
            settingsChanged = true
        }
        if settingsChanged {
            refreshView()
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Event Callbacks
    
    @IBAction func onBillSubAmountEditingDidBegin(sender: AnyObject) {
    
        if billSubAmount == 0 {
            billSubAmountField.text = ""
        }
        else{
            billSubAmountField.text = String(format:"%.2f", billSubAmount) // Don't show $ sign when editing
        }
        
    }
    
    @IBAction func onBillSubAmountEditingDidEnd(sender: AnyObject) {
        
        refreshSubAmountField()
        
    }
    
    @IBAction func onBillAmountEditingDidBegin(sender: AnyObject) {
        
        if billAmount == 0 {
            billField.text = ""
        }
        else{
            billField.text = String(format:"%.2f", billAmount) // Don't show $ sign when editing
        }
        
    }
    
    @IBAction func onBillAmountEditingDidEnd(sender: AnyObject) {
    
        refreshAmountField()
    
    }
    
    @IBAction func onBillSubAmountEditingChanged(sender: AnyObject) {
    
        billSubAmount = (billSubAmountField.text as NSString).doubleValue
        recalcBillAmountFromSubAmount()
        refreshAmountField()
        calcTipAndTotal()
        refreshTipAndTotal()
        
    }
    
    @IBAction func onBillEditingChanged(sender: AnyObject) {
        
        billAmount = (billField.text as NSString).doubleValue
        recalcBillSubAmountFromAmount()
        refreshSubAmountField()
        calcTipAndTotal()
        refreshTipAndTotal()
        
    }
    
    @IBAction func onTipValueChanged(sender: AnyObject) {
        
        tipPercentage = tipPercentages[tipControl.selectedSegmentIndex]
        calcTipAndTotal()
        refreshTipAndTotal()
        
    }
    
    @IBAction func onIncludeTaxSwitchChanged(sender: AnyObject) {
        
        isTaxIncluded = includeTaxSwitch.on
        calcTipAndTotal()
        refreshTipAndTotal()
        
    }
    
    @IBAction func onTap(sender: AnyObject) {
        
        view.endEditing(true)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        // Send over state values to next view controller
        if(segue.identifier == "tipperToPerPerson"){
            var navController = segue.destinationViewController as! UINavigationController
            var controller = navController.topViewController as! PerPersonViewController
            controller.billSubAmount = billSubAmount
            controller.billTotal = total
            controller.taxRate = taxRate
            controller.isTaxIncluded = isTaxIncluded
            controller.tipPercentage = tipPercentage
        }
        
    }
    
    // MARK: - Helper methods
    
    func getSettings() -> (defaultTipIndex: Int, taxRate: Double) {
        
        let settings = NSUserDefaults.standardUserDefaults()
        let defaultTipIndex = settings.integerForKey("defaultTipIndex")
        let taxRate = settings.doubleForKey("taxRate")
        return (defaultTipIndex: defaultTipIndex, taxRate: taxRate)
        
    }
    
    func recalcBillAmountFromSubAmount(){
        
        billAmount = billSubAmount * (taxRate + 1)
        
    }
    
    func recalcBillSubAmountFromAmount(){
        
        billSubAmount = billAmount / (taxRate + 1)
        
    }
    
    func calcTipAndTotal(){
        
        // Determine tip
        if isTaxIncluded {
            tip = billAmount * tipPercentage
        }
        else {
            tip = billSubAmount * tipPercentage
        }
        
        // Determine total amount
        total = billAmount + tip
        
    }
    
    // Refresh visual elements
    func refreshSubAmountField () {
        
        billSubAmountField.text = NSString(format: "$%.2f", billSubAmount) as String
    }
    
    
    func refreshAmountField () {
        
        billField.text = NSString(format: "$%.2f", billAmount) as String
    }
    
    
    func refreshTipAndTotal () {
        
        tipValueLabel.text = String(format: "$%.2f", tip)
        totalValueLabel.text = String(format: "$%.2f", total)
        
    }
    
    func refreshView (){
        refreshSubAmountField()
        refreshAmountField()
        refreshTipAndTotal()
    }
    
}

