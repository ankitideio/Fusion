//
//  NotesLIstVC.swift
//  Fusion
//
//  Created by Apple on 28/12/22.
//

import UIKit
import FirebaseDatabase
import Firebase
import FirebaseStorage
class NotesLIstVC: UIViewController {


    @IBOutlet weak var topDot: NSLayoutConstraint!
    @IBOutlet weak var tralingDot: NSLayoutConstraint!
    @IBOutlet weak var vwSearch: UIView!
    @IBOutlet weak var txtFldSearch: UITextField!
    @IBOutlet weak var tblVwList: UITableView!
    @IBOutlet weak var btnHidden: UIButton!
    @IBOutlet weak var vwDot: UIView!
    var img = String()
    var name = String()
    var imagesArray = [String]()
    var updateText = String()
    var arr = [UserData]()
    var arrNotes = [UserData]()
    var userData = [UserData]()
    var arrSearchNotes = [UserData]()
    var ref: DatabaseReference?
    var viewModel = ImgUploadVM()
    let fetcher = OpenAIService()
    var photos = [Photo]()
    var arrImage = [String]()
    let image = UIImageView()
    var creditCount = 0
    var imgData = UIImageView()
    var imgUrl: String?

    override func viewDidLoad() {
        super.viewDidLoad()
    
        tblVwList.dataSource = self
        tblVwList.delegate = self
        tblVwList.rowHeight = UITableView.automaticDimension
        tblVwList.estimatedRowHeight = 50
        vwSearch.layer.cornerRadius = 10
        vwDot.layer.cornerRadius = 2.0
        txtFldSearch.delegate = self
        txtFldSearch.attributedPlaceholder = NSAttributedString(
            string: "Search",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
        )
      
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    override func viewWillAppear(_ animated: Bool) {
        if Store.showMessage == false{
            showAlertWithOkButton()
           
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.RemoveDotStatus(notification:)), name: Notification.Name("NotificationDotRemove"), object: nil)
        checkDotStatus()
        getPostData()
       if UIDevice().hasNotch == true{
            self.tralingDot.constant = CGFloat(95)
            self.topDot.constant = CGFloat(25)
        }else{
            self.tralingDot.constant = CGFloat(40)
            self.topDot.constant = CGFloat(8)
        }
    }

   
   @objc func RemoveDotStatus(notification: NSNotification){
        checkDotStatus()
        getPostData()

    }
    
    func showAlertWithOkButton() {
        let alertController = UIAlertController(title: "Fusion AI", message: "To open the secret menu double tap the bottom left corner of the screen.", preferredStyle: .alert)

        let okAction = UIAlertAction(title: "Okay", style: .default) { (_) in
            Store.showMessage = true
            self.dismiss(animated: true)
        }

        alertController.addAction(okAction)

        present(alertController, animated: true, completion: nil)
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
            self.arrNotes.removeAll()
            self.userData.removeAll()
            self.userData = tempPost
            
            self.arr.removeAll()
            self.arrSearchNotes.removeAll()
            for i in self.userData{
                if Store.id == i.id {
                    self.arr.append(i)
                    
                }
            }
            for arrayIndex in stride(from: self.arr.count - 1, through: 0, by: -1) {
                self.arrNotes.append(self.arr[arrayIndex])
            }
            if self.arrNotes.count > 0 {
                self.img = self.arrNotes[0].image 
                self.name = self.arrNotes[0].name
                self.updateText = self.arrNotes[0].updateText
            }else{
                self.imgData.image = UIImage(named: "Splash screen-2")
                self.uploadImage(self.imgData.image ?? UIImage()) { url in
                    print(url ?? "")
                }
            }
            self.arrSearchNotes = self.arrNotes
            self.tblVwList.reloadData()

        
        })
       
    }
    func searchNotes(text:String){
        arrNotes = self.arrSearchNotes.filter({ (value) -> Bool in
            let name = value.name
            return ((name.lowercased()).contains(text.lowercased()))
        })
        if text == ""{
        arrNotes = arrSearchNotes
        }
        self.tblVwList.reloadData()
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
    
    @IBAction func actionMenu(_ sender: Any) {
       
    }
    
    @IBAction func actionCreate(_ sender: Any) {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "CreateNotesVC") as! CreateNotesVC
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func actionSubscriptionBtn(_ sender: UIButton) {
       
    }
    @IBAction func actionHidden(_ sender: Any) {
     
        let vc = storyboard?.instantiateViewController(withIdentifier: "CreditsVC") as! CreditsVC
        if arrNotes.count > 0{
            vc.key = arrNotes[0].uid
//            
//            vc.imgUrl = arrNotes[0].image
        }else{
            vc.imgUrl = Store.latestImgUrl ?? ""
        }
        vc.callBack = { (isBuy) in
            if isBuy == true{
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "SubscriptionListVC") as! SubscriptionListVC
                vc.modalPresentationStyle = .overFullScreen
                self.navigationController?.present(vc, animated:true)
            }else{
            
            }
        }
        vc.modalPresentationStyle = .overFullScreen
        self.navigationController?.present(vc, animated: true)
     
    }
}
extension NotesLIstVC{
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

