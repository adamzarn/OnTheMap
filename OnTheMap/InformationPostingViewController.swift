//
//  InformationPostingViewController.swift
//  OnTheMap
//
//  Created by Adam Zarn on 7/19/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import UIKit
import MapKit

class InformationPostingViewController: UIViewController, MKMapViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var bottomButton: UIButton!
    @IBOutlet weak var myMapView: MKMapView!
    @IBOutlet weak var locationTextField: UITextField!
    
    var lat: Double?
    var long: Double?
    
    @IBAction func bottomButtonPressed(sender: AnyObject) {
        if bottomButton.titleLabel!.text == "Find on the Map" {
            myMapView.hidden = false
            locationTextField.enabled = false
            locationTextField.hidden = true
            linkTextField.hidden = false
            linkTextField.text = "Enter a Link to Share Here"
            topLabel.hidden = true
            bottomButton.setTitle("Submit", forState: .Normal)
            self.geocode(locationTextField.text!)
        }
    }
    
    func setUpMapView() {

        var annotations = [MKPointAnnotation]()
        let coordinate = CLLocationCoordinate2D(latitude: self.lat!, longitude: self.long!)
        
        myMapView.setRegion(MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)), animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = locationTextField.text!
        annotation.subtitle = ""
        
        annotations.append(annotation)

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationTextField.delegate = self
        locationTextField.text = "Enter Your Location Here"
        myMapView.hidden = true
        linkTextField.hidden = true
        bottomButton.setTitle("Find on the Map", forState: .Normal)
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.becomeFirstResponder()
        if textField.text == "Enter Your Location Here" || textField.text == "Enter a Link to Share Here" {
            textField.text = ""
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {

    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    func geocode(address: String) {
        CLGeocoder().geocodeAddressString(address, completionHandler: { (placemarks, error) in
            if error != nil {
                print(error)
                return
            }
            if placemarks?.count > 0 {
                let placemark = placemarks?[0]
                let location = placemark?.location
                let coordinate = location?.coordinate
                self.lat = coordinate?.latitude
                self.long = coordinate?.longitude
                self.setUpMapView()
                if placemark?.areasOfInterest?.count > 0 {
                    let areaOfInterest = placemark!.areasOfInterest![0]
                    print(areaOfInterest)
                } else {
                    print("No area of interest found.")
                }
            }
        })
    }


}

