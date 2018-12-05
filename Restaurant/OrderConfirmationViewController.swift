//
//  OrderConfirmationViewController.swift
//  Restaurant
//
//  Created by Wessel Mel on 05/12/2018.
//

import UIKit

class OrderConfirmationViewController: UIViewController {
    
    @IBOutlet weak var timeRemainingLable: UILabel!
    var minutes: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        timeRemainingLable.text = "Thank you for your order! Your wait time is approximately \(minutes!) minutes"
    }
}
