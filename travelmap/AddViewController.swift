//
//  AddViewController.swift
//  travelmap
//
//  Created by 齋藤温仁 on 2024/07/21.
//

import UIKit
import MapKit
import SafariServices

class AddViewController: UIViewController {
    
    @IBOutlet weak var leftImageButton: UIButton!
    @IBOutlet weak var storeButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet var label: UILabel!
    @IBOutlet weak var minLabel: UILabel!
    @IBOutlet weak var stayLabel: UILabel!
    @IBOutlet weak var webLabel: UILabel!
    @IBOutlet weak var detailButton: UIButton!
    var searchedPlace: String = ""
    var searchedLatitude: CLLocationDegrees = 0.0
    var searchedLongitude: CLLocationDegrees = 0.0
    var min: Double = 0.0
    var stayMin: Double = 0.0
    var webURL: String = ""
    var model: VacationModel?
    var memo: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        toolBar.sizeToFit()
        let spacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
        let commitButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(commitButtonTapped))
        toolBar.items = [spacer, commitButton]
        textView.inputAccessoryView = toolBar
        leftImageButton.setImage(UIImage(systemName: "figure.walk"), for: .normal)
        
        self.label.text = self.searchedPlace
        self.textView.text = memo
        //TODO: 1.保存された情報を表示するためのラベル
        //それぞれ関連付けして以下のコードを書こう！
        self.minLabel.text = "所要時間\n\(String(self.model?.timeRequired ?? 0))min"
        self.stayLabel.text = "滞在時間\n\(String(self.model?.stayMin ?? 0))min"
        self.min = self.model?.timeRequired ?? 0
        self.stayMin = self.model?.stayMin ?? 0
        self.webURL = self.model?.websiteURL ?? ""
        let destruct = UIAction(title: "削除する", image: UIImage(systemName: "trush"), attributes: .destructive) { _ in self.deleteVacation() }
        detailButton.menu = UIMenu(title: "", children: [destruct])
        detailButton.showsMenuAsPrimaryAction = true
    }

    @objc func commitButtonTapped(){
        self.view.endEditing(true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    private func updateVacation() {
        SwiftDataService.shared.updateVacation(vacationModel: self.model!, memo: self.textView.text, timeRequired: self.min, stayMin: self.stayMin, websiteURL: self.webURL)
    }
    
    private func savedVacation() {
        SwiftDataService.shared.saveVacation(vacationName: searchedPlace, memo: textView.text, timeRequired: self.min, stayMin: self.stayMin, websiteURL: self.webURL, createdAt: Date(), latitude: self.searchedLatitude, longitude: self.searchedLongitude)
    }
    
    @IBAction func minButton(_ sender: Any) {
        AlertDialog.shared.showDatePicker(vc: self) {
            self.min = AlertDialog.shared.duration
            self.minLabel.text = "所要時間\n\(String(self.min))min"
            print(self.min)
        }
    }
    
    @IBAction func stayMinButton(_ sender: Any) {
        AlertDialog.shared.showDatePicker(vc: self) {
            self.stayMin = AlertDialog.shared.duration
            print(self.stayMin)
            self.stayLabel.text = "滞在時間\n\(String(self.stayMin))min"
            print(self.stayMin)
        }
    }
    
    @IBAction func webURLButton(_ sender: Any) {
        AlertDialog.shared.showAlert(title: "選択してください", message: "urlの変更とwebの閲覧を選択できます", viewController: self) {
            AlertDialog.shared.showAlertWithText(vc: self) {
                self.webURL = AlertDialog.shared.text
            }
        } viewWeb: {
            if let url = URL(string: self.webURL) {
                let config = SFSafariViewController.Configuration()
                config.entersReaderIfAvailable = true
                
                let vc = SFSafariViewController(url: url, configuration: config)
                self.present(vc, animated: true)
            }
        }
    }
    
    @IBAction func saveButton(_ sender: Any) {
        if model != nil {
            AlertDialog.shared.showAlertWithCancel(title: "上書きします", message: "情報を更新します", viewController: self) {
                self.updateVacation()
            }
        } else {
            AlertDialog.shared.showAlertWithCancel(title: "保存します", message: "保存しましょう", viewController: self) {
                self.savedVacation()
            }
        }
    }
    
    @IBAction func back(){
        self.dismiss(animated: true, completion: nil)
    }
    
    private func deleteVacation() {
        if self.model != nil {
            AlertDialog.shared.showAlertWithCancel(title: "データを削除しますか", message: "削除されると元に戻せません", viewController: self) {
                SwiftDataService.shared.deleteVacation(vacationModel: self.model!)
            }
        } else {
            AlertDialog.shared.showAlertWithCancel(title: "保存されてないデータは削除できません", message: "", viewController: self){
                print("データ未保存")
            }
        }
    }
}
