//
//  MapManager.swift
//  MyPlaces
//
//  Created by Жанна Сергеевна  on 09/06/26.
//

import UIKit
import MapKit

class MapManager {
    
    let locationManager = CLLocationManager()
    
    private var placeCoordinate: CLLocationCoordinate2D?
    private var directionsArray: [MKDirections] = []
    private let regionInMeters = 1_000.00
    
    
    
    // MARK: - Маркер заведения
    func setupPlaceMark(place: Place, mapView: MKMapView) {
        
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
            annotation.title = place.name // описывает точку объекта на карте-заголовок
            annotation.subtitle = place.type // описывает точку объекта на карте - подзаголовок объекта
            
            // свойство определяет местоположение маркера
            guard let placemarkLocation = placemark?.location else { return }
            
            annotation.coordinate = placemarkLocation.coordinate
            self.placeCoordinate = placemarkLocation.coordinate // координаты заведения
            
            // видимая область для аннотации
            mapView.showAnnotations([annotation], animated: true)
            mapView.selectAnnotation(annotation, animated: true) // выделяем созданную аннотацию
        }
    }
    
    
    // MARK: - Проверка доступности сервисов геолокации
    func checkLocationServices(mapView: MKMapView, segueIdentifier: String, closure: () -> ()) {
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            checkLocationAuthorization(mapView: mapView, segueIdentifier: segueIdentifier)
            closure()
        } else {
            // позволяет отложить вызов Alert на определенное время - сейчас +1 сек
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(title: "Your Location is not Availeble",
                               message: "To give permission Go to: Setting -> MyPlaces -> Location")
            }
        }
    }
    
    // MARK:  Проверка авторизации приложения для использования сервисов геолокации
    func checkLocationAuthorization(mapView: MKMapView, segueIdentifier: String) {
        let status = locationManager.authorizationStatus
        
        switch status {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            if segueIdentifier == "getAddress" { showUserLocation(mapView: mapView) }
            break
        case .denied:
            // позволяет отложить вызов Alert на определенное время - сейчас +1 сек
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(title: "Your Location is not Availeble",
                               message: "To give permission Go to: Setting -> MyPlaces -> Location")
            }
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            break
        case .authorizedAlways:
            break
        @unknown default:
            print("New case is available")
        }
    }
    
    // MARK: Фокус карты местоположения пользователя
    func showUserLocation(mapView: MKMapView) {
        // проверяем координаты пользователя
        if let location = locationManager.location?.coordinate {
            // если координаты пользователя определены, определяем регион для позиционирования карты
            let region = MKCoordinateRegion(center: location,
                                            latitudinalMeters: regionInMeters,
                                            longitudinalMeters: regionInMeters)
            //  регион для отображения на экране
            mapView.setRegion(region, animated: true)
        }
    }
    
    // MARK: Маршрут от местоположения пользователя до заведения
    func getDirections(for mapView: MKMapView, previousLocation: (CLLocation) -> ()) {
        
        guard let location = locationManager.location?.coordinate else {
            showAlert(title: "Error", message: "Currrent location is not found")
            return
        }
        
        locationManager.startUpdatingLocation() // режим постоянного отслеживания текущего местополодения пользователя
        previousLocation(CLLocation(latitude: location.latitude, longitude: location.longitude))
        
        guard let request = createDirectionsRequest(from: location) else {
            showAlert(title: "Error", message: "Destination is not found")
            return
        }
        
        let directions = MKDirections(request: request)
        resetMapView(withNew: directions, mapView: mapView)
        
        directions.calculate { (responce, error) in
            if let error = error {
                print(error)
                return
            }
            guard let response = responce else {
                self.showAlert(title: "Error", message: "Directions is not available")
                return
            }
            for route in response.routes {
                mapView.addOverlay(route.polyline)
                mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                
                let distance = String(format: "%.1f", route.distance / 1000)
                let timeInterval = route.expectedTravelTime
                
                print("Расстояние до места: \(distance) .")
                print("Расстояние в пути составит: \(timeInterval) .")
            }
        }
    }
    
    
    // Настройка запроса для расчета маршрута
    private func createDirectionsRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
        
        guard let destinationCoordinate = placeCoordinate else { return nil }
        let startingLocation = MKPlacemark(coordinate: coordinate) // точка для начала маршрута
        let destination = MKPlacemark(coordinate: destinationCoordinate)// точка места назначения
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .automobile
        request.requestsAlternateRoutes = true
        return request
    }
    
    // Меняем отображаемую зону области карты в соответсвии с перемещением пользователя
    func startTrackingUserLocation(for mapView: MKMapView, and location: CLLocation?, closure: (_ currentLocation: CLLocation) -> ()) {
        
        guard let location = location else { return }
        let center = getCenterLocation(for: mapView)
        guard center.distance(from: location) > 50 else { return }
        
        closure(center)
    }
    
    // Сброс всех ранее постоенных маршрутов перед построением нового
    // метод удаляет старый маршрут перед тем, как постоить новый
    func resetMapView(withNew directions: MKDirections, mapView: MKMapView) {
            
            mapView.removeOverlays(mapView.overlays)
            directionsArray.append(directions)
            let _ = directionsArray.map { $0.cancel() }
            directionsArray.removeAll()
        }
    
    // Определение центра отображаемой области карты
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        
        let latitude = mapView.centerCoordinate.latitude //координаты ширины
        let longitude = mapView.centerCoordinate.longitude //координаты долготы
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    private func showAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        
        alert.addAction(okAction)
        
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindow.Level.alert + 1
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alert, animated: true)
    }

}
