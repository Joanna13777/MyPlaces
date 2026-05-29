
import UIKit
import MapKit
import CoreLocation



class MapViewController: UIViewController {

    var place = Place()
    
        var placeName: String?
        var placeLocation: String?
        var placeType: String?
        var placeImageData: Data?
    
    let annotationIdentifier = "annotationIdentifier"
    
    // Объявляем locationManager как свойство класса (исправляет ошибку scope
       let locationManager = CLLocationManager()
    
    @IBOutlet var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // делегат для протокола аннотации MapViewController
        mapView.delegate = self
        setupPlaceMark()
        
        // Вызываем настройку менеджера
        setupLocationManager()
              checkLocationAuthorization()
        checkLocationServices()
    }
    
    @IBAction func closeCV() {
        dismiss(animated: true)
    }
    
    // MARK: местоположение на карте
    private func setupPlaceMark() {
        
        // адрес
        guard let location = placeLocation else { return }
        
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
            annotation.title = self.placeName // описывает точку объекта на карте-заголовок
            annotation.subtitle = self.placeType // описывает точку объекта на карте - подзаголовок объекта
            
            // свойство определяет местоположение маркера
            guard let placemarkLocation = placemark?.location else { return }
            
            annotation.coordinate = placemarkLocation.coordinate
                    
            // видимая область для аннотации
            self.mapView.showAnnotations([annotation], animated: true)
            self.mapView.selectAnnotation(annotation, animated: true) // выделяем созданную аннотацию
        }
    }

    private func checkLocationServices() {
        
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            // Показать алерт
        }
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    private func checkLocationAuthorization() {
        let status = locationManager.authorizationStatus
        
        switch status {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
        case .denied:
            // Показать алерт
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
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // если маркером на карте является текущее положение пользователя, аннотация не создается
        guard !(annotation is MKUserLocation) else { return nil }
        
       // объект класса
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? MKMarkerAnnotationView
        
        // если на карте нет аннотации, по инициализатору присваиваем новое значение класса MKAnnotationView
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView?.canShowCallout = true // отображает аннотацию в виде банера
        }
        
        // Отображает изображение заведения в банере Map. Проверяем новые переданные данные изображения placeImageData
        
       
        if let imageData = placeImageData {  // проверяем опциональное значение на nil
            
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            // внешний вид изображения
            imageView.layer.cornerRadius = 10
            imageView.clipsToBounds = true
            // поместим изображение в imageView
            imageView.image = UIImage(data: imageData)
            annotationView?.rightCalloutAccessoryView = imageView
        }
        
        // возрщаем объект
        return annotationView
    }
}
extension MapViewController: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
}
