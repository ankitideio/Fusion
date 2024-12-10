//
//  ExtensionSubscriptionListVC.swift
//  Fusion
//
//  Created by meet sharma on 31/01/23.
//

import Foundation
import UIKit
import StoreKit
import FirebaseDatabase

struct IAP_product_ids{
    var fortyCredits = "com.AppFusion.FortyCredit"
    var hundredCredits  = "com.AppFusion.HundredCredit"
    var twoHundredCredits = "com.AppFusion.TwoHundredCredit"
    var fourHundredCredits = "com.AppFusion.FourHundredCredit"
}
extension SubscriptionListVC {
    //MARK: - Funtions
    
    fileprivate var pageSize: CGSize {
        let layout = self.clsnVwSubscription.collectionViewLayout as! UPCarouselFlowLayout
        var pageSize = layout.itemSize
        if layout.scrollDirection == .horizontal {
            pageSize.width += layout.minimumLineSpacing
        } else {
            pageSize.height += layout.minimumLineSpacing
        }
        return pageSize
    }
}
//MARK: - Collectionview Delegate & Data Source
extension SubscriptionListVC: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIScrollViewDelegate{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrSubscription.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SubscriptionListCVC", for: indexPath) as! SubscriptionListCVC
        cell.lblSubscriptionTitle.text = arrSubscription[indexPath.row]
        cell.btnBuy.layer.cornerRadius = 17.5
        cell.btnBuy.layer.borderWidth = 1.5
        cell.btnBuy.layer.borderColor = UIColor.black.cgColor
        cell.mainVw.layer.cornerRadius = 10
        cell.mainVw.layer.borderWidth = 1.5
        cell.mainVw.layer.borderColor = UIColor.black.cgColor
        cell.btnBuy.addTarget(self, action: #selector(buySubscription), for: .touchUpInside)
        cell.btnBuy.tag = indexPath.row
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let layout = self.clsnVwSubscription.collectionViewLayout as! UPCarouselFlowLayout
        let pageSide = (layout.scrollDirection == .horizontal) ? self.pageSize.width : self.pageSize.height
        let offset = (layout.scrollDirection == .horizontal) ? scrollView.contentOffset.x : scrollView.contentOffset.y
        currentPage = Int(floor((offset - pageSide / 2) / pageSide) + 1)
    }
    
    @objc func buySubscription(sender:UIButton){
        selectIndex = sender.tag
        buyNowAction()
    }
    
}
extension SubscriptionListVC: SKProductsRequestDelegate, SKPaymentTransactionObserver
{
    func buyCredit(credit:Int){
        let currentCount = self.creditCount
        let newCount = currentCount + credit
        print(newCount)
        let postRef = Database.database().reference().child("CreditsCount")
        let postData = [
            "credit": newCount,
            "id": Store.id ?? ""
        ] as [String:Any]
        postRef.setValue(postData, withCompletionBlock: { error, ref in
            if error == nil{
                
            }else{
                showSwiftyAlert("", "Error", false)
            }
        })
        self.getCreditsCount()
    }
    func buyNowAction() {
        if (SKPaymentQueue.canMakePayments()) {
            var productID:NSSet!
            if self.selectIndex == 0{
                productID = NSSet(object:IAP_product_ids().fortyCredits);
            
            }else if self.selectIndex == 1{
                productID = NSSet(object:IAP_product_ids().hundredCredits);
               
            }else if self.selectIndex == 2{
                productID = NSSet(object:IAP_product_ids().twoHundredCredits);
               
            }else{
                productID = NSSet(object:IAP_product_ids().fourHundredCredits);
            }
            let productsRequest:SKProductsRequest = SKProductsRequest(productIdentifiers: productID as! Set<String>);
            productsRequest.delegate = self;
            productsRequest.start();
            print("Fetching Products");
        } else {
            print("can't make purchases");
        }
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let count : Int = response.products.count
        if (count>0) {
            let validProduct: SKProduct = response.products[0] as SKProduct
            print("validProduct.productIdentifier\(validProduct.productIdentifier)")
            if (validProduct.productIdentifier == IAP_product_ids().fortyCredits || validProduct.productIdentifier == IAP_product_ids().hundredCredits || validProduct.productIdentifier == IAP_product_ids().twoHundredCredits || validProduct.productIdentifier == IAP_product_ids().fourHundredCredits){
                buyProduct(product: validProduct);
            } else {
                print("validProduct.productIdentifier\(validProduct.productIdentifier)")
            }
        } else {
            print("nothing")
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print("Received Payment Transaction Response from Apple");
        
        for transaction:AnyObject in transactions {
            if let trans:SKPaymentTransaction = transaction as? SKPaymentTransaction{
                switch trans.transactionState {
                case .purchased:
                    print("Product Purchased");
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    if self.selectIndex == 0{
                     buyCredit(credit: 40)
                    }else if self.selectIndex == 1{
                       buyCredit(credit: 100)
                    }else if self.selectIndex == 2{
                       buyCredit(credit: 200)
                    }else{
                     buyCredit(credit: 400)
                    }
                    break;
                case .failed:
                    print("Purchased Failed");
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    break;
                case .restored:
                    print("Already Purchased");
                    SKPaymentQueue.default().restoreCompletedTransactions()
                default:
                    break;
                }
            }
        }
    }
    
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Error Fetching product information");
    }
    
    func buyProduct(product: SKProduct) {
        print("Sending the Payment Request to Apple---\(product)");
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment);
        SKPaymentQueue.default().add(self)
    }
    
}
