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
    
    let alreadyPostedAlert:UIAlertController = UIAlertController(title: "Location Already Exists", message: "A location for you already exists, what would you like to do?",preferredStyle: UIAlertControllerStyle.Alert)
    
    let unableToLogoutAlert:UIAlertController = UIAlertController(title: "Unable to Logout", message: "You are unable to logout at this time.",preferredStyle: UIAlertControllerStyle.Alert)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.unableToLogoutAlert.addAction(UIAlertAction(title:"OK",style: UIAlertActionStyle.Default, handler: nil))
        ParseClient.sharedInstance().getLocationData { (result) -> () in
            self.myTableView.reloadData()
        }
        
        alreadyPostedAlert.addAction(UIAlertAction(title:"Overwrite",
            style: UIAlertActionStyle.Default,
            handler: {(alert: UIAlertAction!) in
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let nextController = storyboard.instantiateViewControllerWithIdentifier("InformationPostingViewController") as! InformationPostingViewController
                self.presentViewController(nextController, animated: true, completion: nil)
        })
        )
        
        alreadyPostedAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
    }
    
    override func viewWillAppear(animated: Bool) {
        ParseClient.sharedInstance().getLocationData { (result) -> () in
            self.myTableView.reloadData()
        }
    }
    
    @IBAction func refreshData(sender: AnyObject) {
        ParseClient.sharedInstance().getLocationData { (result) -> () in
            self.myTableView.reloadData()
        }

    }
    
    @IBAction func startPost(sender: AnyObject) {
        ParseClient.sharedInstance().doesStudentLocationExist { (objectID, error) -> () in
            if let objectID = objectID {
                if objectID == "" {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let nextController = storyboard.instantiateViewControllerWithIdentifier("InformationPostingViewController") as! InformationPostingViewController
                    self.presentViewController(nextController, animated: true, completion: nil)
                } else {
                    CurrentUser.objectID = objectID
                    self.presentViewController(self.alreadyPostedAlert, animated: true, completion: nil)
                }
            } else {
                print(error)
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentInformation.studentInformationArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell: MyTableCell = tableView.dequeueReusableCellWithIdentifier("Cell") as! MyTableCell
        let currentStudent = StudentInformation.studentInformationArray[indexPath.row]
        
        var rowText = NSMutableAttributedString()
        
        let first = currentStudent.firstName as! String
        let last = currentStudent.lastName as! String
        let place = currentStudent.mapString as! String
        let startPlace = first.characters.count + last.characters.count + 2
        let lengthPlace = place.characters.count
        
        rowText = NSMutableAttributedString(string:first + " " + last + " " + place)
        rowText.addAttribute(NSFontAttributeName,
                             value: UIFont(name:"Georgia",
                size:10.0)!,
                range: NSRange(location: startPlace,length: lengthPlace)
        )
        
        if StudentInformation.studentInformationArray.count == 0 {
            return cell
        } else {
            cell.setCell(rowText)
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
        UdacityClient.sharedInstance().logout { (result, error) -> () in
            if let result = result {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let nextController = storyboard.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
                self.presentViewController(nextController, animated: true, completion: nil)
            } else {
                print(error)
                self.presentViewController(self.unableToLogoutAlert, animated: true, completion: nil)
            }
        }
    }
    
}
