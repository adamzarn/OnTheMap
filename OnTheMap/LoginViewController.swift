//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Adam Zarn on 7/18/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import UIKit
import MapKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var facebookLoginButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var signUpButton: UIButton!

    var accountNumber:String?
    var userInfo:[[String:AnyObject]]?
    
    @IBAction func signUpButtonPressed(sender: AnyObject) {
        if let url = NSURL(string: "https://www.udacity.com/account/auth#!/signup") {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    var credentials: [String:String] = [:]
    var sessionID: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.orangeColor()
        emailTextField.text = "Email"
        passwordTextField.text = "Password"
        loginButton.backgroundColor = UIColor(red: 0.9647, green: 0.3137, blue: 0.1255, alpha: 1.0)
        facebookLoginButton.backgroundColor = UIColor(red: 0.2313, green: 0.3490, blue: 0.5961, alpha: 1.0)
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        
        emailTextField.layer.cornerRadius = 5
        passwordTextField.layer.cornerRadius = 5
        loginButton.layer.cornerRadius = 5
        facebookLoginButton.layer.cornerRadius = 5
        
        loginLabel.font = UIFont(name: "Roboto-Regular", size:17)
        emailTextField.font = UIFont(name: "Roboto-Regular", size:17)
        passwordTextField.font = UIFont(name: "Roboto-Regular", size:17)
        loginButton.titleLabel!.font = UIFont(name: "Roboto-Regular", size:17)
        facebookLoginButton.titleLabel!.font = UIFont(name: "Roboto-Regular", size:17)
        signUpButton.titleLabel!.font = UIFont(name: "Roboto-Regular", size:17)
        
        let backgroundGradient = CAGradientLayer()
        let colorTop = UIColor(red: 1.0, green: 0.5803, blue: 0.1882, alpha: 1.0).CGColor
        let colorBottom = UIColor(red: 1.0, green: 0.4196, blue: 0.1216, alpha: 1.0).CGColor
        backgroundGradient.colors = [colorTop, colorBottom]
        backgroundGradient.locations = [0.0, 1.0]
        backgroundGradient.frame = view.frame
        view.layer.insertSublayer(backgroundGradient, atIndex: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginPressed(sender: AnyObject) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(emailTextField.text!)\", \"password\": \"\(passwordTextField.text!)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            let newData = data?.subdataWithRange(NSMakeRange(5, data!.length-5))
            let newDataString = NSString(data: newData!, encoding: NSUTF8StringEncoding)
            self.accountNumber = newDataString?.substringWithRange(NSRange(location: 41, length: 10))
            
            performUIUpdatesOnMain {
                if newDataString!.rangeOfString("error").location == NSNotFound {
                    let nextController = self.storyboard?.instantiateViewControllerWithIdentifier("TabBarController") as! UITabBarController
                    self.presentViewController(nextController,animated:true,completion:nil)
                    print(self.accountNumber)
                    self.getUserData()
                    return
                } else {
                    self.errorLabel.text = "⚠️ Invalid Username or Password. Try Again."
                }
            }
        }
        
    task.resume()

    }
    
    func getUserData() {
        print(self.accountNumber)
        //let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/users/\(self.accountNumber!)")!)
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/users/6669529102")!)
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
                    if let userInfo = parsedResult as? [[String:AnyObject]] {
                        performUIUpdatesOnMain {
                            self.userInfo = userInfo
                            print(userInfo)
                        }
                    }
                }
            }
        }
        task.resume()

    }
    
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.becomeFirstResponder()
        if textField.text == "Email" || textField.text == "Password" {
            textField.text = ""
        }
        if passwordTextField.editing {
            textField.secureTextEntry = true
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if emailTextField == textField {
            if textField.text == "" {
                textField.text = "Email"
            }
        } else if passwordTextField == textField {
            if textField.text == "" {
                textField.secureTextEntry = false
                textField.text = "Password"
            }
        }
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if emailTextField.editing {
            if textField.text == "" {
                textField.text = "Email"
            }
        } else if passwordTextField.editing {
            if textField.text == "" {
                textField.secureTextEntry = false
                textField.text = "Password"
            }
        }
        textField.resignFirstResponder()
        return true
    }
    
}


