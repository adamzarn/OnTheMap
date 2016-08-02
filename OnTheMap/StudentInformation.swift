//
//  StudentInformation.swift
//  OnTheMap
//
//  Created by Adam Zarn on 8/1/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import UIKit

struct StudentInformation {
    
    var createdAt: AnyObject?
    var firstName: AnyObject?
    var lastName: AnyObject?
    var latitude: AnyObject?
    var longitude: AnyObject?
    var mapString: AnyObject?
    var mediaURL: AnyObject?
    var objectID: AnyObject?
    var uniqueKey: AnyObject?
    var updatedAt: AnyObject?
    
    init(sourceData: NSDictionary) {
        self.createdAt = sourceData["createdAt"]
        self.firstName = sourceData["firstName"]
        self.lastName = sourceData["lastName"]
        self.latitude = sourceData["latitude"]
        self.longitude = sourceData["longitude"]
        self.mapString = sourceData["mapString"]
        self.mediaURL = sourceData["mediaURL"]
        self.objectID = sourceData["objectID"]
        self.uniqueKey = sourceData["uniqueKey"]
        self.updatedAt = sourceData["updatedAt"]
    }
    
    static var studentInformationArray = [StudentInformation]()

}
