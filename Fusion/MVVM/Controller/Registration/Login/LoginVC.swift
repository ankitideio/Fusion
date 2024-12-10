//
//  LoginVC.swift
//  Fusion
//
//  Created by Apple on 28/12/22.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
class LoginVC: UIViewController {
    
    @IBOutlet weak var txtFldUserName: UITextField!
    @IBOutlet weak var txtFldPassword: UITextField!
    @IBOutlet weak var btnLogin: UIButton!
    var ref: DatabaseReference!
    var viewModel = ImgUploadVM()
    let fetcher = OpenAIService()
    var photos = [Photo]()
    var arrImage = [String]()
    let image = UIImageView()
    override func viewDidLoad() {
        super.viewDidLoad()
        if Store.imageSize == ""{
            Store.imageSize = "1024x1024"
        }
       
        btnLogin.layer.cornerRadius = 5
        btnLogin.layer.borderWidth = 1.5
        btnLogin.layer.borderColor = UIColor.black.cgColor
   
        
    }
    
    //MARK: - Fuctions
    func signIn(email: String, pass: String, completionBlock: @escaping (_ success: Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: pass, completion: { (auth, error) in
            if let maybeError = error { //if there was an error, handle it
                let err = maybeError as NSError
                switch err.code {
                case AuthErrorCode.wrongPassword.rawValue:
                    print("wrong password")
                    showSwiftyAlert("", "wrong password", false)
                case AuthErrorCode.invalidEmail.rawValue:
                    print("invalid email")
                    showSwiftyAlert("", "invalid email", false)
                case AuthErrorCode.accountExistsWithDifferentCredential.rawValue:
                    print("accountExistsWithDifferentCredential")
                    showSwiftyAlert("", err.localizedDescription, false)
                    
                default:
                    print("unknown error: \(err.localizedDescription)")
                    showSwiftyAlert("", "Invalid user", false)
                }
            } else { 
                if let _ = auth?.user {
                    print(auth?.user.refreshToken ?? 0)
                    Store.id = auth?.user.uid ?? ""
                    Store.email = auth?.user.email ?? ""
                    print(auth?.user.uid ?? "")
        
                    Store.autoLogin = true
                    SceneDelegate().setHomeeRoot()
                } else {
                    print("no user found")
                    showSwiftyAlert("", "No User Found!", false)
                }
            }
        })
    }
   
     
    //MARK: - Actions
    @IBAction func actionLogin(_ sender: Any) {
        if txtFldUserName.text == ""{
            showSwiftyAlert("", "Please enter your email", false)
        }else if txtFldUserName.isValidEmail() == false{
            showSwiftyAlert("", "Please enter valid email", false)
        }else if txtFldPassword.text == ""{
            showSwiftyAlert("", "Please enter your passwor", false)
        }else{
            guard let email = txtFldUserName.text, let password = txtFldPassword.text else { return }
            signIn(email: email, pass: password) {[weak self] (success) in
                guard self != nil else { return }
                if (success) {
                   
                } else {
                 
                }
            }
        }
    }
    
    @IBAction func actionSignup(_ sender: Any) {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "SignupVC") as! SignupVC
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
}
