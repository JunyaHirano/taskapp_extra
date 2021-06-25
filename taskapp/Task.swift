//
//  Task.swift
//  taskapp
//
//  Created by DS_JH on 2021/04/23.
//

import RealmSwift

class Task: Object {
    //管理用　ID プライマリーキー
    @objc dynamic var id = 0
    
    //タイトル
    @objc dynamic var title = ""
    
    //タスクに設定できるカテゴリ自体はひとつなのでテキスト
    //@objc dynamic var category = ""
     
    //内容
    @objc dynamic var contents = ""
    
    //日時
    @objc dynamic var date = Date()
    
    // idをプライマリーキーとして設定
    override static func primaryKey() -> String? {
        return "id"
    }
}

