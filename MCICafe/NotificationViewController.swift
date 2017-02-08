//
//  NotificationViewController.swift
//  MCICafe
//
//  Created by Erick Barbosa on 1/27/17.
//  Copyright © 2017 Erick Barbosa. All rights reserved.
//

import UIKit
import Firebase


class NotificationViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var msgTexField: UITextField!
    @IBOutlet var scrollView: UIScrollView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        msgTexField.delegate = self
        
        registerForKeyboardNotifications()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(NotificationViewController.keyboardDismiss))
        view.addGestureRecognizer(tap)
        
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func registerForKeyboardNotifications(){
        //Adding notifies on keyboard appearing
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @IBAction func exitButton(_ sender: UIButton) {
        

        self.dismiss(animated: true, completion: nil)
        
    }
    func animateTextField(textField: UITextField, up: Bool)
    {
        let movementDistance:CGFloat = -130
        let movementDuration: Double = 0.3
        
        var movement:CGFloat = 0
        if up
        {
            movement = movementDistance
        }
        else
        {
            movement = -movementDistance
        }
        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
    
    
    
//    func deregisterFromKeyboardNotifications(){
//        //Removing notifies on keyboard appearing
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
//    }
    
    func keyboardWasShown(notification: NSNotification){
        //Need to calculate keyboard exact size due to Apple suggestions
        self.scrollView.isScrollEnabled = true
        var info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height, 0.0)
        
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        //self.scrollView.isScrollEnabled = false
        
        var aRect : CGRect = self.view.frame
        aRect.size.height -= keyboardSize!.height
        if let msgTexField = self.msgTexField {
            if (!aRect.contains(msgTexField.frame.origin)){
                self.scrollView.scrollRectToVisible(msgTexField.frame, animated: true)
            }
        }
    }
    
    func keyboardWillBeHidden(notification: NSNotification){
        //Once keyboard disappears, restore original positions
        var info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -keyboardSize!.height, 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        self.view.endEditing(true)
        self.scrollView.isScrollEnabled = false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField){
        msgTexField = textField
//        self.animateTextField(textField: textField, up:true)
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField){
        msgTexField.text = nil
//        self.animateTextField(textField: textField, up:false)
    }
    
    func keyboardDismiss() {
        msgTexField.resignFirstResponder()
        
    }
    
    
    //Dismiss keyboard using Return Key (Done) Button
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        keyboardDismiss()
        
        return true
    }
    func displayAlert(title: String, message: String) {
        
        
        let refreshAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            self.dismiss(animated: true, completion: nil)
        }))
        
        
        present(refreshAlert, animated: true, completion: nil)
        
    }

    
    @IBAction func sendButton(_ sender: UIButton) {
        
        if msgTexField.text == "" {
            displayAlert(title: "empty", message: "cannot send empty message")
        }
        
        var request = URLRequest(url: URL(string: "https://fcm.googleapis.com/fcm/send")!)
        
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("key=AAAAL644vRY:APA91bGsDOi2kNyK5pnRjkvBVOK47-UhllnHIk3_33PP4O0C0os2ur1YpY4l-KPuRGl1f-GoBgkh_8q3Xk4Ttdc_sdNl5UHC-VxMyY7BxTJuzu0hb65rSyjbGvWuAR2GW_JxF9X9r0qmHZD2UR7SYSt6YFrys3lSvw", forHTTPHeaderField: "Authorization")
       
        
        let postParams: [String : Any] = ["to": "/topics/notification","priority": "high", "content_available": true,"time_to_live" : 5, "notification": ["body": msgTexField.text!]]
        
        do
        {
            request.httpBody = try JSONSerialization.data(withJSONObject: postParams, options: JSONSerialization.WritingOptions())
        }
        catch
        {
            print("Caught an error: \(error)")
        }
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let realResponse = response as? HTTPURLResponse
            {
                if realResponse.statusCode != 200
                {
                    print("Not a 200 response")
                }
            }
            
            if let postString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue) as? String
            {
                print("POST: \(postString)")
            }
        }
        
        task.resume()
        keyboardDismiss()
        
        msgTexField.text = nil

        

    }
    
}

    
