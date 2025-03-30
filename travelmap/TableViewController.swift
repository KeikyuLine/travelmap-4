//
//  TableViewController.swift
//  travelmap
//
//  Created by 齋藤温仁 on 2024/12/16.
//

import UIKit

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate{
    
    @IBOutlet var travelTableView: UITableView!
    //追加①
    var TODO = ["牛乳を買う", "掃除をする", "アプリ開発の勉強をする"] //追加②

    //最初からあるコード
    override func viewDidLoad() {
        super.viewDidLoad()
        travelTableView.delegate = self
        travelTableView.dataSource = self
    }

    //最初からあるコード
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //追加③ セルの個数を指定するデリゲートメソッド（必須）
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TODO.count
    }

    //追加④ セルに値を設定するデータソースメソッド（必須）
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを取得する
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        // セルに表示する値を設定する
        cell.textLabel!.text = TODO[indexPath.row]
        return cell
    }
    
    @IBAction func aleat(_ sender: Any) {
        
        var textFieldOnAlert = UITextField()

        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alert.title = "ここにタイトル"
        alert.message = "メッセージ"
        
        alert.addTextField { TextField in

           
               
                textFieldOnAlert = TextField
                textFieldOnAlert.returnKeyType = .done
            }
            

        
        //追加ボタン
        alert.addAction(
            UIAlertAction(
                title: "追加",
                style: .default,
                
                handler: { (action) in
                    print(textFieldOnAlert.text!)
                    self.TODO.append(textFieldOnAlert.text!)
        })
        )
        
        //キャンセルボタン
        alert.addAction(
        UIAlertAction(
            title: "キャンセル",
            style: .cancel,
            handler: {(action) -> Void in
                self.hello(action.title!)
        })
        )
        
        
        
        //アラートが表示されるごとにprint
        self.present(
        alert,
        animated: true,
        completion: {
            print("アラートが表示された")
        })
    }

    func hello(_ msg:String){
        print(msg)
    }
    
 
}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

//}
