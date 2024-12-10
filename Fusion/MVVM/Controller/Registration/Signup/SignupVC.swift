//
//  SignupVC.swift
//  Fusion
//
//  Created by Apple on 28/12/22.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
class SignupVC: UIViewController {
    
    @IBOutlet weak var txtFldConfirmPassword: UITextField!
    @IBOutlet weak var txtFldUserName: UITextField!
    @IBOutlet weak var txtFldPassword: UITextField!
    @IBOutlet weak var btnSignup: UIButton!
    var ref: DatabaseReference!
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        btnSignup.layer.cornerRadius = 5
        btnSignup.layer.borderWidth = 1.5
        btnSignup.layer.borderColor = UIColor.black.cgColor
        
        
        
    }
    
    @IBAction func actionLogin(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func actionSignup(_ sender: Any) {
        if txtFldUserName.text == ""{
            showSwiftyAlert("", "Please enter your email", false)
        }else if txtFldUserName.isValidEmail() == false{
            showSwiftyAlert("", "Please enter valid email", false)
        }else if txtFldPassword.text == ""{
            showSwiftyAlert("", "Please enter your password", false)
        }else if txtFldConfirmPassword.text == ""{
            showSwiftyAlert("", "Please enter your confirm password", false)
        }else if txtFldConfirmPassword.text != txtFldPassword.text{
            showSwiftyAlert("", "Password and confirm password doesn't match", false)
        }else{
            let signUpManager = FirebaseAuthManager()
            if let email = txtFldUserName.text, let password = txtFldPassword.text {
                signUpManager.createUser(email: email, password: password) {[weak self] (success) in
                    guard self != nil else { return }
                    var message: String = ""
                    if (success) {
                        message = "User was sucessfully created."
                        showSwiftyAlert("", "User was sucessfully created.", true)
                        Store.autoLogin = true
                        Store.id = Auth.auth().currentUser?.uid ?? ""
                        Store.email = Auth.auth().currentUser?.email ?? ""
                        print(Auth.auth().currentUser?.uid ?? "")
                        
                        SceneDelegate().setHomeeRoot()
                    } else {
                        message = "There was an error."
                    }
                    
                }
            }
        }
    }
}
