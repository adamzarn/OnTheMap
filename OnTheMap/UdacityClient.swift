//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Adam Zarn on 7/19/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import Foundation

class UdacityClient: NSObject {
    
    func setUpParseRequest() {
    
    let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation?limit=100")!)
    request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
    request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
    let session = NSURLSession.sharedSession()

    }
}
