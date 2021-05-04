//
//  ViewController.swift
//  taskapp
//
//  Created by DS_JH on 2021/04/22.
//

import UIKit
import RealmSwift
import UserNotifications

class ViewController: UIViewController , UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate { //UISearchBarデリゲート追加
    
    @IBOutlet weak var tableView: UITableView!
    //検索ボックスを接続
    @IBOutlet weak var searchBox: UISearchBar!
    
    // Realmインスタンスを取得する
    let realm = try! Realm()
    
    //DB内のタスクが格納されるリスト taskArray
    //byKeyPath dateで日付の近い順でソート:昇順
    //ascending trueで 以降内容をアプデするとリスト内は自動的に更新される
    var taskArray = try! Realm().objects(Task.self)
    
    // taskArrayに代入するresultを定義
    var result = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        //検索バーのデリゲートを受け取る
        searchBox.delegate = self
    }
    
    //検索バーメソッド 検索バーの値を取得しrelmの絞り込みを指定して値を返す taskArrayに代入する
      func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
          if searchText.isEmpty {
             result = realm.objects(Task.self)
          } else {
             result = realm.objects(Task.self).filter("category CONTAINS %@" , searchText)
          }
        taskArray = result
        tableView.reloadData()
      }

    //データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return taskArray.count
    }

    //各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //再利用可能な cellを得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell" , for: indexPath)
        
       // Cellに値を設定する.
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.title
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateString:String = formatter.string(from: task.date)
        cell.detailTextLabel?.text = dateString
        
        return cell
    }
    
    //各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue",sender: nil) //
    }
    //segue で画面遷移するときに呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let inputViewController:InputViewController = segue.destination as! InputViewController
        
        if segue.identifier == "cellSegue" {
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        } else {
            let task = Task()
            
            let allTasks = realm.objects(Task.self)
            if allTasks.count != 0 {
                task.id = allTasks.max(ofProperty: "id")! + 1
            }
            
            inputViewController.task = task
        }
    }
    //各セルを削除可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCell.EditingStyle{
        return .delete
    }
    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            //削除するタスクを取得する
            let task = self.taskArray[indexPath.row]
            
            //ローカル通知をキャンセルする
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            
            // データベースから削除する
            try! realm.write {
                self.realm.delete(self.taskArray[indexPath.row])
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            //未通知のローカル通知一覧をログ出力
            center.getPendingNotificationRequests { (requests: [ UNNotificationRequest]) in
                for request in requests {
                    print("/---------------")
                    print(request)
                    print("----------------/")
                }
            }
        }
    }
    //入力画面から戻った時に TableViewを更新させる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    //確定して戻るボタン
    @IBAction func unwind(_ segue: UIStoryboardSegue){
        
    }
    
}

