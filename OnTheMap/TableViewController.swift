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
    
    var studentLocationsDictionary: [[String:AnyObject]] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getLocationData()

    }
    
    func viewWillAppear() {
        getLocationData()
    }
    
    @IBAction func refreshData(sender: AnyObject) {
        getLocationData()
        print("Data refreshed")
    }

    func getLocationData() {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation?limit=100")!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            if error != nil {
                return
            } else {
                if let data = data {
                    var parsedResult: AnyObject!
                    do {
                        parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
                    } catch {
                        print("error")
                        return
                    }
                    if let locationsDictionary = parsedResult as? [String:AnyObject], locationsArray = locationsDictionary["results"] as? [[String:AnyObject]] {
                        performUIUpdatesOnMain {
                            self.studentLocationsDictionary = locationsArray
                            self.myTableView.reloadData()
                        }
                    }
                }
            }
        }
        task.resume()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return studentLocationsDictionary.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell: MyTableCell = tableView.dequeueReusableCellWithIdentifier("Cell") as! MyTableCell
        let currentStudent = studentLocationsDictionary[indexPath.row]
        
        if studentLocationsDictionary.count == 0 {
            return cell
        } else {
            cell.setCell(String(currentStudent["firstName"]!) + " " + String(currentStudent["lastName"]!))
        }
            
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell: MyTableCell = tableView.dequeueReusableCellWithIdentifier("Cell") as! MyTableCell
        let currentStudent = studentLocationsDictionary[indexPath.row]
        
        let app = UIApplication.sharedApplication()
        if let toOpen = studentLocationsDictionary[indexPath.row]["mediaURL"] {
            print(URLVerified(toOpen as? String))
            if URLVerified(toOpen as? String) {
                app.openURL(NSURL(string: toOpen as! String)!)
            } else {
                cell.setCell(String(currentStudent["firstName"]!) + " " + String(currentStudent["lastName"]!) + " (Invalid URL Provided)")
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
}
