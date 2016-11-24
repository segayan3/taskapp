//
//  InputViewController.swift
//  taskapp
//
//  Created by Naohiro Segawa on 2016/11/22.
//  Copyright © 2016年 segayan3. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class InputViewController: UIViewController {

    @IBOutlet weak var categoryField: UITextField!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var task: Task! // viewControllerから受け取ったtaskを保存するパラメーター
    var realm = try! Realm() // モデルクラスのインスタンスを作成
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // 背景をタップしたらdismissKeyboardメソッドを呼ぶ
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        // ViewControllerから受け取ったtaskをUIに設定
        categoryField.text = task.category
        titleTextField.text = task.title
        contentsTextView.text = task.contents
        datePicker.date = task.date as Date
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // キーボードを閉じる
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // UIViewControllerのメソッドをOverrideするメソッド
    override func viewWillDisappear(_ animated: Bool) {
        // 画面を閉じる前にUIの内容をDBに保存
        try! realm.write {
            task.category = categoryField.text!
            task.title = titleTextField.text!
            task.contents = contentsTextView.text
            task.date = datePicker.date as Date
            realm.add(task, update: true)
        }
        
        setNotification(task: task) // 画面を閉じる前にローカル通知を登録するメソッドを呼ぶ
        
        super.viewWillDisappear(animated)
    }
    
    // タスクのローカル通知を登録するメソッド
    func setNotification(task: Task){
        let content = UNMutableNotificationContent() // 通知内容を設定するインスタンス
        
        // 通知内容を設定
        content.title = task.title
        content.body = task.contents
        content.sound = UNNotificationSound.default()
        
        // ローカル通知が発動するtrigger(日付)を作成
        let calender = Calendar.current
        let dateComponents = calender.dateComponents([.year, .month, .day, .hour, .minute], from: task.date as Date)
        let trigger = UNCalendarNotificationTrigger.init(dateMatching: dateComponents, repeats: false)
        
        // ローカル通知を作成(identifierが同じ場合は上書きされる)
        let request = UNNotificationRequest.init(identifier: String(task.id), content: content, trigger: trigger)
        
        // ローカル通知を登録
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error) in print(error ?? "") }
        
        // 未通知のローカル通知一覧をログ出力
        center.getPendingNotificationRequests { (requests) in
            for request in requests {
                print("/-------------")
                print(request)
                print("-------------/")
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
