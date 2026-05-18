

import UIKit
import CoreData

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // Свойства для поиска
    private let searchController = UISearchController(searchResultsController: nil)
    private var filteredPlaces: [Place] = []
    
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    // свойства
    var context: NSManagedObjectContext!
    private var places: [Place] = []
    private var ascendingSorting = true
   
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet var reversedSortingButton: UIBarButtonItem!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if context == nil {
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            context = appDelegate?.coreDataStack.context
        }
        // Настройка search controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        setupInitialData()
        fetchData()
    }
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Если поиск активен, возвращаем количество из отфильтрованного массива
        if isFiltering {
            return filteredPlaces.count
        }
        return places.isEmpty ? 0 : places.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        
        // ВЫБОР ОБЪЕКТА: фильтрованный или обычный
        let place = isFiltering ? filteredPlaces[indexPath.row] : places[indexPath.row]
        
        cell.nameLabel.text = place.name
        cell.locationLabel.text = place.location
        cell.typeLabel.text = place.type
        
        if let imageData = place.imageData {
            cell.imageOfPlace.image = UIImage(data: imageData)
        } else {
            cell.imageOfPlace.image = UIImage(named: "imagePlaceholder")
        }
        
        cell.imageOfPlace.layer.cornerRadius = cell.imageOfPlace.frame.size.height / 2
        cell.imageOfPlace.clipsToBounds = true
        
        // Передаем рейтинг из Core Data (Int16) в контроллер звезд (Int)
            cell.cellRatingControl.rating = Int(place.rating)
        
        return cell
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
                              location: "Ташкент",
                              type: "Ресторан",
                              image: image,
                              context: context,
                              rating: Double(Int16()))
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
        guard let context = context, let segmented = segmentedControl else { return }
        
        let fetchRequest: NSFetchRequest<Place> = Place.fetchRequest()
        
        // Выбираем поле для сортировки
        let sortKey = segmented.selectedSegmentIndex == 0 ? "date" : "name"
        
        // Используем  переменную ascendingSorting для направления
        let sortDescriptor = NSSortDescriptor(key: sortKey, ascending: ascendingSorting)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
       // fetchRequest.predicate = compoundPredicate

        fetchRequest.predicate = nil
        
        do {
            places = try context.fetch(fetchRequest)
            tableView.reloadData()
        } catch {
            print("Ошибка Core Data: \(error)")
        }
    }
    

    
    // MARK: - Table view delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
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
        // Проверяем оба возможных идентификатора (для редактирования и для добавления)
        if segue.identifier == "showDetail" || segue.identifier == "addItem" {
            
            let destination = segue.destination
            let newPlaceVC = (destination as? UINavigationController)?.viewControllers.first as? NewPlaceViewController ?? destination as? NewPlaceViewController
            
            // ПЕРЕДАЕМ КОНТЕКСТ ВСЕГДА (и для новых, и для старых)
            newPlaceVC?.context = self.context
            
            //  ПЕРЕДАЕМ ОБЪЕКТ ТОЛЬКО ДЛЯ РЕДАКТИРОВАНИЯ. Oбновим получение объекта place, чтобы при нажатии на ячейку в режиме поиска открывалось правильное место:
            
            if segue.identifier == "showDetail",
                let indexPath = tableView.indexPathForSelectedRow {
                // Используем ту же логику выбора
                newPlaceVC?.currentPlace = isFiltering ? filteredPlaces[indexPath.row] : places[indexPath.row]
            }

        }
    }
    
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        
        guard let newPlaceVC = segue.source as? NewPlaceViewController else { return }
        
        newPlaceVC.savePlace() // Сохраняем данные
        tableView.reloadData()
        fetchData()            // перезагружаем данные из Core Data
    }
    
    
    
    @IBAction func sortSelection(_ sender: UISegmentedControl) {
        fetchData()
    }
    
    @IBAction func reversedSorting(_ sender: Any) {
        //  Меняем значение на противоположное
        ascendingSorting.toggle()
        
        // Меняем иконку в зависимости от состояния
            if ascendingSorting {
                // Иконка для сортировки по возрастанию (А-Я)
                reversedSortingButton.image = UIImage(systemName: "arrow.down")
            } else {
                // Иконка для сортировки по убыванию (Я-А)
                reversedSortingButton.image = UIImage(systemName: "arrow.up")
            }
            
            // Обновляем данные
        fetchData()
    }
}

extension MainViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    private func filterContentForSearchText(_ searchText: String) {
            // Если строка поиска пуста, фильтровать нечего
            if searchText.isEmpty {
                filteredPlaces = []
                tableView.reloadData()
                return
            }

            // Создаем запрос к Core Data
            let fetchRequest: NSFetchRequest<Place> = Place.fetchRequest()
            
            // Предикат для поиска по трем полям
            // [cd] означает Case и Diacritic insensitive (игнорирует регистр и ударения)
            fetchRequest.predicate = NSPredicate(format: "name CONTAINS[cd] %@ OR location CONTAINS[cd] %@ OR type CONTAINS[cd] %@", searchText, searchText, searchText)
            
            // Добавляем ту же сортировку, что и в основном списке
            let sortKey = segmentedControl.selectedSegmentIndex == 0 ? "date" : "name"
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: sortKey, ascending: ascendingSorting)]
            
            do {
                // Выполняем поиск в базе
                filteredPlaces = try context.fetch(fetchRequest)
            } catch {
                print("Ошибка поиска в Core Data: \(error)")
            }
       
        tableView.reloadData()
    }
    
}

