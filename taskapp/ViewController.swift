//
//  ViewController.swift
//  taskapp
//
//  Created by Naohiro Segawa on 2016/11/22.
//  Copyright © 2016年 segayan3. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    // Realmインスタンスを作成
    let realm = try! Realm()
    
    // DB内のデータを取得して格納する配列
    // 日付の近い順でソート:降順
    // 以降、内容をアップデートするとリストが自動更新される
    let taskArray = try! Realm().objects(Task.self).sorted(byProperty: "date", ascending: false)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // UITableViewのデリゲート先をこのコントローラーに設定
        tableView.delegate = self
        tableView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UITableViewDataSourceプロトコルのメソッド
    // データの数(=セルの数)を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count
    }
    
    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能なcellを得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        // cellに値を設定する
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.title
        
        print("indexPathの中身\(indexPath)")
        print("taskArrayの中身\(taskArray[indexPath.row])")
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm" // 日時のフォーマットを決定
        
        let dateString: String = formatter.string(from: task.date as Date)
        cell.detailTextLabel?.text = dateString
        
        return cell
    }
    
    // MARK: UITableViewDelegateプロトコルのメソッド
    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // segueのIDを選択して遷移
        performSegue(withIdentifier: "cellSegue", sender: nil)
    }
    
    // セルが削除可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.delete
    }
    
    // Deleteボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if(editingStyle == UITableViewCellEditingStyle.delete) {
            // 削除されるタスクを取得する
            let task = taskArray[indexPath.row]
            
            //　ローカル通知をキャンセルする
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            
            // DBから削除する
            try! realm.write {
                self.realm.delete(self.taskArray[indexPath.row])
                tableView.deleteRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.fade)
            }
            
            // 未通知のローカル通知一覧をログ出力
            center.getPendingNotificationRequests { (requests) in
                for request in requests {
                    print("/----------")
                    print(request)
                    print("----------/")
                }
            }
        }

    }
    
    // MARK: UIViewControllerをOverrideするメソッド
    // セグエで画面遷移する際、遷移先にデータを受け渡すメソッド
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // 遷移先のコントローラーのインスタンスを作成
        let inputViewController: InputViewController = segue.destination as! InputViewController
        
        // セルをタップして遷移する場合と、+ボタンで遷移する場合で受け渡すデータを切り替える
        if(segue.identifier == "cellSegue") { // セルをタップしてデータを受け渡す場合
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        } else { // +をタップしてデータを受け渡す場合
            let task = Task()
            task.date = Date() // 初期データとして日時を渡す
            
            if(taskArray.count != 0) { // １つ目のデータ入力ではない場合は、idに最新のidを設定
                task.id = taskArray.max(ofProperty: "id")! + 1
            }
            
            inputViewController.task = task
        }
    }
    
    // 入力画面から戻ってきた時にtableViewを更新するメソッド
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
}

