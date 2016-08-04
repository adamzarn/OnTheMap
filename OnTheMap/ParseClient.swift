//
//  ParseClient.swift
//  OnTheMap
//
//  Created by Adam Zarn on 8/4/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import UIKit

class ParseClient: NSObject {
    
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
    
    func postLocation(methodType:String,location:String,link:String,lat:String,long:String) {
        
        var method = ""
        if CurrentUser.objectID == "" {
            method = ""
        } else {
            method = "/\(CurrentUser.objectID)"
        }
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://parse.udacity.com/parse/classes/StudentLocation\(method)")!)
        request.HTTPMethod = methodType
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"uniqueKey\": \"\(CurrentUser.userID)\", \"firstName\": \"\(CurrentUser.firstName)\", \"lastName\": \"\(CurrentUser.lastName)\",\"mapString\": \"\(location)\", \"mediaURL\": \"\(link)\",\"latitude\": \(lat), \"longitude\": \(long)}".dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                return
            }
        }
        task.resume()
    }
    
    func doesStudentLocationExist(completion: (objectID: String?) -> ()) {
        
        let urlQueryString = "https://parse.udacity.com/parse/classes/StudentLocation?where=%7B%22uniqueKey%22%3A%22\(CurrentUser.userID)%22%7D"
        
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
    
    class func sharedInstance() -> ParseClient {
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        return Singleton.sharedInstance
    }

}
