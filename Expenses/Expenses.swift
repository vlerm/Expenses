//
//  Expenses.swift
//  Expenses
//
//  Created by Вадим Лавор on 23.08.22.
//

import RealmSwift

class Expenses: Object {
    
    @objc dynamic var category = String()
    @objc dynamic var cost = 1
    @objc dynamic var data = NSDate()
    
}
