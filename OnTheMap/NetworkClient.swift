//
//  NetworkClient.swift
//  OnTheMap
//
//  Created by Adam Zarn on 7/19/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//


import UIKit

class NetworkClient: NSObject {
    
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
    
    func getLocationData(completion: (result: [StudentInformation]?) -> ()) {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://parse.udacity.com/parse/classes/StudentLocation?limit=100")!)
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
                            StudentInformation.studentInformationArray = []
                            for student in locationsArray {
                                StudentInformation.studentInformationArray.append(StudentInformation(sourceData: student))
                            }
                            completion(result: StudentInformation.studentInformationArray)
                        }
                    }
                }
            }
        }
        task.resume()
    }
    
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
    
    func postLocation(method: String, methodType: String, location:String,link:String,lat:String,long:String) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://parse.udacity.com/parse/classes/\(method)")!)
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
    
    func doesStudentLocationExist(completion: (objectID: String?) -> ()) {
        
        var search = [String: String]()
        let searchText = "\(CurrentUser.userID!)"
        
        search = ["uniqueKey":searchText]
        
        var jsonifyError:NSError? = nil
        
        let data: NSData?
        do {
            data = try NSJSONSerialization.dataWithJSONObject(search, options: [])
        } catch let error as NSError {
            jsonifyError = error
            data = nil
        }
        
        let parameters:[String:AnyObject] = ["where":NSString(data: data!, encoding: NSUTF8StringEncoding)!]
        
        let urlQueryString = "https://parse.udacity.com/parse/classes/StudentLocation?where=%7B%22uniqueKey%22%3A%226669529102%22%7D"
        
        let url = NSURL(string: urlQueryString)
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
                    if let lastLocation = parsedResult as? [String:AnyObject], lastLocationResults = lastLocation["results"] as? [[String:AnyObject]] {
                        performUIUpdatesOnMain {
                            var dictionaryToUpdate: [String:AnyObject]?
                            for dictionary in lastLocationResults {
                                if String(dictionary["firstName"]!) == String(CurrentUser.firstName) && String(dictionary["lastName"]!) == String(CurrentUser.lastName) {
                                        dictionaryToUpdate = dictionary
                                }
                            }
                            if let objectID = dictionaryToUpdate!["objectId"] {
                                CurrentUser.objectID = String(objectID)
                            } else {
                                CurrentUser.objectID = ""
                            }
                            completion(objectID: CurrentUser.objectID)
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
    
    class func sharedInstance() -> NetworkClient {
        struct Singleton {
            static var sharedInstance = NetworkClient()
        }
        return Singleton.sharedInstance
    }

    
    
}
