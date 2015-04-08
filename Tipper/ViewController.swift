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
    let taxRate = 0.1 //##todo Allow this to be changed in Settings.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tipValueLabel.text = "$0.00"
        totalValueLabel.text = "$0.00"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onEditingChanged(sender: AnyObject) {
        
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
    
    @IBAction func onTap(sender: AnyObject) {
        view.endEditing(true)
    }
    
}

