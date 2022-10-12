//
//  BirthdayTableViewController.swift
//  MyBirthdayTracker
//
//  Created by Алексей Моторин on 12.10.2022.
//

import UIKit
import CoreData
import UserNotifications

class BirthdayTableViewController: UITableViewController {
    
    // MARK: - private property
    private var birthday = [Birthday]()
    private let dateFormatter = DateFormatter()
    
    // MARK: - ovveride methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter.timeStyle = .none
        dateFormatter.dateFormat = "dd MMMM yyyy "
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let application = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = application.persistentContainer.viewContext
        
        let fetchRequest = Birthday.fetchRequest() as NSFetchRequest<Birthday>
        
        let sortDescriptorFirstName = NSSortDescriptor(key: "firstName", ascending: true)
        let sortDescriptorLastName = NSSortDescriptor(key: "lastName", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptorFirstName, sortDescriptorLastName]
        
        do {
            birthday = try context.fetch(fetchRequest)
        } catch let error {
            print("Не удалось загрузить данные, ошибка \(error)")
        }
        
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        birthday.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let birthday = birthday[indexPath.row]
        
        guard let firstName = birthday.firstName, let lastName = birthday.lastName, let birthday = birthday.birthDate else { return cell }
        
        
        var configuration = cell.defaultContentConfiguration()
        configuration.text = firstName + " " + lastName
        configuration.secondaryText = dateFormatter.string(from: birthday)
        cell.contentConfiguration = configuration
        cell.selectionStyle = .none
        return cell
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if birthday.count > indexPath.row {
                let birthday = birthday[indexPath.row]
                
                if let identifire = birthday.birthdayID {
                    let center = UNUserNotificationCenter.current()
                    center.removePendingNotificationRequests(withIdentifiers: [identifire])
                }
                
                guard let application = UIApplication.shared.delegate as? AppDelegate else { return }
                let context = application.persistentContainer.viewContext
                
                context.delete(birthday)
                
                do {
                    try context.save()
                    print("День рождения удален")
                } catch let error {
                    print("Удаление не было сохранено, ошибка: \(error)")
                }
                
                self.birthday.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
        }
    }
}
