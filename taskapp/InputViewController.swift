//
//  InputViewController.swift
//  taskapp
//
//  Created by DS_JH on 2021/04/23.
//

import UIKit
import RealmSwift
import UserNotifications

class InputViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    //UIPickerViewのデリゲートとプロトコル追加
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    //カテゴリを選択（ピッカー）
    @IBOutlet weak var categoryPicker: UIPickerView!
    
    let realm = try! Realm()
    var task: Task!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
        //背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        titleTextField.text = task.title
        contentsTextView.text = task.contents
        datePicker.date = task.date
        
        
    }
    
    //カテゴリ表示部分、ifでカテゴリがひとつもない場合は「カテゴリを追加してください」という表示が必要
    //let category = Array(task.category)
    //仮の配列をいれておく
    let categories = [
        "筋トレ", "買い物", "開発", "勉強", "仕事"
    ]
    
    // カテゴリUIPickerViewの列数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    // 行数、要素の全数を返す
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component:Int) -> Int {
      return categories.count
    }
    //UIPickerViewに最初の表示をする
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories[row]
    }
    // UIPickerViewのRowが選択された時の処理
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
     //選択されたカテゴリラベルをtaskの方のカテゴリに書き込む（確定ボタン押下時に書き込む必要がありそう）
    // task.category = categories[row]

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        try! realm.write {
            self.task.title = self.titleTextField.text!
            self.task.contents = self.contentsTextView.text
            self.task.date = self.datePicker.date
            //カテゴリ追加
           // self.task.category = self.categoryTextField.text!
            self.realm.add(self.task, update: .modified)
        }
        
        setNotification(task: task)
        super.viewWillDisappear(animated)
    }
    
    //タスクのローカル通知を登録する
    func setNotification(task: Task){
        let content = UNMutableNotificationContent()
        //タイトルと内容を設定（中身がない場合メッセージ無しで音だけの通知になるので「（xxなし）」を表示する）
        if task.title == "" {
            content.title = "（タイトルなし）"
        } else {
            content.title = task.title
        }
        
        if task.contents == "" {
            content.body = "（内容なし）"
        }
        else {
            content.body = task.contents
        }
        
//        if task.category == "" {
//            content.title = "(内容なし)"
//        }
//        else {
//            content.title = task.category
//        }
        
        content.sound = UNNotificationSound.default
        
        //ローカル通知が発動するtrigger（日付マッチ）を作成
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute] ,from: task.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        // identifier, content, triggerからローカル通知を作成（identifierが同じだとローカル通知を上書き保存）
        let request = UNNotificationRequest(identifier: String(task.id), content: content, trigger: trigger)
        
        //ローカル通知を登録
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error) in
            print(error ?? "ローカル通知登録 OK") //errorがnilならローカル通知の登録に成功したと表示します。errorが存在すればerrorを表示します。
        }
        
        //未通知のローカル通知一覧をログ出力
        center.getPendingNotificationRequests{ (requests: [UNNotificationRequest]) in
            for request in requests {
                print("/---------------")
                print(request)
                print("----------------/")
            }
        }
    }
    
    @objc func dismissKeyboard(){
        //キーボードを閉じる
        view.endEditing(true)
    }
    
    @IBAction func forCategoryView(_ sender: Any) {
        //「カテゴリを追加する」ボタン押下で遷移する処理
        //カテゴリビューコントローラーをpresentメソッドで開く
        let CategoryViewController = self.storyboard?.instantiateViewController(withIdentifier: "AddCategory")
        //presentメソッドで開く
        self.present(CategoryViewController!, animated: true, completion: nil)
        
    }


}
