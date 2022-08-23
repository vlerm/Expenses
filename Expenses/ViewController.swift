//
//  ViewController.swift
//  Expenses
//
//  Created by Вадим Лавор on 23.08.22.
//

import UIKit
import RealmSwift

class ViewController: UIViewController {
    
    let realm = try! Realm()
    var expenses: Results<Expenses>!
    
    private var stillTyping = false
    private var categoryName = String()
    private var displayValue = Int()
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var displayLabel: UILabel!
    @IBOutlet weak var setLimitLabel: UIButton!
    @IBOutlet weak var eatButton: UIButton!
    @IBOutlet weak var clothesButton: UIButton!
    @IBOutlet weak var connectionButton: UIButton!
    @IBOutlet weak var entertaimentButton: UIButton!
    @IBOutlet weak var beautyButton: UIButton!
    @IBOutlet weak var autoButton: UIButton!
    @IBOutlet weak var categoriesStackView: UIStackView!
    @IBOutlet var limitLabel: UILabel!
    @IBOutlet var canExpensesLabel: UILabel!
    @IBOutlet var expenseByCheckLabel: UILabel!
    @IBOutlet var allExpensesLabel: UILabel!
    @IBOutlet var numberFromKeyboard: [UIButton]! {
        didSet {
            for button in numberFromKeyboard {
                button.layer.cornerRadius = 10
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLeftLabels()
        setMonthlyExpenses()
        setDefaultConfigation()
    }
    
    @IBAction func numberButtonClicked(_ sender: UIButton) {
        guard let number = sender.currentTitle else { return }
        guard let displayText = displayLabel.text else { return }
        if stillTyping {
            if displayText.count < 15 {
                displayLabel.text = displayText + number
            }
        } else {
            if sender.currentTitle == "0" {
                return
            } else {
                displayLabel.text = number
                stillTyping = true
            }
        }
    }
    
    @IBAction func resetButtonClicked(_ sender: UIButton) {
        displayLabel.text = "0"
        stillTyping = false
    }
    
    @IBAction func categoryButtonClicked(_ sender: UIButton) {
        categoryName = sender.currentTitle!
        displayValue = Int(displayLabel.text!) ?? 0
        displayLabel.text = "0"
        stillTyping = false
        let value = Expenses(value: ["\(categoryName)", displayValue])
        try! realm.write {
            realm.add(value)
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: [IndexPath.init(row: 0, section: 0)], with: .automatic)
            self.tableView.endUpdates()
        }
        self.setLeftLabels()
        tableView.reloadData()
    }
    
    @IBAction func setLimitButtonClicked(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Установить лимит", message: "Введите сумму и количество дней" , preferredStyle: .alert)
        let addAlertAction = UIAlertAction(title: "Установить", style: .default) { action in
            let limitSum = alertController.textFields?[0].text
            let limitDay = alertController.textFields?[1].text
            guard limitDay != "" && limitSum != "" else { return }
            self.limitLabel.text = limitSum
            if let day = limitDay {
                let dateNow = Date()
                let lastDay: Date = dateNow.addingTimeInterval(60*60*24*Double(day)!)
                let limit = self.realm.objects(Limit.self)
                if limit.isEmpty == true {
                    let value = Limit(value: [self.limitLabel.text!, dateNow, lastDay])
                    try! self.realm.write {
                        self.realm.add(value)
                    }
                } else {
                    try! self.realm.write {
                        limit[0].summa = self.limitLabel.text!
                        limit[0].date = dateNow as NSDate
                        limit[0].lastDay = lastDay as NSDate
                    }
                }
            }
            self.setLeftLabels()
        }
        alertController.addTextField { money in
            money.placeholder = "Сумма"
            money.keyboardType = .asciiCapableNumberPad
        }
        alertController.addTextField { day in
            day.placeholder = "Количество дней"
            day.keyboardType = .asciiCapableNumberPad
        }
        let cancelAlertAction = UIAlertAction(title: "Отмена", style: .default) { _ in }
        alertController.addAction(cancelAlertAction)
        alertController.addAction(addAlertAction)
        present(alertController, animated: true, completion: nil)
    }
    
    private func setLeftLabels() {
        let limit = self.realm.objects(Limit.self)
        guard limit.isEmpty == false else { return }
        limitLabel.text = limit[0].summa
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        let firstDay = limit[0].date as Date
        let lastDay = limit[0].lastDay as Date
        let firstComponents = calendar.dateComponents([.year, .month, .day], from: firstDay)
        let lastComponents = calendar.dateComponents([.year, .month, .day], from: lastDay)
        let startDate = formatter.date(from: "\(firstComponents.year!)/\(firstComponents.month!)/\(firstComponents.day!) 00:00")!
        let endDate = formatter.date(from: "\(lastComponents.year!)/\(lastComponents.month!)/\(lastComponents.day!) 23:59")
        let filtredLimit: Int = realm.objects(Expenses.self).filter("self.data >= %@ && self.data <= %@", startDate, endDate!).sum(ofProperty: "cost")
        expenseByCheckLabel.text = "\(filtredLimit)"
        let limitMoney = Int(limitLabel.text!) ?? Int()
        let canExpenseMoney = Int(expenseByCheckLabel.text!) ?? Int()
        let diff = limitMoney - canExpenseMoney
        canExpensesLabel.text = "\(diff)"
        let allExpenses : Int = realm.objects(Expenses.self).sum(ofProperty: "cost")
        allExpensesLabel.text = "\(allExpenses)"
    }
    
    func setMonthlyExpenses() {
        let nowDate = Date()
        let currentCalendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
        let dateComponents = currentCalendar.dateComponents([.year, .month, .day], from: nowDate)
        let dayMonth: Int
        if Int(dateComponents.year!) % 4 == 0 && dateComponents.month == 2 {
            dayMonth = 29
        } else {
            switch dateComponents.month {
            case 1: dayMonth = 31
            case 2: dayMonth = 28
            case 3: dayMonth = 31
            case 4: dayMonth = 30
            case 5: dayMonth = 31
            case 6: dayMonth = 30
            case 7: dayMonth = 31
            case 8: dayMonth = 31
            case 9: dayMonth = 30
            case 10: dayMonth = 31
            case 11: dayMonth = 30
            case 12: dayMonth = 31
            default: return
            }
        }
    }
    
    func setDefaultConfigation(){
        eatButton.layer.cornerRadius = 10
        eatButton.clipsToBounds = true
        clothesButton.layer.cornerRadius = 10
        clothesButton.clipsToBounds = true
        connectionButton.layer.cornerRadius = 10
        connectionButton.clipsToBounds = true
        entertaimentButton.layer.cornerRadius = 10
        entertaimentButton.clipsToBounds = true
        beautyButton.layer.cornerRadius = 10
        beautyButton.clipsToBounds = true
        autoButton.layer.cornerRadius = 10
        autoButton.clipsToBounds = true
        expenses = realm.objects(Expenses.self)
        limitLabel.layer.cornerRadius = 20
        categoriesStackView.clipsToBounds = true
        setGradientBackground(view: self.view, colorTop: UIColor(red: 210/255, green: 109/255, blue: 180/255, alpha: 1).cgColor, colorBottom: UIColor(red: 52/255, green: 148/255, blue: 230/255, alpha: 1).cgColor)
        setLimitLabel.layer.cornerRadius = 10
        setLimitLabel.clipsToBounds = true
    }
    
    func setGradientBackground(view: UIView, colorTop: CGColor = UIColor(red: 29.0/255.0, green: 34.0/255.0, blue:234.0/255.0, alpha: 1.0).cgColor, colorBottom: CGColor = UIColor(red: 38.0/255.0, green: 0.0/255.0, blue: 6.0/255.0, alpha: 1.0).cgColor) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expenses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CategoryExpensesTableViewCell
        let expenses = expenses.sorted(byKeyPath: "data", ascending: false)[indexPath.row]
        cell.nameCategoryLabel.text = expenses.category
        cell.expensesCategoryLabel.text = String(expenses.cost)
        switch expenses.category {
        case "Еда": cell.categoryImageView.image = #imageLiteral(resourceName: "Category_Еда")
        case "Одежда": cell.categoryImageView.image = #imageLiteral(resourceName: "Category_Одежда")
        case "Связь": cell.categoryImageView.image = #imageLiteral(resourceName: "Category_Связь")
        case "Досуг": cell.categoryImageView.image = #imageLiteral(resourceName: "Category_Досуг")
        case "Красота": cell.categoryImageView.image = #imageLiteral(resourceName: "Category_Красота")
        case "Авто": cell.categoryImageView.image = #imageLiteral(resourceName: "Category_Авто")
        default:
            cell.categoryImageView.image = UIImage(named: "folder")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteConfiguration = UISwipeActionsConfiguration(actions: [UIContextualAction(style: .destructive, title: "Delete", handler: { [weak self] (action, view, completionHandler) in
            guard let editingRow = self?.expenses.sorted(byKeyPath: "data", ascending: false)[indexPath.row] else { return }
            try! self?.realm.write {
                self?.realm.delete(editingRow)
                self?.setLeftLabels()
                tableView.reloadData()
            }
            completionHandler(true)
        })])
        return deleteConfiguration
    }
    
}
