//
//  ExtentionNotesList.swift
//  Fusion
//
//  Created by Apple on 28/12/22.
//

import Foundation
import UIKit


extension NotesLIstVC:UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrNotes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblVwList.dequeueReusableCell(withIdentifier: "NotesListTVC", for: indexPath) as! NotesListTVC
        cell.lblName.text = arrNotes[indexPath.row].updateText
        return cell
    }
    
    
}
//MARK: - TEXTFIELD DELEGATE METHOD
extension NotesLIstVC: UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
        print(newString)
        if textField == txtFldSearch {
            searchNotes(text: newString)
        }
        tblVwList.reloadData()
        return true
    }
}
