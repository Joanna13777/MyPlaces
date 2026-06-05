

import UIKit
import CoreData

class NewPlaceViewController: UITableViewController {
    
    var currentPlace: Place!
    var context: NSManagedObjectContext!
    var imageIsChanged = false
    var currentRating = 0.0
    
    @IBOutlet var saveButton: UIBarButtonItem!
    @IBOutlet var placeImage: UIImageView!
    @IBOutlet var placeName: UITextField!
    @IBOutlet var placeLocation: UITextField!
    @IBOutlet var placeType: UITextField!
    
    @IBOutlet var ratingControl: RatingControl!
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Выводит в консоль путь к папке приложения, где лежит база данных
            if let url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
                print("Путь к базе данных Core Data: \(url.path)")
            }
        
        
         // Включаем динамический перенос и автоматическую высоту ячеек
                 tableView.rowHeight = UITableView.automaticDimension
                 tableView.estimatedRowHeight = 85
        
        tableView.tableFooterView = UIView(frame: CGRect(x: 0,
                                                         y: 0,
                                                         width: tableView.frame.size.width,
                                                         height: 1))
        saveButton.isEnabled = false
        placeName.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        setupEditScreen()
    }
    
    // MARK: - Table View Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            
    
            let cameraIcon = UIImage(systemName: "camera")
            let photoIcon = UIImage(systemName: "photo.on.rectangle")
            
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            // Action для камеры
            let camera = UIAlertAction(title: "Camera", style: .default) { _ in
                self.chooseImagePicker(source: .camera)
            }
            // Безопасная установка иконки
            if let cameraIcon = cameraIcon {
                camera.setValue(cameraIcon, forKey: "image")
            }
            camera.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            // Action для фото
            let photo = UIAlertAction(title: "Photo", style: .default) { _ in
                self.chooseImagePicker(source: .photoLibrary)
            }
            if let photoIcon = photoIcon {
                photo.setValue(photoIcon, forKey: "image")
            }
            photo.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            
            actionSheet.addAction(camera)
            actionSheet.addAction(photo)
            actionSheet.addAction(cancel)
            
            present(actionSheet, animated: true)
        } else {
            view.endEditing(true)
        }
    }
     
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Передаем значение 2-х identifier при переходе на MapViewController
        guard let identifier = segue.identifier,
              let mapVC = segue.destination as? MapViewController else { return }
        
        mapVC.incomeSequeIdentifier = identifier
        mapVC.mapViewControllerDelegate = self
        
        if identifier == "showPlace" {
            // Передаем данные напрямую в свойства контроллера карты
            mapVC.placeName = placeName.text
            mapVC.placeLocation = placeLocation.text
            mapVC.placeType = placeType.text
            mapVC.placeImageData = placeImage.image?.pngData()
        }
    }
    
    func savePlace() {
        //  Проверка контекста
        guard let context = context else {
            print("DEBUG: Метод savePlace вызван. Контекст: \(context != nil)")
            return
        }
        
        // Подготавливаем данные
        let image = imageIsChanged ? placeImage.image : UIImage(named: "imagePlaceholder")
        let imageData = image?.pngData()

        // РЕЖИМ РЕДАКТИРОВАНИЯ ИЛИ СОЗДАНИЯ
        if let place = currentPlace {
            // Если currentPlace не nil, мы просто обновляем его свойства
            place.name = placeName.text ?? ""
            place.location = placeLocation.text
            place.type = placeType.text
            place.imageData = imageData
            place.rating = Int16(ratingControl.rating)
        
            // Обновляем дату, чтобы при сортировке по дате объект поднялся наверх
            place.date = Date()
            
            
            print("Режим редактирования: объект обновлен")
        } else {
            // Если currentPlace == nil, создаем новый объект
            _ = Place(name: placeName.text ?? "",
                      location: placeLocation.text,
                      type: placeType.text,
                      image: image,
                      context: context,
                      rating: Int16(ratingControl.rating))
            
            print("Режим создания: новый объект добавлен")
        }

        // ОБЩЕЕ СОХРАНЕНИЕ
        do {
            try context.save()
            print("✅ Успешно сохранено в Core Data")
        } catch {
            print("❌ Ошибка сохранения: \(error.localizedDescription)")
        }
    }
    
    private func setupEditScreen() {
        
        if currentPlace != nil {
            setupNavigationBar()
            imageIsChanged = true
            
            guard let data = currentPlace?.imageData, let image = UIImage(data: data) else { return }
            
            
            placeImage.image = image
            placeImage.contentMode = .scaleAspectFill
            placeName.text = currentPlace?.name
            placeLocation.text = currentPlace?.location
            placeType.text = currentPlace?.type
            // Переводим Int16 из базы данных в Int для кнопок со звездами
            ratingControl.rating = Int(currentPlace?.rating ?? 0)
        }
    }
    
    private func setupNavigationBar() {
        if let topItem = navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
        navigationItem.leftBarButtonItem = nil
        title = currentPlace?.name
        saveButton.isEnabled = true
    }
    
    @IBAction func cancelAction(_ segue: UIStoryboardSegue) {
        dismiss(animated: true)
    }
}

// MARK: Text field delegate
extension NewPlaceViewController: UITextFieldDelegate {
    
    // Скрываем клавиатуру по нажатию на Done
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc private func textFieldChanged() {
        
        if placeName.text?.isEmpty == false {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }
}

//MARK: Work with image
extension NewPlaceViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func chooseImagePicker(source: UIImagePickerController.SourceType) {
        
        if UIImagePickerController.isSourceTypeAvailable(source) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = source
            present(imagePicker, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        placeImage.image = info[.editedImage] as? UIImage
        placeImage.contentMode = .scaleAspectFill
        placeImage.clipsToBounds = true
        
        imageIsChanged = true
        
        dismiss(animated: true)
    }
}

// Объявим текущий класс делегатом
extension NewPlaceViewController: MapViewControllerDelegate {
    func getAddress(_ address: String?) {
        placeLocation.text = address
    }
}
