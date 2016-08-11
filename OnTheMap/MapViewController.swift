//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Adam Zarn on 7/20/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import UIKit
import MapKit
import FBSDKLoginKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var myMapView: MKMapView!
    
    let alreadyPostedAlert:UIAlertController = UIAlertController(title: "Location Already Exists", message: "A location for you already exists, what would you like to do?",preferredStyle: UIAlertControllerStyle.Alert)
    let unableToLogoutAlert:UIAlertController = UIAlertController(title: "Unable to Logout", message: "You are unable to logout at this time.",preferredStyle: UIAlertControllerStyle.Alert)
    let downloadFailedAlert:UIAlertController = UIAlertController(title: "Download Failed", message: "The download failed, please try again later.",preferredStyle: UIAlertControllerStyle.Alert)
    let invalidURLAlert:UIAlertController = UIAlertController(title: "Invalid URL", message: "The URL that was provided is invalid.",preferredStyle: UIAlertControllerStyle.Alert)

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.getLocationData()
        
        alreadyPostedAlert.addAction(UIAlertAction(title:"Overwrite", style: UIAlertActionStyle.Default, handler: {(alert: UIAlertAction!) in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let nextController = storyboard.instantiateViewControllerWithIdentifier("InformationPostingViewController") as! InformationPostingViewController
            self.presentViewController(nextController, animated: true, completion: nil)
        }))
        alreadyPostedAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
        
        unableToLogoutAlert.addAction(UIAlertAction(title:"OK",style: UIAlertActionStyle.Default, handler: nil))
        downloadFailedAlert.addAction(UIAlertAction(title:"OK",style: UIAlertActionStyle.Default, handler: nil))
        invalidURLAlert.addAction(UIAlertAction(title:"OK",style: UIAlertActionStyle.Default, handler: nil))
        
    }
    
    func getLocationData() {
        ParseClient.sharedInstance().getLocationData { (result, error) -> () in
            if let result = result {
                self.setUpMapView()
            } else {
                print(error)
                self.presentViewController(self.downloadFailedAlert, animated: true, completion: nil)
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        self.getLocationData()
    }
    
    @IBAction func refreshData(sender: AnyObject) {
        self.getLocationData()
    }
    
    @IBAction func startPost(sender: AnyObject) {
        ParseClient.sharedInstance().doesStudentLocationExist { (objectID, error) -> () in
            if let objectID = objectID {
                if objectID == "" {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let nextController = storyboard.instantiateViewControllerWithIdentifier("InformationPostingViewController") as! InformationPostingViewController
                    self.presentViewController(nextController, animated: true, completion: nil)
                } else {
                    CurrentUser.objectID = objectID
                    self.presentViewController(self.alreadyPostedAlert, animated: true, completion: nil)
                }
            } else {
                print(error)
            }
        }
    }
    
    func setUpMapView() {
    
        let allAnnotations = self.myMapView.annotations
        self.myMapView.removeAnnotations(allAnnotations)
        
        let locations = StudentInformation.studentInformationArray
    
        var annotations = [MKPointAnnotation]()
    
        for studentInfo in locations {
            if let latitude = studentInfo.latitude, longitude = studentInfo.longitude {
                let lat = CLLocationDegrees(latitude as! Double)
                let long = CLLocationDegrees(longitude as! Double)
    
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
        }
        self.myMapView.addAnnotations(annotations)
    }

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
    
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .redColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        } else {
            pinView!.annotation = annotation
        }
        return pinView

    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            if let toOpen = view.annotation?.subtitle! {
                
                isSuccess(URLVerified(toOpen), success: { () -> Void in
                    app.openURL(NSURL(string: toOpen)!)
                }, error: { () -> Void in
                    self.presentViewController(self.invalidURLAlert, animated: true, completion: nil)
                })

            } else {
                self.presentViewController(self.invalidURLAlert, animated: true, completion: nil)
            }
        }
    }
    
    func isSuccess(val:Bool, success: () -> Void, error: () -> Void) {
        if val {
            success()
        } else {
            error()
        }
    }
    
    func URLVerified(urlString: String?) -> Bool {
        if let url = NSURL(string: urlString!) {
            if UIApplication.sharedApplication().canOpenURL(url) {
                return true
            } else {
                return false
            }
        }
        return false
    }
    
    @IBAction func logoutPressed() {
        
        if CurrentUser.facebookToken != nil {
            let loginManager = FBSDKLoginManager()
            loginManager.logOut()
        }
        
        UdacityClient.sharedInstance().logout { (result, error) -> () in
            if let result = result {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let nextController = storyboard.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
                self.presentViewController(nextController, animated: true, completion: nil)
            } else {
                print(error)
                self.dismissViewControllerAnimated(false, completion: nil)
                self.presentViewController(self.unableToLogoutAlert, animated: true, completion: nil)
            }
        }
    }
    
}

