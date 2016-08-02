//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Adam Zarn on 7/20/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var myMapView: MKMapView!
    
    let unableToLogoutAlert:UIAlertController = UIAlertController(title: "Unable to Logout", message: "You are unable to logout at this time.",preferredStyle: UIAlertControllerStyle.Alert)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.unableToLogoutAlert.addAction(UIAlertAction(title:"OK",style: UIAlertActionStyle.Default, handler: nil))
        NetworkClient.sharedInstance().getLocationData(self,vc2:nil)
    }
    
    func encodeParameters(params: [String: String]) -> String {
        let queryItems = params.map() { NSURLQueryItem(name:$0, value:$1)}
        let components = NSURLComponents()
        components.queryItems = queryItems
        return components.percentEncodedQuery ?? ""
    }
    
    @IBAction func addLocation(sender: AnyObject) {
        
        let parameter = [
            "where" : "{\"uniqueKey\":\"\(CurrentUser.userID!)\"}"
        ]
        let urlQueryString = "https://api.parse.com/1/classes/StudentLocation?" + encodeParameters(parameter)

        print(urlQueryString)
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
                    if let lastLocation = parsedResult as? [String:AnyObject], lastLocationResults = lastLocation["results"] as? [String:AnyObject] {
                        performUIUpdatesOnMain {
                            print(lastLocationResults["objectId"])
                            let nextController = self.storyboard?.instantiateViewControllerWithIdentifier("InformationPostingViewController") as! InformationPostingViewController
                            self.presentViewController(nextController,animated:true,completion:nil)
                        }
                    }
                }
            }
        }
        task.resume()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        NetworkClient.sharedInstance().getLocationData(self,vc2:nil)
    }
    
    func setUpMapView() {
    
        let locations = StudentInformation.studentInformationArray
    
        var annotations = [MKPointAnnotation]()
    
        for studentInfo in locations {
    
        let lat = CLLocationDegrees(studentInfo.latitude as! Double)
        let long = CLLocationDegrees(studentInfo.longitude as! Double)
    
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
    
        let first = studentInfo.firstName as! String
        let last = studentInfo.lastName as! String
        let mediaURL = studentInfo.mediaURL as! String
    
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "\(first) \(last)"
        annotation.subtitle = mediaURL
    
        annotations.append(annotation)
        }

        self.myMapView.addAnnotations(annotations)

}

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinColor = .Red
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            if let toOpen = view.annotation?.subtitle! {
                app.openURL(NSURL(string: toOpen)!)
            }
        }
    }
    
    @IBAction func logoutPressed() {
        NetworkClient.sharedInstance().logout(self,vc2: nil)
    }
    
    
}

