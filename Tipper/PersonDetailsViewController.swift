//
//  PersonDetailsViewController.swift
//  Tipper
//
//  Created by psytronx on 4/10/15.
//  Copyright (c) 2015 Roger Hom. All rights reserved.
//

import UIKit

protocol PersonDetailsViewControllerDelegate {
    
    func personSubAmountDidChange (personIndex: Int, personSubAmount: Double)
    
}

class PersonDetailsViewController: UIViewController {

    @IBOutlet weak var personSubAmountLabel: UILabel!
    @IBOutlet weak var personSubAmountField: UITextField!
    @IBOutlet weak var personSharedCostValueLabel: UILabel!
    @IBOutlet weak var personTaxValueLabel: UILabel!
    @IBOutlet weak var personTipValueLabel: UILabel!
    @IBOutlet weak var personTotalLabel: UILabel!
    @IBOutlet weak var personTotalValue: UILabel!
    
    var delegate:PersonDetailsViewControllerDelegate? = nil
    
    // Formatters
    var currencyFormatter: NSNumberFormatter = NSNumberFormatter()
    var numberFormatter: NSNumberFormatter = NSNumberFormatter()
    
    // State
    var personIndex = 0 // From Per Person view controller
    var billSubAmount:Double = 100.00 // From Per Person view controller
    var taxRate:Double = 0.1 // From Per Person view controller
    var isTaxIncluded = true // From Per Person view controller
    var tipPercentage:Double = 0.15 // From Per Person view controller
    var numberOfPeople = 1 // From Per Person view controller
    var sharedCost:Double = 0.00 // From Per Person view controller
    var personSubAmount:Double = 0.00
    var personSharedCost:Double = 0.00
    var personTax:Double = 0.00
    var personTip:Double = 0.00
    var personTotal:Double = 0.00

    
    // MARK: - UIViewController methods
    required init(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        // Init formatters
        currencyFormatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
        numberFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
        numberFormatter.maximumFractionDigits = 2
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        calcAmounts()
        refreshView()
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Event Handlers
    
    @IBAction func onPersonSubAmountEditingDidBegin(sender: AnyObject) {
        
        if personSubAmount == 0 {
            personSubAmountField.text = ""
        }
        else{
            personSubAmountField.text = numberFormatter.stringFromNumber(personSubAmount)
        }
        
    }
    
    @IBAction func onPersonSubAmountEditingDidEnd(sender: AnyObject) {

        refreshView()
    
    }
    
    @IBAction func onPersonSubAmountEditingChanged(sender: AnyObject) {
        
        personSubAmount = (personSubAmountField.text as NSString).doubleValue
        calcAmounts()
        refreshView(skipPersonSubAmountField: true)
        if (delegate != nil){
            delegate!.personSubAmountDidChange(personIndex, personSubAmount: personSubAmount)
        }
    }
    
    @IBAction func onBackPress(sender: AnyObject) {
        
        if let navController = self.navigationController {
            navController.popViewControllerAnimated(true)
        }
        
    }
    
    @IBAction func onViewTap(sender: AnyObject) {
        
        view.endEditing(true)
        
    }
    
    // MARK: - Helper Methods
    
    // Given sub amount, calculate tip, tax, shared-cost, and total amount
    // payed by one person
    func calcAmounts () {
            
            personSharedCost = sharedCost/Double(numberOfPeople)
            let personPreTaxSum = personSubAmount + personSharedCost
            personTax = personPreTaxSum * taxRate
            if isTaxIncluded{
                personTip = (personPreTaxSum + personTax) * tipPercentage
            }
            else{
                personTip = personPreTaxSum * tipPercentage
            }
            personTotal = personPreTaxSum + personTax + personTip
            
    }
    
    func refreshView (skipPersonSubAmountField: Bool = false) {
        
        title = "Person \(personIndex + 1)'s Details"
        personSubAmountLabel.text = "Cost of Person \(personIndex + 1)'s Order (Before Tax)"
        if (!skipPersonSubAmountField){
            personSubAmountField.text = currencyFormatter.stringFromNumber(personSubAmount)
        }
        personSharedCostValueLabel.text = currencyFormatter.stringFromNumber(personSharedCost)
        personTaxValueLabel.text = currencyFormatter.stringFromNumber(personTax)
        personTipValueLabel.text = currencyFormatter.stringFromNumber(personTip)
        personTotalLabel.text = "Person \(personIndex + 1) Pays"
        personTotalValue.text = currencyFormatter.stringFromNumber(personTotal)
        
    }

}
