//
//  TipperViewController.swift
//  Tipper
//
//  Created by psytronx on 4/7/15.
//  Copyright (c) 2015 Roger Hom. All rights reserved.
//

import UIKit

class TipperViewController: UIViewController {

    // Outlets
    @IBOutlet weak var billSubAmountField: UITextField!
    @IBOutlet weak var billField: UITextField!
    @IBOutlet weak var tipValueLabel: UILabel!
    @IBOutlet weak var totalValueLabel: UILabel!
    @IBOutlet weak var tipControl: UISegmentedControl!
    @IBOutlet weak var includeTaxSwitch: UISwitch!
    
    let tipPercentages = [0.15, 0.18, 0.20, 0.22]
    var currencyFormatter: NSNumberFormatter = NSNumberFormatter()
    var numberFormatter: NSNumberFormatter = NSNumberFormatter()
    
    // State
    var defaultTipIndex = 0 // From Settings
    var taxRate = 0.0 // From Settings
    var isTaxIncluded = true
    var billSubAmount:Double = 0
    var billAmount:Double = 0
    var tipPercentage:Double = 0
    var tip:Double = 0
    var total:Double = 0
    
    // MARK: - UIViewController Methods
    
    required init(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        // Init formatters
        currencyFormatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
        numberFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
        numberFormatter.maximumFractionDigits = 2
        
        // Register application active/resign notification observers
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("onApplicationDidBecomeActive"), name: UIApplicationDidBecomeActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("onApplicationResigningActive"), name: UIApplicationWillResignActiveNotification, object: nil)
        
    }
    
    deinit {
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
    }
    
    func onApplicationDidBecomeActive () {
        
        // Refresh currencyFormatter based on current locale, which may have changed in Settings
        
        
        // Load settings
        let settings = getSettings()
        taxRate = settings.taxRate
        defaultTipIndex = settings.defaultTipIndex
        
        // Load bill sub amount and amount if under 10 minutes
        let savedState = NSUserDefaults.standardUserDefaults()
        if let billAmountLastSavedDate = savedState.objectForKey("billAmountLastSavedDate") as? NSDate {
            let now = NSDate()
            let interval = now.timeIntervalSinceDate(billAmountLastSavedDate)
            if interval < 60 * 10 {
                billSubAmount = savedState.doubleForKey("billSubAmount")
                tipControl.selectedSegmentIndex = savedState.integerForKey("tipIndex")
                tipPercentage = tipPercentages[savedState.integerForKey("tipIndex")]
                isTaxIncluded = savedState.boolForKey("isTaxIncluded")
            }
            else {
                // Default values
                billSubAmount = 0
                tipControl.selectedSegmentIndex = defaultTipIndex
                tipPercentage = tipPercentages[defaultTipIndex]
                isTaxIncluded = true
            }
        }
        else{
            // If no billAmountLastSavedDate, use default values
            billSubAmount = 0
            tipControl.selectedSegmentIndex = defaultTipIndex
            tipPercentage = tipPercentages[defaultTipIndex]
            isTaxIncluded = true
        }
        recalcBillAmountFromSubAmount()
        calcTipAndTotal()
        refreshView()
    }
    
    func onApplicationResigningActive () {
        
        // Save state
        let savedState = NSUserDefaults.standardUserDefaults()
        savedState.setDouble(billSubAmount, forKey: "billSubAmount")
        savedState.setInteger(tipControl.selectedSegmentIndex, forKey: "tipIndex")
        savedState.setBool(isTaxIncluded, forKey: "isTaxIncluded")
        savedState.setObject(NSDate(), forKey: "billAmountLastSavedDate")
        
        savedState.synchronize()
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        
        // Reload settings and refresh UI elements if settings were changed
        var settingsChanged = false
        let settings = getSettings()
        // Check if tax rate was changed
        if taxRate != settings.taxRate{
            taxRate = settings.taxRate
            recalcBillAmountFromSubAmount()
//            calcTipAndTotal()
            settingsChanged = true
        }
        // Check if default tip percentage was changed
        if defaultTipIndex != settings.defaultTipIndex {
            defaultTipIndex = settings.defaultTipIndex
            tipControl.selectedSegmentIndex = defaultTipIndex
            tipPercentage = tipPercentages[tipControl.selectedSegmentIndex]
//            calcTipAndTotal()
            settingsChanged = true
        }
        if settingsChanged {
            calcTipAndTotal()
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
            billSubAmountField.text = numberFormatter.stringFromNumber(billSubAmount) // Don't show currency symbol when editing
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
            billField.text = numberFormatter.stringFromNumber(billAmount) // Don't show currency symbol when editing
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
        
        billSubAmountField.text = currencyFormatter.stringFromNumber(billSubAmount)
        
    }
    
    
    func refreshAmountField () {
        
        billField.text = currencyFormatter.stringFromNumber(billAmount)
        
    }
    
    
    func refreshTipAndTotal () {
        
        includeTaxSwitch.on = isTaxIncluded
        tipValueLabel.text = currencyFormatter.stringFromNumber(tip)
        totalValueLabel.text = currencyFormatter.stringFromNumber(total)
        
    }
    
    func refreshView (){
        refreshSubAmountField()
        refreshAmountField()
        refreshTipAndTotal()
    }
    
}

