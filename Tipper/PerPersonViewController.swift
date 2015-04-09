//
//  PerPersonViewController.swift
//  Tipper
//
//  Created by psytronx on 4/9/15.
//  Copyright (c) 2015 Roger Hom. All rights reserved.
//

import UIKit

class PerPersonViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var numberOfPeopleField: UITextField!
    @IBOutlet weak var SharedCostField: UITextField!
    @IBOutlet weak var peopleTable: UITableView!
    
    // State
    var billSubAmount:Double = 100.0 // From Tipper view controller
    var taxRate:Double = 0.1 // From Tipper view controller
    var isTaxIncluded = true // From Tipper view controller
    var tipPercentage:Double = 0.1 // From Tipper view controller
    var numberOfPeople = 1
    var sharedCost:Double = 0.0
    var peopleSubAmounts:[Double] = [0.0]
    
    // MARK: - ViewController Methods

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Event Callbacks
    
    @IBAction func onNumberOfPeopleValueChanged(sender: AnyObject) {
        
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
            peopleTable.reloadData()
        }
        
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
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
        if let textLabel = cell.textLabel{
            textLabel.text = String(format: "Person %d pays ", indexPath.row + 1);
        }
        let personTotalAmount = calculateAmountsForPerson(peopleSubAmounts[indexPath.row]).personTotalAmount
        if let detailTextLabel = cell.detailTextLabel{
            detailTextLabel.text = String(format: "$%.2f", personTotalAmount);
        }
        
        return cell
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Helper Methods
    
    // Given new number of people, reset the subamounts per person to be evenly divided
    func resetPeopleSubAmounts(numberOfPeople: Int, billSubAmount: Double, sharedCost: Double) {
        
        // Re-instantiate array with new sub amount values per person
        let personSubAmount = (billSubAmount - sharedCost)/Double(numberOfPeople)
        peopleSubAmounts = Array<Double>(count:numberOfPeople, repeatedValue: personSubAmount)
        
    }
    
    // Given sub amount and other inputs, calculate tip, tax, shared-cost, and total amount
    // payed by one person
    func calculateAmountsForPerson (personSubAmount:Double)
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
        
    }
    
    

}
