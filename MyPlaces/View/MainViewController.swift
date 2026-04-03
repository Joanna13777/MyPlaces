//
//  MainViewController.swift
//  MyPlaces
//
//  Created by Жанна Сергеевна  on 09/03/26.
//

import UIKit
import CoreData

class MainViewController: UITableViewController {
    
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
                                  location: "Уфа",
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

    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
//        guard let newPlace = segue.source as? NewPlaceViewController else { return }
        fetchData()
//        DispatchQueue.main.async {
        }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showNewPlace" {
            let destination = segue.destination
            
            // 2. Если NewPlaceViewController находится внутри NavigationController (как в Storyboard)
                    if let navVC = destination as? UINavigationController,
                       let newPlaceVC = navVC.viewControllers.first as? NewPlaceViewController {
                        
                        // ПЕРЕДАЕМ КОНТЕКСТ
                        newPlaceVC.context = self.context
                        print("✅ Контекст успешно передан в NewPlaceViewController через NavVC")
                        
                    } else if let newPlaceVC = destination as? NewPlaceViewController {
                        // Если переход идет напрямую (без NavVC)
                        newPlaceVC.context = self.context
                        print("✅ Контекст успешно передан напрямую")
                    }
                }
            }
            
//            if let navVC = destination as? UINavigationController,
//                       let newPlaceVC = navVC.viewControllers.first as? NewPlaceViewController {
//                        newPlaceVC.context = self.context
//                    } else if let newPlaceVC = destination as? NewPlaceViewController {
//                        newPlaceVC.context = self.context
//            }
//        }
//    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.isEmpty ? 0 : places.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        
        let place = places[indexPath.row]
        
        cell.nameLabel?.text = place.name
        cell.locationLabel?.text = place.location
        cell.typeLabel?.text = place.type
        
        if let data = place.imageData {
            cell.imageOfPlace.image = UIImage(data: data)
        } else {
            cell.imageOfPlace.image = UIImage(named: "imagePlaceholder")
        }
        
        cell.imageOfPlace.layer.cornerRadius = cell.imageOfPlace.frame.size.height / 2
        cell.imageOfPlace.clipsToBounds = true
        
        return cell
    }
}
