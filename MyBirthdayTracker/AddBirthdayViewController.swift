//
//  ViewController.swift
//  MyBirthdayTracker
//
//  Created by Алексей Моторин on 12.10.2022.
//

import UIKit
import CoreData
import UserNotifications

class AddBirthdayViewController: UIViewController {
    
    
    // MARK: - IBOutlet
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    // MARK: - ovveride methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePicker.maximumDate = Date()
        
    }
    
    // MARK: - IBAction
    @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    
    @IBAction func saveTapped(_ sender: UIBarButtonItem) {
    
        guard firstNameTextField.text != "" , lastNameTextField.text != "" else { return }
        
        guard let application = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = application.persistentContainer.viewContext
        
        let birthDate = datePicker.date
        
        let newBirthday = Birthday(context: context)
        newBirthday.firstName = firstNameTextField.text
        newBirthday.lastName = lastNameTextField.text
        newBirthday.birthDate = birthDate
        newBirthday.birthdayID = UUID().uuidString
        
        if let birthdayID = newBirthday.birthdayID {
            print("BirthdayID: \(birthdayID)")
        }
        
        do {
            try context.save()
        
            let message = "Сегодня день рождения у \(newBirthday.firstName ?? "") \(newBirthday.lastName ?? "") не забудь поздравить"
            let content = UNMutableNotificationContent()
            content.body = message
            content.sound = .default
            var dateConponents = Calendar.current.dateComponents([.month, .day], from: birthDate)
            dateConponents.hour = 11
            dateConponents.minute = 0
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateConponents, repeats: true)
            
            if let identifire = newBirthday.birthdayID {
                let request = UNNotificationRequest(identifier: identifire,
                                                    content: content,
                                                    trigger: trigger)
                let center = UNUserNotificationCenter.current()
                center.add(request)
            }
            
            print("День рождения сохранен")
        } catch let error {
            print("Не удалось сохранить, ошибка: \(error)")
        }
        
        dismiss(animated: true)
    }
    
}

