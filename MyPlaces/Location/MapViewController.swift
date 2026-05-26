//
//  MapViewController.swift
//  MyPlaces
//
//  Created by Жанна Сергеевна  on 22/05/26.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    var place: Place!
    
    @IBOutlet var mapView: MKMapView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlaceMark()
    }
    
    @IBAction func closeCV() {
        dismiss(animated: true)
    }
    
    // MARK: местоположение на карте
    private func setupPlaceMark() {
        
        // адрес
        guard let location = place.location else { return }
        
        //  отвечает за геогр. координаты и геогр. названия по адресу
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) { (placemarks, error) in
            
            // выдает ошибку, если метки не представлены
            if let error = error {
                print(error)
                return
            }
            
            //  если ошибки нет извлекаем орционал
            guard let placemarks = placemarks else { return }
            
            // массив должен содержать 1 метку
            let placemark = placemarks.first
            
            let annotation = MKPointAnnotation()
            annotation.title = self.place.name // описывает точку объекта на карте-заголовок
            annotation.subtitle = self.place.type // описывает точку объекта на карте - подзаголовок объекта
            
            // свойство определяет местоположение маркера
            guard let placemarkLocation = placemark?.location else { return }
                    annotation.coordinate = placemarkLocation.coordinate
                    
                    // видимая область для аннотации
                    self.mapView.showAnnotations([annotation], animated: true)
                    self.mapView.selectAnnotation(annotation, animated: true) // выделяем созданную аннотацию
        }
    }

}
