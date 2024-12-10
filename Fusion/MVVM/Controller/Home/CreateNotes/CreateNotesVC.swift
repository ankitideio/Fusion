//
//  CreateNotesVC.swift
//  Fusion
//
//  Created by Apple on 28/12/22.
//

import UIKit
import FirebaseDatabase
import AudioToolbox
import IQKeyboardManagerSwift
import FirebaseStorage
import FirebaseFirestore
class CreateNotesVC: UIViewController,UITextViewDelegate {
    
    @IBOutlet weak var dotTop: NSLayoutConstraint!
    @IBOutlet weak var dotTrailing: NSLayoutConstraint!
    @IBOutlet weak var txtVwNote: UITextView!
    @IBOutlet weak var vwShare: UIView!
    @IBOutlet weak var vwImage: UIView!
    
    let fetcher = OpenAIService()
    var photos = [Photo]()
    var arrImage = [String]()
    let image = UIImageView()
    var ref: DatabaseReference!
    var creditCount = 0
    var imageStyle = ""
    var viewModel = ImgUploadVM()
    var uploadImg = false
    var imageText = ""
    var imgData = UIImageView()
    var imgUrl: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        txtVwNote.delegate = self
        vwImage.layer.cornerRadius = 2.0
        
        if Store.imageSize == ""{
            Store.imageSize = "1024x1024"
        }
        IQKeyboardManager.shared.enable = false
        let str = "Super long string here"
        let filename = getDocumentsDirectory().appendingPathComponent("output.txt")
        print(filename)
        do {
            try str.write(to: filename, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            // failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
        }
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    override func viewWillAppear(_ animated: Bool) {
        getCreditsCount()
        getImageStyleUrl()
        checkDotStatus()
        if UIDevice().hasNotch == true{
            self.dotTrailing.constant = CGFloat(95)
            self.dotTop.constant = CGFloat(25)
        }else{
            self.dotTrailing.constant = CGFloat(40)
            self.dotTop.constant = CGFloat(8)
        }
    }
    
    @objc func methodOfReceivedNotification(notification: Notification) {
        
        checkDotStatus()
        
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
                self.creditCount = creditScore as? Int ?? 0
            }else{
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
                self.imageStyle = imageStyle as? String ?? ""
            }else{
                self.imageStyle = ""
            }
            
            
        })
    }
    func checkDotStatus(){
        switch fetchDotStatus(){
        case 1:
            vwImage.backgroundColor = .yellow
            vwImage.isHidden = false
        case 2:
            vwImage.backgroundColor = .red
            vwImage.isHidden = false
        case 3:
            vwImage.backgroundColor = .green
            vwImage.isHidden = false
            if photos.count > 0 {
                
                let a = String(describing: photos[0].url)
                self.arrImage.append(a)
                print(self.arrImage)
                
                let postRef = Database.database().reference().child("users").childByAutoId()
                let postData = [
                    "name": "\(self.imageStyle) \(self.imageText)",
                    "image": a,
                    "id": Store.id ?? "",
                    "uid": postRef.key ?? "",
                    "updateText": self.imageText
                ] as [String:Any]
                postRef.setValue(postData, withCompletionBlock: { error, ref in
                    if error == nil{
                        
                    }else{
                        showSwiftyAlert("", "Error", false)
                    }
                })
                
                
                
                self.uploadImg = false
                
            }
            
            if creditCount > 0{
                let postCredit = Database.database().reference().child("CreditsCount")
                self.creditCount = creditCount - 1
                let postCreditData = [
                    "credit": creditCount,
                    "id": Store.id ?? ""
                ] as [String:Any]
                postCredit.setValue(postCreditData, withCompletionBlock: { error, ref in
                    if error == nil{
                        
                    }else{
                        showSwiftyAlert("", "Error", false)
                    }
                })
            }
            if Store.isVibrationOn == true{
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            }
            self.getCreditsCount()
            
            
        default:
            vwImage.isHidden = true
        }
    }
    
    //MARK: - Add image to Library
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
        } else {
            
        }
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        
        return true
    }
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if txtVwNote.text == "" || txtVwNote.text.count == 0{
            TostErrorMessage(view: self, message: "Please type something which you want in the image")
        }else{
            //            if self.creditCount != 0 {
            
            if uploadImg == false{
                self.imageText = txtVwNote.text ?? ""
                self.uploadImg = true
                
                Task{
                    do{
                        photos = try await fetcher.generateImage(from: "\(self.imageStyle) \(txtVwNote.text ?? "")",obj:self)
                        if let url = self.photos.map(\.url).first{
                            let (data,_) = try await URLSession.shared.data(from: url)
                            print(photos.count)
                            if photos.count > 0{
                                let data = try? Data(contentsOf: photos[0].url)
                                
                                if let imageData = data {
                                    let image = UIImage(data: imageData)
                                    print(image ?? UIImage())
                                    self.imgData.image = image
                                    
                                }
                                self.uploadImage(self.imgData.image ?? UIImage()) { url in
                                    print(url ?? "")
                                    DispatchQueue.main.async {
                                        activityIndicatorEnd(view: keyWindow)
                                    }
                                }
                            }
                                    //activityIndicatorEnd(view: keyWindow)
                                    self.image.image = UIImage(data: data ?? Data())
                                self.ResizeImage(image: self.image.image ?? UIImage() , targetSize: CGSizeMake(512.0, 1024.0))
                                    
                                    //     self.navigationController?.popViewController(animated: true)
                                    //   addSiriButton(to: self.view)
                            }
                        
                        }catch{
                            print(error)}
                    }
                    //            }else{
                    //                showSwiftyAlert("", "Please buy credits", false)
                    //            }
                }else{
                    TostErrorMessage(view: self, message: "Please wait")
                }
            }
            return true
        }
        
        func ResizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
            let size = image.size
            
            let widthRatio  = targetSize.width  / image.size.width
            let heightRatio = targetSize.height / image.size.height
            
            // Figure out what our orientation is, and use that to form the rectangle
            var newSize: CGSize
            if(widthRatio > heightRatio) {
                newSize = CGSizeMake(size.width * heightRatio, size.height * heightRatio)
            } else {
                newSize = CGSizeMake(size.width * widthRatio,  size.height * heightRatio)
            }
            
            // This is the rect that we've calculated out and this is what is actually used below
            let rect = CGRectMake(0, 0, newSize.width, newSize.height)
            
            // Actually do the resizing to the rect using the ImageContext stuff
            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            image.draw(in: rect)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            saveDotStatus(dot: 3)
            checkDotStatus()
            
            
            //        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: NSNotification.Name("NotificationDotRemove"), object: nil)
            UIImageWriteToSavedPhotosAlbum(newImage, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
            NotificationCenter.default.post(name: Notification.Name("NotificationDotRemove"), object: nil)
            return newImage
        }
        
        @IBAction func actionMore(_ sender: Any) {
          
            
        }
        
        @IBAction func actionBack(_ sender: Any) {
            self.navigationController?.popViewController(animated: true)
        }
        
        @IBAction func actionShare(_ sender: Any) {
            
        }
        
        @IBAction func actionDone(_ sender: Any) {
            //        if txtVwNote.text == "" || txtVwNote.text.count == 0{
            //            TostErrorMessage(view: self, message: "Please type somting which you want in the image")
            //        }else{
            //
            //            Task{
            //                do{
            //                    photos = try await fetcher.generateImage(from: txtVwNote.text ?? "")
            //                    if let url = self.photos.map(\.url).first{
            //                        let (data,_) = try await URLSession.shared.data(from: url)
            //                        print(photos.count)
            //                        DispatchQueue.main.async {
            //                            activityIndicatorEnd(view: keyWindow)
            //                        }
            //                        //activityIndicatorEnd(view: keyWindow)
            //                        image.image = UIImage(data: data)
            //                        UIImageWriteToSavedPhotosAlbum(image.image!, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
            //                        self.navigationController?.popViewController(animated: true)
            //                     //   addSiriButton(to: self.view)
            //                    }
            //                }catch{
            //                    print(error)}
            //            }
            //        }
        }
        
    }
    
    extension CreateNotesVC{
        func uploadImage(_ image:UIImage, completion: @escaping ((_ url:URL?)->())){
            var text = String()
            let greeting = Store.email ?? ""
            let prefix = greeting.prefix(while: { $0 != "@" })
            text = String(prefix)
            let imgeText = "\(text).png"
            let storageRef = Storage.storage().reference().child(Store.id ?? "").child(imgeText)
            let imgData = self.imgData.image?.pngData()
            let metaData = StorageMetadata()
            metaData.contentType = "image/png"
            let db = Firestore.firestore()
            
            storageRef.putData(imgData ?? Data(), metadata: metaData){  (metadata,error) in
                if error == nil{
                    print("Success")
                    storageRef.downloadURL(completion: { (url,error) in
                        completion(url)
                        
                        
                    })
                }else{
                    print("error in save image")
                    completion(nil)
                }
                
            }
        }
    }
