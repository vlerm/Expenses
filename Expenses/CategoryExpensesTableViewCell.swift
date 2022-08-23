//
//  CategoryExpensesTableViewCell.swift
//  Expenses
//
//  Created by Вадим Лавор on 23.08.22.
//

import UIKit

class CategoryExpensesTableViewCell: UITableViewCell {

    @IBOutlet var categoryImageView: UIImageView!
    @IBOutlet var nameCategoryLabel: UILabel!
    @IBOutlet var expensesCategoryLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.categoryImageView.layer.cornerRadius = 10
        self.categoryImageView.clipsToBounds = true
    }
    
}
