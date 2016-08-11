//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Adam Zarn on 7/20/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var myTableView: UITableView!
    
    let alreadyPostedAlert:UIAlertController = UIAlertController(title: "Location Already Exists", message: "A location for you already exists, what would you like to do?",preferredStyle: UIAlertControllerStyle.Alert)
    let unableToLogoutAlert:UIAlertController = UIAlertController(title: "Unable to Logout", message: "You are unable to logout at this time.",preferredStyle: UIAlertControllerStyle.Alert)
    let downloadFailedAlert:UIAlertController = UIAlertController(title: "Download Failed", message: "The download failed, please try again later.",preferredStyle: UIAlertControllerStyle.Alert)
    let invalidURLAlert:UIAlertController = UIAlertController(title: "Invalid URL", message: "The URL that was provided is invalid.",preferredStyle: UIAlertControllerStyle.Alert)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.getLocationData()
        
        alreadyPostedAlert.addAction(UIAlertAction(title:"Overwrite", style: UIAlertActionStyle.Default, handler: {(alert: UIAlertAction!) in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let nextController = storyboard.instantiateViewControllerWithIdentifier("InformationPostingViewController") as! InformationPostingViewController
            self.presentViewController(nextController, animated: true, completion: nil)
        }))
        unableToLogoutAlert.addAction(UIAlertAction(title:"OK",style: UIAlertActionStyle.Default, handler: nil))
        downloadFailedAlert.addAction(UIAlertAction(title:"OK",style: UIAlertActionStyle.Default, handler: nil))
        alreadyPostedAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
        invalidURLAlert.addAction(UIAlertAction(title:"OK",style: UIAlertActionStyle.Default, handler: nil))
        
    }
    
    func getLocationData() {
        ParseClient.sharedInstance().getLocationData { (result, error) -> () in
            if let result = result {
                self.myTableView.reloadData()
            } else {
            print(error)
            self.presentViewController(self.downloadFailedAlert, animated: true, completion: nil)
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        self.getLocationData()
    }
    
    @IBAction func refreshData(sender: AnyObject) {
        self.getLocationData()
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
        
        if let first = currentStudent.firstName, last = currentStudent.lastName, place = currentStudent.mapString {
            let first = first as! String
            let last = last as! String
            let place = place as! String
            let startPlace = first.characters.count + last.characters.count + 2
            let lengthPlace = place.characters.count
        
            rowText = NSMutableAttributedString(string: first + " " + last + " " + place)
            rowText.addAttribute(NSFontAttributeName, value: UIFont(name:"Georgia",size:10.0)!,range: NSRange(location: startPlace,length: lengthPlace))
            
        }
        
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
        if let toOpen = currentStudent.mediaURL as? String {
            
            isSuccess(URLVerified(toOpen), success: { () -> Void in
                app.openURL(NSURL(string: toOpen)!)
                }, error: { () -> Void in
                    self.presentViewController(self.invalidURLAlert, animated: true, completion: nil)
                })
            
        } else {
            self.presentViewController(self.invalidURLAlert, animated: true, completion: nil)
        }
    }

    func isSuccess(val:Bool, success: () -> Void, error: () -> Void) {
        if val {
            success()
        } else {
            error()
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
        
        if CurrentUser.facebookToken != nil {
            let loginManager = FBSDKLoginManager()
            loginManager.logOut()
        }
        
        UdacityClient.sharedInstance().logout { (result, error) -> () in
            if let result = result {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let nextController = storyboard.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
                self.presentViewController(nextController, animated: true, completion: nil)
            } else {
                print(error)
                self.dismissViewControllerAnimated(false, completion: nil)
                self.presentViewController(self.unableToLogoutAlert, animated: true, completion: nil)
            }
        }
    }

}

