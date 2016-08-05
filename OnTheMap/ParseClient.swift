//
//  ParseClient.swift
//  OnTheMap
//
//  Created by Adam Zarn on 8/4/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import UIKit

class ParseClient: NSObject {
    
    func getLocationData(completion: (result: [StudentInformation]?, error: NSError?) -> Void) -> NSURLSessionDataTask {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://parse.udacity.com/parse/classes/StudentLocation?limit=100")!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            func sendError(error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completion(result: nil, error: NSError(domain: "getLocationData", code: 1, userInfo: userInfo))
            }
            
            guard (error == nil) else {
                sendError("There was an error with your request: \(error)")
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
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
                    completion(result: StudentInformation.studentInformationArray, error: nil)
                }
            }
        }
        task.resume()
        return task
    }
    
    func postLocation(methodType: String, location: String, link: String, lat: String, long: String, completion: (result: [String:AnyObject]?, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
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

            func sendError(error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completion(result: nil, error: NSError(domain: "postLocation", code: 1, userInfo: userInfo))
            }
            
            guard (error == nil) else {
                sendError("There was an error with your request: \(error)")
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            var parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                print("error")
                return
            }
            if let postRequest = parsedResult as? [String:AnyObject] {
                performUIUpdatesOnMain {
                    completion(result: postRequest, error: nil)
                }
            }
        }
        task.resume()
        return task
    }
    
    func doesStudentLocationExist(completion: (objectID: String?, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        let urlQueryString = "https://parse.udacity.com/parse/classes/StudentLocation?where=%7B%22uniqueKey%22%3A%22\(CurrentUser.userID)%22%7D"
        
        let url = NSURL(string: urlQueryString)
        let request = NSMutableURLRequest(URL: url!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            func sendError(error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completion(objectID: nil, error: NSError(domain: "doesStudentLocationExist", code: 1, userInfo: userInfo))
            }
            
            guard (error == nil) else {
                sendError("There was an error with your request: \(error)")
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }

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
                        completion(objectID: objectID as? String, error: nil)
                    } else {
                        completion(objectID: "", error: nil)
                    }
                }
            }
        }
        task.resume()
        return task
    }
    
    class func sharedInstance() -> ParseClient {
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        return Singleton.sharedInstance
    }

}
