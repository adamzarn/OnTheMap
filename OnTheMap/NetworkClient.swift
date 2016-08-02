//
//  NetworkClient.swift
//  OnTheMap
//
//  Created by Adam Zarn on 7/19/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//


import UIKit

class NetworkClient: NSObject {
    
    func logout(vc1: MapViewController?, vc2: TableViewController?) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            let newData = data?.subdataWithRange(NSMakeRange(5, data!.length-5))
            
            if error != nil {
                if let vc1 = vc1 {
                    vc1.presentViewController(vc1.unableToLogoutAlert, animated: true, completion: nil)
                } else {
                    vc2!.presentViewController(vc2!.unableToLogoutAlert, animated: true, completion: nil)
                }
                return
            } else {
                if let newData = newData {
                    var parsedResult: AnyObject!
                    do {
                        parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)
                    } catch {
                        print("error")
                        return
                    }
                    if let sessionLogout = parsedResult as? [String:AnyObject] {
                        performUIUpdatesOnMain {
                            if let session = sessionLogout["session"] {
                                print(session)
                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                let nextController = storyboard.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
                                if let vc1 = vc1 {
                                    vc1.presentViewController(nextController, animated: true, completion: nil)
                                } else {
                                    vc2!.presentViewController(nextController, animated: true, completion: nil)
                                }
                            } else {
                                if let vc1 = vc1 {
                                    vc1.presentViewController(vc1.unableToLogoutAlert, animated: true, completion: nil)
                                } else {
                                    vc2!.presentViewController(vc2!.unableToLogoutAlert, animated: true, completion: nil)
                                }
                            }
                        }
                    }
                }
            }
        }
        task.resume()
    }
    
    func getLocationData(vc1: MapViewController?, vc2: TableViewController?) {
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
                            for student in locationsArray {
                                StudentInformation.studentInformationArray.append(StudentInformation(sourceData: student))
                            }
                            if let vc1 = vc1 {
                                vc1.setUpMapView()
                            } else {
                                vc2!.myTableView.reloadData()
                            }
                        }
                    }
                }
            }
        }
        task.resume()
    }
    
    func postLocation(method: String, methodType: String, location:String,link:String,lat:String,long:String) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/\(method)")!)
        request.HTTPMethod = methodType
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"uniqueKey\": \"\(CurrentUser.userID)\", \"firstName\": \"\(CurrentUser.firstName)\", \"lastName\": \"\(CurrentUser.lastName)\",\"mapString\": \"\(location)\", \"mediaURL\": \"\(link))\",\"latitude\": \(lat), \"longitude\": \(long)}".dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                return
            }
            print(NSString(data: data!, encoding: NSUTF8StringEncoding))
        }
        
        task.resume()
        
    }
    
    func doesStudentLocationExist() {
    
        let urlString = "https://api.parse.com/1/classes/StudentLocation?where=%7B%22uniqueKey%22%3A%22\(CurrentUser.userID)%22%7D"
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(URL: url!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
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
                    if let lastLocation = parsedResult as? [String:AnyObject], lastLocationResults = lastLocation["results"] as? [String:AnyObject] {
                        performUIUpdatesOnMain {
                            print(lastLocationResults["objectId"])
                        }
                    }
                }
            }
        }
    task.resume()
    }
    
    class func sharedInstance() -> NetworkClient {
        struct Singleton {
            static var sharedInstance = NetworkClient()
        }
        return Singleton.sharedInstance
    }

    
    
}
