//
//  OrderTableViewController.swift
//  Restaurant
//
//  Created by Wessel Mel on 04/12/2018.
//

import UIKit

class OrderTableViewController: UITableViewController {
    
     var orderMinutes = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = editButtonItem
        
        NotificationCenter.default.addObserver(tableView, selector: #selector(UITableView.reloadData), name: MenuController.orderUpdatedNotification, object: nil)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MenuController.shared.order.menuItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderCellIdentifier", for: indexPath)
        configure(cell, forItemAt: indexPath)
        return cell
    }
    
    func configure(_ cell: UITableViewCell, forItemAt indexPath: IndexPath) {
        let menuItem = MenuController.shared.order.menuItems[indexPath.row]
        cell.textLabel?.text = menuItem.name
        cell.detailTextLabel?.text = String(format: "$%.2f", menuItem.price)
        MenuController.shared.fetchImage(url: menuItem.imageURL)
        { (image) in
            guard let image = image else { return }
            DispatchQueue.main.async {
                if let currentIndexPath = self.tableView.indexPath(for: cell), currentIndexPath != indexPath {
                    return
                }
                cell.imageView?.image = image
                cell.setNeedsLayout()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            MenuController.shared.order.menuItems.remove(at: indexPath.row)
        }
    }
    
    @IBAction func submitTapped(_ sender: Any) {
        let orderTotal = MenuController.shared.order.menuItems.reduce(0.0) { (result, menuItem) -> Double in
            return result + menuItem.price
        }
        let formattedOrder = String(format: "$%.2f", orderTotal)
        
        let alert = UIAlertController(title: "Confirm Order", message: "You are about to submit your order with a total of \(formattedOrder)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Submit", style: .default) { action in self.uploadOrder() })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ConfirmationSegue" {
            let orderConfirmationViewController = segue.destination as! OrderConfirmationViewController
            orderConfirmationViewController.minutes = orderMinutes
        } else if segue.identifier == "OrderDetailSegue" {
            let menuItemDetailViewController = segue.destination as! MenuItemDetailViewController
            let index = tableView.indexPathForSelectedRow!.row
            let id = MenuController.shared.order.menuItems[index].id
            menuItemDetailViewController.menuItem = MenuController.shared.item(withID: id)
            menuItemDetailViewController.orderOrNot = 1
        }
        
    }
    
    @IBAction func unwindToOrderList(segue: UIStoryboardSegue){
        if segue.identifier == "DismissConfirmation" {
            MenuController.shared.order.menuItems.removeAll()
        }
    }

    func uploadOrder()
    {
        let menuIds = MenuController.shared.order.menuItems.map
        { $0.id }
        MenuController.shared.submitOrder(forMenuIDs: menuIds)
        { (minutes) in
            DispatchQueue.main.async
                {
                    if let minutes = minutes
                    {
                        self.orderMinutes = minutes
                        self.performSegue(withIdentifier:
                            "ConfirmationSegue", sender: nil)
                    }
            }
        }
    }
}
