//
//  Limit.swift
//  Expenses
//
//  Created by Вадим Лавор on 23.08.22.
//

import RealmSwift

class Limit: Object {
    
    @objc dynamic var summa = String()
    @objc dynamic var date = NSDate()
    @objc dynamic var lastDay = NSDate()
    
}
