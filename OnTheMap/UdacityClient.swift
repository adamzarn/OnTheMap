//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Adam Zarn on 7/19/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//


import UIKit

class UdacityClient: NSObject {
    
    func login(email: String, password: String, completion: (result: [String:AnyObject]?) -> ()) {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(email)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            let newData = data?.subdataWithRange(NSMakeRange(5, data!.length-5))
            
            if error != nil {
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
                    if let sessionRequest = parsedResult as? [String:AnyObject] {
                        performUIUpdatesOnMain {
                            completion(result: sessionRequest)
                        }
                    }
                }
            }
        }
        task.resume()
    }

    func getUserData() {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/users/\(CurrentUser.userID!)")!)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
        
            let newData = data?.subdataWithRange(NSMakeRange(5, data!.length-5))
        
            if error != nil {
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
                    if let allUserInfo = parsedResult as? [String:AnyObject], userInfo = allUserInfo["user"] as? [String:AnyObject] {
                        performUIUpdatesOnMain {
                            CurrentUser.firstName = String(userInfo["first_name"]!)
                            CurrentUser.lastName = String(userInfo["last_name"]!)
                        }
                    }
                }
            }
        }
        task.resume()
    }

    func logout(completion: (result: [String:AnyObject]?) -> ()) {
        
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
                            completion(result: sessionLogout)
                        }
                    }
                }
            }
        }
        task.resume()
    }
    
        
    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        return Singleton.sharedInstance
    }

    
    
}
