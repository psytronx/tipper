//
//  PerPersonViewController.swift
//  Tipper
//
//  Created by psytronx on 4/9/15.
//  Copyright (c) 2015 Roger Hom. All rights reserved.
//

import UIKit

class PerPersonViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, PersonDetailsViewControllerDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var numberOfPeopleField: UITextField!
    @IBOutlet weak var sharedCostField: UITextField!
    @IBOutlet weak var peopleTable: UITableView!
    @IBOutlet weak var groupIsPayingValueLabel: UILabel!
    @IBOutlet weak var billTotalValueLabel: UILabel!
    @IBOutlet weak var shortByValueLabel: UILabel!
    @IBOutlet weak var shortByLabel: UILabel!
    
    // State
    var billSubAmount:Double = 100.00 // From Tipper view controller
    var billTotal:Double = 120.00 // From Tipper view controller
    var taxRate:Double = 0.1 // From Tipper view controller
    var isTaxIncluded = true // From Tipper view controller
    var tipPercentage:Double = 0.15 // From Tipper view controller
    var numberOfPeople = 1
    var sharedCost:Double = 0.0
    var peopleSubAmounts:[Double] = []
    
    
    // MARK: - UIViewController Methods

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // todo Try to load previous values of peopleSubAmounts. If peopleSubAmounts has not been populated yet, calculate this
        resetPeopleSubAmounts(numberOfPeople, billSubAmount: billSubAmount, sharedCost: sharedCost)
        refreshView()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        
    }
    
    // todo Persist peopleSubAmounts and other values before view disappears

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Event Callbacks
    
    @IBAction func onNumberOfPeopleEditingDidEnd(sender: AnyObject) {
        
        // Setup alert
        let alertController = UIAlertController(title: "Invalid value", message:
            "Number of people needs to be one or more.", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
        
        // Update number of people
        let newNumberOfPeople = numberOfPeopleField.text.toInt()
        if newNumberOfPeople == numberOfPeople{
            // If no change, don't do anything
            return
        }
        else if newNumberOfPeople == nil || newNumberOfPeople <= 0 {
            println("Invalid value")
            // If number of people is below 0, alert user and undo change.
            self.presentViewController(alertController, animated: true, completion: nil)
            numberOfPeopleField.text = String(numberOfPeople)
        }
        else{
            // If number is greater than 0, accept the new value and refresh the table
            numberOfPeople = newNumberOfPeople!
            resetPeopleSubAmounts(numberOfPeople, billSubAmount:billSubAmount, sharedCost:sharedCost)
            refreshView()
        }
        
    }
    
    @IBAction func onSharedCostEditingDidBegin(sender: AnyObject) {
        
        if sharedCost == 0 {
            sharedCostField.text = ""
        }
        else{
            sharedCostField.text = String(format:"%.2f", sharedCost)
        }
        
    }
    
    @IBAction func onSharedCostEditingDidEnd(sender: AnyObject) {
        
        sharedCost = (sharedCostField.text as NSString).doubleValue
        refreshView()
        
    }
    
    @IBAction func onDonePush(sender: AnyObject) {
        
        if let navController = self.navigationController {
            navController.dismissViewControllerAnimated(true, completion: nil)
        }
        
    }
    
    @IBAction func onViewTap(sender: AnyObject) {
        
        view.endEditing(true)
        
    }
    
    
    // MARK: - UITableViewDataSource/Delegate Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return numberOfPeople
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! UITableViewCell
        if let textLabel = cell.textLabel{
            textLabel.text = String(format: "Person %d pays ", indexPath.row + 1);
        }
        let personTotalAmount = calcAmountsForPerson(peopleSubAmounts[indexPath.row]).personTotalAmount
        if let detailTextLabel = cell.detailTextLabel{
            detailTextLabel.text = String(format: "$%.2f", personTotalAmount);
        }
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        performSegueWithIdentifier("perPersonToPersonDetails", sender: self)
        
    }
    
    
    // MARK: - UIGestureRecognizerDelegate Methods
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        
        // Deal with table cell selection
        if(touch.view.isDescendantOfView(peopleTable)) {
//            sharedCost = (sharedCostField.text as NSString).doubleValue
//            refreshView()
            view.endEditing(true)
            return false;
        }
        
        return true; // handle the touch
        
    }
    
    
    // MARK: - PersonDetailsViewControllerDelegate Methods
    
    func personSubAmountDidChange (personIndex: Int, personSubAmount: Double) {
        
        peopleSubAmounts[personIndex] = personSubAmount
        refreshView()
        
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "perPersonToPersonDetails"{
            let pvc = segue.destinationViewController as! PersonDetailsViewController
            // Pass along state to PersonDetailsViewController
            let indexPath = peopleTable.indexPathForSelectedRow()!
            pvc.personIndex = indexPath.row
            pvc.numberOfPeople = numberOfPeople
            pvc.personSubAmount = peopleSubAmounts[pvc.personIndex]
            pvc.taxRate = taxRate
            pvc.isTaxIncluded = isTaxIncluded
            pvc.tipPercentage = tipPercentage
            pvc.isTaxIncluded = isTaxIncluded
            pvc.tipPercentage = tipPercentage
            pvc.sharedCost = sharedCost
            pvc.delegate = self
        }
        
    }

    
    // MARK: - Helper Methods
    
    // Given new number of people, reset the subamounts per person to be evenly divided
    func resetPeopleSubAmounts(numberOfPeople: Int, billSubAmount: Double, sharedCost: Double) {
        
        // Re-instantiate array with new sub amount values per person
        let personSubAmount = (billSubAmount - sharedCost)/Double(numberOfPeople)
        peopleSubAmounts = Array<Double>(count:numberOfPeople, repeatedValue: personSubAmount)
        
    }
    
    // Given sub amount, calculate tip, tax, shared-cost, and total amount
    // payed by one person
    // todo - move this to static class, since it's used in multiple classes
    func calcAmountsForPerson (personSubAmount:Double)
        -> (personSharedCost:Double, personTaxAmount:Double, personTipAmount:Double, personTotalAmount:Double) {
            
            let personSharedCost = sharedCost/Double(numberOfPeople)
            let personPreTaxSum = personSubAmount + personSharedCost
            let personTaxAmount = personPreTaxSum * taxRate
            var personTipAmount:Double
            if isTaxIncluded{
                personTipAmount = (personPreTaxSum + personTaxAmount) * tipPercentage
            }
            else{
                personTipAmount = personPreTaxSum * tipPercentage
            }
            let personTotalAmount = personPreTaxSum + personTaxAmount + personTipAmount
            
            return (
                personSharedCost: personSharedCost,
                personTaxAmount: personTaxAmount,
                personTipAmount: personTipAmount,
                personTotalAmount: personTotalAmount
            )
        
    }
    
    // Refresh the table view and other visual elements
    func refreshView () {
        
        // Refresh Number of People
        numberOfPeopleField.text = String(numberOfPeople)
        
        // Refresh Cost Shared By Group
        sharedCostField.text = String(format:"$%.2f", sharedCost)
        
        // Refresh table view
        peopleTable.reloadData()
        
        // Refresh "Group is Paying" value
        var groupIsPaying:Double = 0.00
        for personSubAmount in peopleSubAmounts {
            groupIsPaying += calcAmountsForPerson(personSubAmount).personTotalAmount
        }
        groupIsPayingValueLabel.text = String(format:"$%.2f", groupIsPaying)
        
        // Refresh "Total" value
        billTotalValueLabel.text = String(format:"$%.2f", billTotal)
        
        // Refresh "Short By/ Over" value
        var difference = groupIsPaying - billTotal
        if difference < 0{
            shortByLabel.text = "Underpaying by "
            shortByValueLabel.text = String(format:"$%.2f", -1 * difference)
        }else{
            shortByLabel.text = "Overpaying by "
            shortByValueLabel.text = String(format:"$%.2f", difference)
        }
        
    }
    
    

}
