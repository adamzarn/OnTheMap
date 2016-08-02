//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Adam Zarn on 7/20/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import UIKit

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var myTableView: UITableView!
    
    let unableToLogoutAlert:UIAlertController = UIAlertController(title: "Unable to Logout", message: "You are unable to logout at this time.",preferredStyle: UIAlertControllerStyle.Alert)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.unableToLogoutAlert.addAction(UIAlertAction(title:"OK",style: UIAlertActionStyle.Default, handler: nil))
        NetworkClient.sharedInstance().getLocationData(nil,vc2:self)

    }
    
    override func viewWillAppear(animated: Bool) {
        NetworkClient.sharedInstance().getLocationData(nil,vc2:self)
    }
    
    @IBAction func refreshData(sender: AnyObject) {
        NetworkClient.sharedInstance().getLocationData(nil,vc2:self)
        print("Data refreshed")
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return StudentInformation.studentInformationArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell: MyTableCell = tableView.dequeueReusableCellWithIdentifier("Cell") as! MyTableCell
        let currentStudent = StudentInformation.studentInformationArray[indexPath.row]
        
        let first = currentStudent.firstName as! String
        let last = currentStudent.lastName as! String
        
        if StudentInformation.studentInformationArray.count == 0 {
            return cell
        } else {
            cell.setCell(first + " " + last)
        }
            
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let currentStudent = StudentInformation.studentInformationArray[indexPath.row]
        
        let app = UIApplication.sharedApplication()
        if let toOpen = currentStudent.mediaURL {
            if URLVerified(toOpen as? String) {
                app.openURL(NSURL(string: toOpen as! String)!)
            } else {
                self.myTableView.reloadData()
            }
        }
    }
    
    func URLVerified(urlString: String?) -> Bool {
        if let url = NSURL(string: urlString!) {
            if UIApplication.sharedApplication().canOpenURL(url) {
                return true
            } else {
                return false
            }
        }
        return false
    }
    
    @IBAction func logoutPressed() {
        NetworkClient.sharedInstance().logout(nil,vc2: self)
    }
}
