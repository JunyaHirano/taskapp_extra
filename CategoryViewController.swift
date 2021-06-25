
import UIKit
import RealmSwift
import UserNotifications

class CategoryViewController: UIViewController {
    
    //カテゴリ名を入力テキストフィールド
    @IBOutlet weak var categoryTextField: UITextField!
    
    //Realmインスタンス
    let realm = try! Realm()
    //Category.swift カテゴリのインスタンス作成
    var category: Category!

    //登録カテゴリの一覧取得
    //var cateArray = try! Realm().objects(Category.self).sorted(byKeyPath: "id", ascending: true)
    
    //「追加する」ボタン押下
    @IBAction func categoryAddButton(_ sender: Any) {
        //画面を閉じて戻る処理
        self.dismiss(animated: true, completion:nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //viewを閉じる時にカテゴリラベルを新規追加する
        
        let category = Category()
        //カテゴリタスクの数に+1（カテゴリがひとつも無ければ0、1以上ならidに+1）
        let allCates = realm.objects(Category.self)
        if allCates.count != 0 {
            category.id = allCates.max(ofProperty: "id")! + 1
        }
        
        try! realm.write {
                //カテゴリラベル追加
                self.category.categoryLabel = self.categoryTextField.text!
        }
        super.viewWillDisappear(animated)
    }
    
    
   
}
