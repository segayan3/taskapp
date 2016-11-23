//
//  Task.swift
//  taskapp
//
//  Created by Naohiro Segawa on 2016/11/22.
//  Copyright © 2016年 segayan3. All rights reserved.
//

import RealmSwift

class Task: Object {
    // 管理用ID プライマリーキー
    dynamic var id = 0
    
    // タイトル
    dynamic var title = ""
    
    // 内容
    dynamic var contents = ""
    
    // 日時
    dynamic var date = Date()
    
    // idをプライマリーキーとして設定
    override static func primaryKey() -> String?{
        return "id"
    }

}
