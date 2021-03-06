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
    @IBOutlet weak var middleLabel: UILabel!
    @IBOutlet weak var bottomLabel: UILabel!
    @IBOutlet weak var bottomButton: UIButton!
    @IBOutlet weak var myMapView: MKMapView!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var myView: UIView!
    @IBOutlet weak var startOver: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var mapLoadingIndicator: UIActivityIndicatorView!
    
    var lat: Double?
    var long: Double?
    
    let invalidAddressAlert:UIAlertController = UIAlertController(title: "Invalid Address", message: "Please enter a valid address.",preferredStyle: UIAlertControllerStyle.Alert)
    let invalidURLAlert:UIAlertController = UIAlertController(title: "Invalid URL", message: "You have entered an invalid URL, do you wish to continue?",preferredStyle: UIAlertControllerStyle.Alert)
    let noLocationAlert:UIAlertController = UIAlertController(title: "No Location Entered", message: "Please enter a location.",preferredStyle: UIAlertControllerStyle.Alert)
    let noLinkAlert:UIAlertController = UIAlertController(title: "No Link Entered", message: "Please enter a link.",preferredStyle: UIAlertControllerStyle.Alert)
    let unableToPostAlert:UIAlertController = UIAlertController(title: "Unable to post your location. Please check your connection or try again later.", message: "Please enter a link.",preferredStyle: UIAlertControllerStyle.Alert)
    let unableToUpdateAlert:UIAlertController = UIAlertController(title: "Unable to update your location.", message: "Please check your connection or try again later.",preferredStyle: UIAlertControllerStyle.Alert)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myView.backgroundColor = UIColor(red:0.3216,green:0.5333,blue:0.7137,alpha:1.0)
        
        topLabel.font = UIFont(name: "AppleSDGothicNeo-Light", size: 30.0)
        middleLabel.font = UIFont(name: "AppleSDGothicNeo-Light", size: 30.0)
        bottomLabel.font = UIFont(name: "AppleSDGothicNeo-Light", size: 30.0)
        
        self.locationTextField.delegate = self
        self.linkTextField.delegate = self
        locationTextField.autocorrectionType = .No
        linkTextField.autocorrectionType = .No
        
        invalidAddressAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        noLocationAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        noLinkAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        invalidURLAlert.addAction(UIAlertAction(title:"Continue", style: UIAlertActionStyle.Default, handler: {(alert: UIAlertAction!) in self.postLocation() }))
        invalidURLAlert.addAction(UIAlertAction(title:"Cancel",style: UIAlertActionStyle.Default, handler: nil))
        unableToPostAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {(alert: UIAlertAction!) in
            self.dismissViewControllerAnimated(false,completion:nil)
            }))
        unableToUpdateAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {(alert: UIAlertAction!) in
            self.dismissViewControllerAnimated(false,completion:nil)
        }))
        
        locationTextField.font = UIFont(name: "Roboto-Regular", size:24.0)
        linkTextField.font = UIFont(name: "Roboto-Regular", size:24.0)
        bottomButton.titleLabel!.font = UIFont(name: "Roboto-Regular", size:17)
        startOver.titleLabel!.font = UIFont(name: "Roboto-Regular", size:17)
        
        bottomButton.layer.cornerRadius = 5
        bottomButton.layer.borderWidth = 1
        bottomButton.layer.borderColor = UIColor.blackColor().CGColor
        
        startOver.setTitle("Start Over", forState: .Normal)
        startOver.backgroundColor = UIColor.whiteColor()
        startOver.setTitleColor(UIColor.blackColor(), forState: .Normal)
        startOver.layer.borderWidth = 1
        startOver.layer.cornerRadius = 5
        startOver.layer.borderColor = UIColor.blackColor().CGColor
        
        mapLoadingIndicator.hidden = true
        
        self.setUpView()
    }
    
    func postLocation() {
        if CurrentUser.objectID == "" {
            ParseClient.sharedInstance().postLocation("POST",location:self.locationTextField.text!,link:self.linkTextField.text!,lat:String(self.lat!),long:String(self.long!), completion: { (result, error) -> () in
                if let result = result {
                    CurrentUser.updatedAt = result["updatedAt"]
                    self.dismissViewControllerAnimated(false, completion: nil)
                } else {
                    print(error)
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        self.presentViewController(self.unableToPostAlert,animated:true,completion:nil)
                    }
                }
            })
        } else {
            ParseClient.sharedInstance().postLocation("PUT",location:self.locationTextField.text!,link:self.linkTextField.text!,lat:String(self.lat!),long:String(self.long!), completion: { (result, error) -> () in
                if let result = result {
                    CurrentUser.updatedAt = result["updatedAt"]
                        self.dismissViewControllerAnimated(false, completion: nil)
                } else {
                    print(error)
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        self.presentViewController(self.unableToUpdateAlert,animated:true,completion:nil)
                    }
                }
            })
        }
    }
    
    @IBAction func bottomButtonPressed(sender: AnyObject) {
        if bottomButton.titleLabel!.text == "Find on the Map" {
            if locationTextField.text == "Enter Your Location Here" {
                self.presentViewController(self.noLocationAlert, animated: true, completion: nil)
            } else {
            self.geocode(locationTextField.text!)
            }
        }
        if bottomButton.titleLabel!.text == "Submit" {
            if linkTextField.text == "Enter a Link to Share Here" {
                self.presentViewController(self.noLinkAlert, animated: true, completion: nil)
            } else {
            isSuccess(URLVerified(linkTextField.text!), success: { () -> Void in
                self.postLocation()
                }, error: { () -> Void in
                self.presentViewController(self.invalidURLAlert, animated: true, completion: nil)
                })
            }
        }
    }
    
    func moveToLinkEntry() {
        
        view.backgroundColor = UIColor(red:0.3216,green:0.5333,blue:0.7137,alpha:1.0)
        
        cancelButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        
        myView.hidden = true
        
        myMapView.hidden = false
        
        locationTextField.enabled = false
        locationTextField.hidden = true
        
        linkTextField.hidden = false
        linkTextField.enabled = true
        
        topLabel.hidden = true
        middleLabel.hidden = true
        bottomLabel.hidden = true
        
        bottomButton.setTitle("Submit", forState: .Normal)
        bottomButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        bottomButton.layer.borderWidth = 1
        bottomButton.layer.borderColor = UIColor.blackColor().CGColor
        
        
        startOver.enabled = true
        startOver.hidden = false
    }
    
    @IBAction func startOverPressed(sender: AnyObject) {
        self.setUpView()
    }
    
    func setUpView() {
        
        view.backgroundColor = UIColor(red:0.8784,green:0.8784,blue:0.8706,alpha:1.0)
        
        cancelButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        
        myView.hidden = false
        
        myMapView.hidden = true
        
        locationTextField.enabled = true
        locationTextField.hidden = false
        locationTextField.text = "Enter Your Location Here"
        
        linkTextField.enabled = false
        linkTextField.hidden = true
        linkTextField.text = "Enter a Link to Share Here"

        topLabel.hidden = false
        middleLabel.hidden = false
        bottomLabel.hidden = false
        
        bottomButton.setTitle("Find on the Map", forState: .Normal)
        bottomButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        bottomButton.backgroundColor = UIColor.whiteColor()
        
        startOver.enabled = false
        startOver.hidden = true
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
    
    func setUpMapView() {

        var annotations = [MKPointAnnotation]()
        let coordinate = CLLocationCoordinate2D(latitude: self.lat!, longitude: self.long!)
        
        myMapView.setRegion(MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)), animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = locationTextField.text!
        
        annotations.append(annotation)

        self.myMapView.addAnnotations(annotations)
        
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        //found how to add uneditable prefix to text field on StackOverflow from user Jeremy Pope: http://stackoverflow.com/questions/28434993/uneditable-prefix-inside-a-uitextfield-using-swift
        if textField == linkTextField {
            let protectedRange = NSMakeRange(0, 12)
            let intersection = NSIntersectionRange(protectedRange, range)
            if intersection.length > 0 {
                return false
            }
            return true
        }
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.becomeFirstResponder()
        if textField.text == "Enter Your Location Here" {
            textField.text = ""
        }
        if textField.text == "Enter a Link to Share Here" {
            let attributedString = NSMutableAttributedString(string: "https://www.")
            attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor(), range: NSMakeRange(0,12))
            linkTextField.attributedText = attributedString
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func geocode(address: String) {
        mapLoadingIndicator.hidden = false
        mapLoadingIndicator.startAnimating()
        CLGeocoder().geocodeAddressString(address, completionHandler: { (placemarks, error) in
            self.mapLoadingIndicator.stopAnimating()
            self.mapLoadingIndicator.hidden = true
            if error != nil {
                self.presentViewController(self.invalidAddressAlert, animated: true, completion: nil)
                return
            }
            if placemarks?.count > 0 {
                let placemark = placemarks?[0]
                let location = placemark?.location
                let coordinate = location?.coordinate
                
                self.lat = coordinate?.latitude
                self.long = coordinate?.longitude
                
                self.setUpMapView()
                self.moveToLinkEntry()
            }
        })
    }


}

