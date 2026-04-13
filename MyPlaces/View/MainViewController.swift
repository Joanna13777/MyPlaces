//
//  MainViewController.swift
//  MyPlaces
//
//  Created by Жанна Сергеевна  on 09/03/26.
//

import UIKit
import CoreData

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    var context: NSManagedObjectContext!
    var places: [Place] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if context == nil {
            let appDelegate = UIApplication.shared.delegate as? CoreDataStack
            context = appDelegate?.persistentContainer.viewContext
        }
        
        setupInitialData()
        fetchData()
        
    }
    
    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.isEmpty ? 0 : places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        
        let place = places[indexPath.row]
        
        cell.nameLabel.text = place.name
        cell.locationLabel.text = place.location
        cell.typeLabel.text = place.type
        cell.imageOfPlace.image = UIImage(data: place.imageData!)
        
        cell.imageOfPlace.layer.cornerRadius = cell.imageOfPlace.frame.size.height / 2
        cell.imageOfPlace.clipsToBounds = true

        return cell
    }
    
    // MARK: - Table view Delegate
    
//    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
//        
//        let place = places[indexPath.row]
//        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (_, _) in
//            
//            tableView.deleteRows(at: [indexPath], with: .automatic)
//            return [deleteAction]
            
            // MARK: - Table view data source
            
            
            private func setupInitialData() {
                let fetchRequest: NSFetchRequest<Place> = Place.fetchRequest()
                
                do {
                    // Проверяем, пуста ли база
                    let count = try context.count(for: fetchRequest)
                    
                    if count == 0 {
                        // Обращаемся к списку имен прямо из модели Place
                        for name in Place.restaurantNames {
                            
                            // Берем картинку из Assets по имени
                            let image = UIImage(named: name)
                            
                            // Создаем объект Core Data
                            _ = Place(name: name,
                                      location: "Ташкент",
                                      type: "Ресторан",
                                      image: image,
                                      context: context)
                        }
                        
                        // Сохраняем всё в память устройства
                        try context.save()
                        print("✅ База успешно инициализирована данными из Place.restaurantNames")
                    }
                } catch {
                    print("Ошибка инициализации: \(error.localizedDescription)")
                }
            }
            
            // MARK: - Data Fetching
            func fetchData() {
                let fetchRequest: NSFetchRequest<Place> = Place.fetchRequest()
                
                // Сортировка по дате (новые сверху)
                let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
                fetchRequest.sortDescriptors = [sortDescriptor]
                
                do {
                    places = try context.fetch(fetchRequest)
                    print("🔎 В базе сейчас объектов: \(places.count)")
                    tableView.reloadData()
                    
                } catch {
                    print("Ошибка загрузки: \(error)")
                }
            }
            
            
            // MARK: - Delete Action
            
            func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
                
                if editingStyle == .delete {
                    let placeToDelete = places[indexPath.row]
                    context.delete(placeToDelete)
                    
                    //  Сохраняем изменения в базе данных
                    do {
                        try context.save()
                        print("✅ Объект успешно удален из базы")
                        places.remove(at: indexPath.row)
                        
                        tableView.deleteRows(at: [indexPath], with: .fade)
                        
                    } catch {
                        print("❌ Ошибка при удалении: \(error.localizedDescription)")
                    }
                }
            }
            
            func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
                return "Удалить"
            }
            
            // MARK: - Navigation
            
            override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
                // 1. Проверяем переход к экрану добавления/редактирования. проверьте этот ID в сториборде у стрелочки "+"
                if segue.identifier == "showDetail" {
                    let destination = segue.destination
                    
                    // Достаем NewPlaceViewController (учитывая, что он может быть в Navigation Controller)
                    let newPlaceVC = (destination as? UINavigationController)?.viewControllers.first as? NewPlaceViewController ?? destination as? NewPlaceViewController
                    
                    // ПЕРЕДАЕМ КОНТЕКСТ
                    newPlaceVC?.context = self.context
                    
                    // Если это редактирование, передаем и сам объект
                    if let indexPath = tableView.indexPathForSelectedRow {
                        newPlaceVC?.currentPlace = places[indexPath.row]
                    }
                }
            }
            
            
            @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
                
                guard let newPlaceVC = segue.source as? NewPlaceViewController else { return }
                
                newPlaceVC.savePlace()
                fetchData()
                
            }
        }
  
