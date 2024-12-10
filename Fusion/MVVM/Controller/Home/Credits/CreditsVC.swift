//
//  CreditsVC.swift
//  Fusion
//
//  Created by Apple on 29/12/22.
//

import UIKit
import FirebaseDatabase
import AudioToolbox
import FirebaseStorage
class CreditsVC: UIViewController {

    @IBOutlet weak var vwTop: NSLayoutConstraint!
    @IBOutlet weak var dotTrailing: NSLayoutConstraint!
    @IBOutlet weak var vwDot: UIView!
    @IBOutlet weak var txtFldImageStyle: UITextField!
    @IBOutlet weak var txtFldImgSize: UITextField!
    @IBOutlet weak var txtFldInput: UITextField!
    @IBOutlet weak var btnSwitch: UISwitch!
    @IBOutlet weak var txtFldImgUrl: UITextField!
    @IBOutlet weak var btnBuy: UIButton!
    @IBOutlet weak var btnHelp: UIButton!
    @IBOutlet weak var lblCreditsScore: UILabel!
    var callBack:((_ isBuy:Bool)->())?
    var viewModel = ImgUploadVM()
    var key = String()
    var name = String()
    let fetcher = OpenAIService()
    var photos = [Photo]()
    var arrImage = [String]()
    var ref: DatabaseReference!
    var creditCount = 0
    var userData = [UserData]()
    var arr = [UserData]()
    var arrNotes = [UserData]()
    let image = UIImageView()
    var updateText = String()
    var picker = UIPickerView()
    var bizCat = ["256x256", "512x512", "1024x1024"]
    var imgUrl = ""
    var img = UIImageView()
    override func viewDidLoad() {
        super.viewDidLoad()
        vwDot.layer.cornerRadius = 2.0
        btnHelp.layer.cornerRadius = 5
        btnHelp.layer.borderWidth = 1.5
        btnHelp.layer.borderColor = UIColor.black.cgColor
        btnBuy.layer.cornerRadius = 5
        btnBuy.layer.borderWidth = 1.5
        btnBuy.layer.borderColor = UIColor.black.cgColor
        txtFldImageStyle.delegate = self
        txtFldInput.delegate = self
       
  
//        txtFldImgUrl.text = Store.latestImgUrl
        if Store.imageSize == ""{
            Store.imageSize = "1024x1024"
        }
        txtFldImgSize.text = Store.imageSize ?? "1024x1024"
         print(imgUrl)
        txtFldImgSize.inputView = picker
        picker.delegate = self
        picker.dataSource = self
       getCreditsCount()
       
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    override func viewWillAppear(_ animated: Bool) {
      getImageStyleUrl()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.RemoveDotStatus(notification:)), name: Notification.Name("NotificationDotRemove"), object: nil)
        checkDotStatus()
        setDot()
        switchOnOff()
        getImage()
//        getLatestUrl()
    }
    func getImage(){
        var text = String()
        let greeting = Store.email ?? ""
        let prefix = greeting.prefix(while: { $0 != "@" })
        text = String(prefix)
        let imgeText = "\(text).png"
        let Ref = Storage.storage().reference().child(Store.id ?? "").child(imgeText)
        Ref.downloadURL(completion: { (url,error) in
            if error != nil{

            }else{
                print(url ?? URL(fileURLWithPath: ""))
                var text = String()
                
                let greeting = String(describing: url ?? URL(fileURLWithPath: ""))
                let prefix = greeting.prefix(while: { $0 != "&" })
                text = String(prefix)
                self.imgUrl = text
                self.txtFldImgUrl.text = text
                
                print(text)
            }
        })
    }

    func getCreditsCount(){
        let ref = Database.database().reference(withPath: "CreditsCount")
            ref.observeSingleEvent(of: .value, with: { snapshot in

                if !snapshot.exists() { return }

                print(snapshot) // Its print all values including Snap (User)

                print(snapshot.value!)
                let id = snapshot.childSnapshot(forPath: "id").value
                let creditScore = snapshot.childSnapshot(forPath: "credit").value
                if Store.id == id as? String ?? ""{
                    self.lblCreditsScore.text = "\(creditScore as? Int ?? 0)"
                    self.creditCount = creditScore as? Int ?? 0
                }else{
                    self.lblCreditsScore.text = "\(0)"
                    self.creditCount = 0
                }
            

            })
        
            }
    func getImageStyleUrl(){
        let ref = Database.database().reference(withPath: "ImageStyleUrl")
            ref.observeSingleEvent(of: .value, with: { snapshot in

                if !snapshot.exists() { return }

                print(snapshot) // Its print all values including Snap (User)

                print(snapshot.value!)
                let id = snapshot.childSnapshot(forPath: "id").value
                let imageStyle = snapshot.childSnapshot(forPath: "imageStyle").value
                if Store.id == id as? String ?? ""{
                    self.txtFldImageStyle.text = imageStyle as? String ?? ""
                }else{
                    self.lblCreditsScore.text = "\(0)"
                    self.creditCount = 0
                }
            

            })
    }
    
 
    func setDot(){
        if UIDevice().hasNotch == true{
            self.dotTrailing.constant = CGFloat(95)
            self.vwTop.constant = CGFloat(25)
        }else{
            self.dotTrailing.constant = CGFloat(40)
            self.vwTop.constant = CGFloat(8)
        }
    }
    func switchOnOff(){
        if Store.isVibrationOn == true{
            btnSwitch.isOn = true
        }else{
            btnSwitch.isOn = false
        }
    }

    @objc func RemoveDotStatus(notification: NSNotification){
    
            checkDotStatus()
            getPostData()
            getImage()
     }
    func checkDotStatus(){
        switch fetchDotStatus(){
        case 1:
            vwDot.backgroundColor = .yellow
            vwDot.isHidden = false
        case 2:
            vwDot.backgroundColor = .red
            vwDot.isHidden = false
        case 3:
            vwDot.backgroundColor = .green
            vwDot.isHidden = false
        

        default:
            vwDot.isHidden = true
            
        }
    }
  func getPostData(){
       
        var tempPost = [UserData]()
      
        let postRef = Database.database().reference().child("users")
        postRef.observe(.value, with:  { snapshot in
            tempPost.removeAll()
            for child in snapshot.children{
                if let childSnapShot = child as? DataSnapshot,
                   let dict = childSnapShot.value as? [String:Any],
                 
                   let id = dict["id"] as? String,
                   let image = dict["image"] as? String,
                   let name = dict["name"] as? String,
                   let uid = dict["uid"] as? String,
                   let updateText = dict["updateText"] as? String {
                    let post = UserData(id: id, name: name, image: image, uid: uid, updateText: updateText)
                    tempPost.append(post)
                    
                }
            }
            self.userData.removeAll()
            self.userData = tempPost
            
            for i in self.userData{
                if Store.id == i.id {
                    self.arr.append(i)
                    
                }
            }
            for arrayIndex in stride(from: self.arr.count - 1, through: 0, by: -1) {
                self.arrNotes.append(self.arr[arrayIndex])
            }
            if self.arrNotes.count > 0 {
                self.imgUrl = self.arrNotes[0].image
               
            }
          

        
        })
       
    }
    @IBAction func actionHelp(_ sender: Any) {
        if let url = URL(string: "https://engageprops.com/fusion"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func actionBuy(_ sender: Any) {
      
        self.dismiss(animated: true)
        callBack?(true)
    }
    
    @IBAction func actionDone(_ sender: Any) {
        self.dismiss(animated: true)
        callBack?(false)
    }
    
    @IBAction func actionUrlBtn(_ sender: UIButton) {
     
        let textToCopy = self.imgUrl
            UIPasteboard.general.string = textToCopy
        
    }
    @IBAction func actionSwitch(_ sender: Any) {
        if btnSwitch.isOn == true{
            Store.isVibrationOn = true
        }else{
            Store.isVibrationOn = false
        }
    }
}

extension CreditsVC: UITextFieldDelegate{
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField == txtFldImageStyle{
            let postRef = Database.database().reference().child("ImageStyleUrl")
            let postData = [
                "imageStyle": txtFldImageStyle.text ?? "",
                "id": Store.id ?? ""
            ] as [String:Any]
            postRef.setValue(postData, withCompletionBlock: { error, ref in
                if error == nil{
                    
                }else{
                    showSwiftyAlert("", "Error", false)
                }
            })
            
            if let url = self.photos.map(\.url).first{
                
                
            }
        }else{
            img.image = UIImage(named: "AppIcon")
            let printController = UIPrintInteractionController.shared
            let printInfo = UIPrintInfo(dictionary: nil)
            printInfo.outputType = .photo
            printInfo.jobName = "job name"
            printController.printInfo = printInfo
            printController.printingItem = img.image
            printController.present(animated: true)
        }
        return true
    }
}
extension CreditsVC: UIPickerViewDelegate,UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
  
    
    // returns the # of rows in each component..
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return bizCat.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return bizCat[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        txtFldImgSize.text = "\(bizCat[row])"
        Store.imageSize = "\(bizCat[row])"
    }
}
