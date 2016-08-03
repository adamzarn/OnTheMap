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
        NetworkClient.sharedInstance().getLocationData { (result) -> () in
            self.setUpMapView()
        }
    }
    
    @IBAction func queryStudent(sender: AnyObject) {
        NetworkClient.sharedInstance().doesStudentLocationExist()
    }
    
    override func viewWillAppear(animated: Bool) {
        NetworkClient.sharedInstance().getLocationData { (result) -> () in
            self.setUpMapView()
        }
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

