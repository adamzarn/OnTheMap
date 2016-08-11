//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Adam Zarn on 7/18/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class LoginViewController: UIViewController, UITextFieldDelegate, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var emailTextField: MyTextField!
    @IBOutlet weak var passwordTextField: MyTextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var FBLoginButton: FBSDKLoginButton!
    
    let unableToConnectAlert:UIAlertController = UIAlertController(title: "Unable to Connect", message: "Check your connection or try again later.",preferredStyle: UIAlertControllerStyle.Alert)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FBLoginButton.readPermissions = ["email"]
        FBLoginButton.delegate = self
        
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        emailTextField.autocorrectionType = .No
        passwordTextField.autocorrectionType = .No
        
        loginLabel.text = "Login to Udacity"
        emailTextField.text = "Email"
        passwordTextField.text = "Password"
        signUpButton.titleLabel!.text = "Don't have an account? Sign up."
        errorLabel.text = ""
        
        loginButton.backgroundColor = UIColor(red: 0.9647, green: 0.3137, blue: 0.1255, alpha: 1.0)

        emailTextField.layer.cornerRadius = 5
        passwordTextField.layer.cornerRadius = 5
        loginButton.layer.cornerRadius = 5
        FBLoginButton.layer.cornerRadius = 5
        
        loginLabel.font = UIFont(name: "Roboto-Regular", size:17)
        emailTextField.font = UIFont(name: "Roboto-Regular", size:17)
        passwordTextField.font = UIFont(name: "Roboto-Regular", size:17)
        loginButton.titleLabel!.font = UIFont(name: "Roboto-Regular", size:17)
        signUpButton.titleLabel!.font = UIFont(name: "Roboto-Regular", size:17)
        
        let backgroundGradient = CAGradientLayer()
        let colorTop = UIColor(red: 1.0, green: 0.5803, blue: 0.1882, alpha: 1.0).CGColor
        let colorBottom = UIColor(red: 1.0, green: 0.4196, blue: 0.1216, alpha: 1.0).CGColor
        backgroundGradient.colors = [colorTop, colorBottom]
        backgroundGradient.locations = [0.0, 1.0]
        backgroundGradient.frame = view.frame
        view.layer.insertSublayer(backgroundGradient, atIndex: 0)
        
        activityIndicator.hidden = true
        
        unableToConnectAlert.addAction(UIAlertAction(title:"OK",style: UIAlertActionStyle.Default, handler: nil))
        
    }
    
    override func viewWillAppear(animated: Bool) {
        emailTextField.text = "Email"
        passwordTextField.text = "Password"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signUpButtonPressed(sender: AnyObject) {
        if let url = NSURL(string: "https://www.udacity.com/account/auth#!/signup") {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    func currentAccessToken() -> FBSDKAccessToken! {
        return FBSDKAccessToken.currentAccessToken()
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
        self.activityIndicator.hidden = false
        self.activityIndicator.startAnimating()
        
        UdacityClient.sharedInstance().FBLogin(currentAccessToken().tokenString, completion: { (result, error) -> () in
            CurrentUser.facebookToken = self.currentAccessToken().tokenString
            if let result = result {
                if let account = result["account"] {
                    CurrentUser.userID = account["key"]!
                    let nextController = self.storyboard?.instantiateViewControllerWithIdentifier("TabBarController") as! UITabBarController
                    self.activityIndicator.stopAnimating()
                    self.presentViewController(nextController,animated:true,completion:nil)
                    UdacityClient.sharedInstance().getUserData { (result, error) -> Void in
                        if let result = result {
                            CurrentUser.firstName = String(result["first_name"]!)
                            CurrentUser.lastName = String(result["last_name"]!)
                        } else {
                            print(error)
                        }
                    }
                } else {
                    self.errorLabel.text = "⚠️ Invalid Username or Password. Try Again."
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.hidden = true
                }
            } else {
                print(error)
                self.activityIndicator.stopAnimating()
                self.activityIndicator.hidden = true
                self.presentViewController(self.unableToConnectAlert, animated: true, completion: nil)
            }
        print("logged in")
        })
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("logged out")
    }
    
    @IBAction func loginPressed(sender: AnyObject) {
        
        CurrentUser.facebookToken = ""
        
        self.errorLabel.text = ""
        
        if emailTextField.isFirstResponder() {
            emailTextField.resignFirstResponder()
        } else {
            passwordTextField.resignFirstResponder()
        }
        
        self.activityIndicator.hidden = false
        self.activityIndicator.startAnimating()
        
        UdacityClient.sharedInstance().login(emailTextField.text!, password: passwordTextField.text!, completion: { (result, error) -> () in
            if let result = result {
                if let account = result["account"] {
                    CurrentUser.userID = account["key"]!
                    let nextController = self.storyboard?.instantiateViewControllerWithIdentifier("TabBarController") as! UITabBarController
                    self.activityIndicator.stopAnimating()
                    self.presentViewController(nextController,animated:true,completion:nil)
                    UdacityClient.sharedInstance().getUserData { (result, error) -> Void in
                        if let result = result {
                            CurrentUser.firstName = String(result["first_name"]!)
                            CurrentUser.lastName = String(result["last_name"]!)
                        } else {
                            print(error)
                        }
                    }
                } else {
                    self.errorLabel.text = "⚠️ Invalid Username or Password. Try Again."
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.hidden = true
                }
            } else {
                print(error)
                self.activityIndicator.stopAnimating()
                self.activityIndicator.hidden = true
                self.presentViewController(self.unableToConnectAlert, animated: true, completion: nil)
            }
        })
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


