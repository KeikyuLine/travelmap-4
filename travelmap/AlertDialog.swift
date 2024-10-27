//
//  AlertDialog.swift
//  travelmap
//
//  Created by 齋藤温仁 on 2024/08/04.
//

import Foundation
import UIKit
class AlertDialog {
    static let shared = AlertDialog()
    var text = ""
    var duration: Double = 0.0
    
    func showDatePicker(vc: UIViewController, completion: @escaping() -> Void) {
        let myDatePicker: UIDatePicker = UIDatePicker()
        myDatePicker.timeZone = .current
        myDatePicker.preferredDatePickerStyle = .wheels
        myDatePicker.datePickerMode = .countDownTimer
        myDatePicker.frame = CGRect(x: 0, y: 15, width: 270,height: 200)
        let alertController = UIAlertController(title: "\n\n\n\n\n\n\n\n", message: nil, preferredStyle: .alert)
        alertController.view.addSubview(myDatePicker)
        let selectAction = UIAlertAction(title: "Ok", style: .default, handler: { _ in
            self.duration = myDatePicker.countDownDuration/60
            completion()
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(selectAction)
        alertController.addAction(cancelAction)
        vc.present(alertController, animated: true)
    }
    
    func showAlertWithText(vc: UIViewController, completion: @escaping() -> Void) {
        var textFieldOnAlert = UITextField()
        
        let alert = UIAlertController(title: "テキスト入力",
                                      message: nil,
                                      preferredStyle: .alert)
        alert.addTextField{ TextField in
            textFieldOnAlert = TextField
            textFieldOnAlert.returnKeyType = .done
        }
        
        let doneAction = UIAlertAction(title: "決定", style: .default) {_ in
                    //TODO: 修正する
                    self.text = textFieldOnAlert.text!
                    completion()
        }
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel)
        
        alert.addAction(doneAction)
        alert.addAction(cancelAction)
        vc.present(alert, animated: true)
    }
    
    
    
    
    func showAlertWithCancel(title: String, message: String, viewController: UIViewController, completion: @escaping() -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { (action) in
            completion()
        }
        let cancel: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler: {
            (action: UIAlertAction!) -> Void in
            print("cancel")
        })
        alert.addAction(ok)
        alert.addAction(cancel)
        viewController.present(alert, animated: true, completion: nil)
    }
    
    func showAlert(title: String, message: String, viewController: UIViewController, edit: @escaping() -> Void, viewWeb: @escaping() -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let edit = UIAlertAction(title: "URL編集", style: .default) { (action) in
            edit()
        }
        
        let goWeb = UIAlertAction(title: "Web閲覧", style: .default) { (action) in
            viewWeb()
        }
        
        alert.addAction(edit)
        alert.addAction(goWeb)
        viewController.present(alert, animated: true, completion: nil)
    }
}
