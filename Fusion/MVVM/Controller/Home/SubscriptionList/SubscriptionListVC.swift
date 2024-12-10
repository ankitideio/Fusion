//
//  SubscriptionListVC.swift
//  Fusion
//
//  Created by meet sharma on 20/01/23.
//

import UIKit
import StoreKit
import FirebaseDatabase

class SubscriptionListVC: UIViewController {
   
    //MARK: - Outlets
    @IBOutlet weak var topDot: NSLayoutConstraint!
    @IBOutlet weak var dotrailing: NSLayoutConstraint!
    @IBOutlet weak var vwDot: UIView!
    @IBOutlet weak var clsnVwSubscription: UICollectionView!
    //MARK: - Variables
    var creditCount = 0
    var selectIndex = 0
    var currentPage: Int = 0 
    var arrSubscription = ["Buy 40 credits in $20","Buy 100 credits in $50","Buy 200 credits in $100","Buy 400 credits in $200"]
    override func viewDidLoad() {
        super.viewDidLoad()
//        uiData()
   
        self.clsnVwSubscription.showsHorizontalScrollIndicator = false
         let floawLayout = UPCarouselFlowLayout()
        floawLayout.itemSize = CGSize(width: UIScreen.main.bounds.size.width - 140.0, height: clsnVwSubscription.frame.size.height)
         floawLayout.scrollDirection = .horizontal
        floawLayout.sideItemScale = 0.9
         floawLayout.sideItemAlpha = 1.0
        floawLayout.spacingMode = .fixed(spacing: 20.0)
        clsnVwSubscription.collectionViewLayout = floawLayout
        vwDot.layer.cornerRadius = 2.0
     
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    override func viewWillAppear(_ animated: Bool) {
        getCreditsCount()
        NotificationCenter.default.addObserver(self, selector: #selector(self.RemoveDotStatus(notification:)), name: Notification.Name("NotificationDotRemove"), object: nil)
        checkDotStatus()
        if UIDevice().hasNotch == true{
            self.dotrailing.constant = CGFloat(95)
            self.topDot.constant = CGFloat(25)
        }else{
            self.dotrailing.constant = CGFloat(40)
            self.topDot.constant = CGFloat(8)
        }
    }
    @objc func RemoveDotStatus(notification: NSNotification){
         checkDotStatus()
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
   
    func getCreditsCount(){
            let ref = Database.database().reference(withPath: "CreditsCount")
                ref.observeSingleEvent(of: .value, with: { snapshot in
                    if !snapshot.exists() { return }
                    let id = snapshot.childSnapshot(forPath: "id").value
                    let creditScore = snapshot.childSnapshot(forPath: "credit").value
                    if Store.id == id as? String ?? ""{
                        self.creditCount = creditScore as? Int ?? 0
                        print(self.creditCount)
                    }else{
                        self.creditCount = 0
                    }
                })
            }

    //MARK: - Actions
    @IBAction func actionDone(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func actionCancel(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
}

