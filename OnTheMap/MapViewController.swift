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
    
    var studentLocationsDictionary: [[String:AnyObject]] = [[:]]
    
    @IBOutlet weak var myMapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getLocationData()

    }
    
    func viewWillAppear() {
        getLocationData()
    }
    
    func setUpMapView() {
    
        let locations = studentLocationsDictionary
    
        // We will create an MKPointAnnotation for each dictionary in "locations". The
        // point annotations will be stored in this array, and then provided to the map view.
        var annotations = [MKPointAnnotation]()
    
        // The "locations" array is loaded with the sample data below. We are using the dictionaries
        // to create map annotations. This would be more stylish if the dictionaries were being
        // used to create custom structs. Perhaps StudentLocation structs.
    
        for dictionary in locations {
    
        // Notice that the float values are being used to create CLLocationDegree values.
        // This is a version of the Double type.
        let lat = CLLocationDegrees(dictionary["latitude"] as! Double)
        let long = CLLocationDegrees(dictionary["longitude"] as! Double)
    
        // The lat and long are used to create a CLLocationCoordinates2D instance.
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
    
        let first = dictionary["firstName"] as! String
        let last = dictionary["lastName"] as! String
        let mediaURL = dictionary["mediaURL"] as! String
    
        // Here we create the annotation and set its coordiate, title, and subtitle properties
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "\(first) \(last)"
        annotation.subtitle = mediaURL
    
        // Finally we place the annotation in an array of annotations.
        annotations.append(annotation)
        }
    
        // When the array is complete, we add the annotations to the map.
        self.myMapView.addAnnotations(annotations)

}
    // MARK: - MKMapViewDelegate
    
    // Here we create a view with a "right callout accessory view". You might choose to look into other
    // decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
    // method in TableViewDataSource.
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
    
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            if let toOpen = view.annotation?.subtitle! {
                app.openURL(NSURL(string: toOpen)!)
            }
        }
    }
    
    //    func mapView(mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
    //
    //        if control == annotationView.rightCalloutAccessoryView {
    //            let app = UIApplication.sharedApplication()
    //            app.openURL(NSURL(string: annotationView.annotation.subtitle))
    //        }
    //    }
    
    // MARK: - Sample Data
    
    // Some sample data. This is a dictionary that is more or less similar to the
    // JSON data that you will download from Parse.
    
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
                            self.setUpMapView()
                        }
                    }
                }
            }
        }
        task.resume()
    }
    
}

