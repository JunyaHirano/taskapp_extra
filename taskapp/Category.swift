//
//  Category.swift
//  taskapp
//
//  Created by DS_JH on 2021/06/20.
//

import RealmSwift

class Category: Object {
    
    //管理用ID プライマリーキー
    @objc dynamic var id = 0
    
    //カテゴリ選択ボックス 定義 Realm Swiftでは配列（Array)が使えないのでListを使う
    @objc dynamic var categoryLabel  = ""
    
    //List定義
    //let categories = List<Categories>()
    
    // idをプライマリーキーとして設定
    override static func primaryKey() -> String? {
        return "id"
    }
    
}
