//
//  NewPlaceViewController.swift
//  MyPlaces
//
//  Created by Жанна Сергеевна  on 15/03/26.
//

import UIKit
import CoreData

class NewPlaceViewController: UITableViewController {
    
    var context: NSManagedObjectContext!
    var imageIsChanged = false
    
    @IBOutlet var saveButton: UIBarButtonItem!
    @IBOutlet var placeImage: UIImageView!
    @IBOutlet var placeName: UITextField!
    @IBOutlet var placeLocation: UITextField!
    @IBOutlet var placeType: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        saveButton.isEnabled = false
        placeName.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        
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
    
    func saveNewPlace() {
        if context == nil {
                print("❌ КРИТИЧЕСКАЯ ОШИБКА: Context в NewPlaceViewController равен nil!")
                return
            }
        
        guard let context = context else {
            print("❌ Ошибка: Контекст не передан в NewPlaceViewController")
        return }
        
        let image = imageIsChanged ? placeImage.image : UIImage(named: "imagePlaceholder")

        let _ = Place(name: placeName.text ?? "",
                      location: placeLocation.text,
                      type: placeType.text,
                      image: image,
                      context: context)
        
        do {
                try context.save()
                print("✅ Успешно сохранено в Core Data")
            } catch {
                print("❌ Ошибка сохранения: \(error.localizedDescription)")
            }
        }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("➡️ Переход активирован! ID: \(segue.identifier ?? "nil")")
        
        guard let identifier = segue.identifier, identifier == "unwindSegue" else {
            print("⚠️ Переход проигнорирован (это не unwindSegue или Cancel)")
            return
        }
        print("LOG: Начинаю сохранение...")
        saveNewPlace()
    }
    
    
    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @objc private func textFieldChanged() {
        saveButton.isEnabled = !(placeName.text?.isEmpty ?? true)
    }
    
}


    // MARK: - Text field delegate
    
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
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            placeImage.image = info[.editedImage] as? UIImage
            placeImage.contentMode = .scaleAspectFill
            placeImage.clipsToBounds = true
            
            imageIsChanged = true
            dismiss(animated: true)
        
    }
}
