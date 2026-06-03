
import UIKit
import MapKit
import CoreLocation



class MapViewController: UIViewController {

    var place = Place()
    
        var placeName: String?
        var placeLocation: String?
        var placeType: String?
        var placeImageData: Data?
    
    // Объявляем locationManager как свойство класса
    let locationManager = CLLocationManager()
    let annotationIdentifier = "annotationIdentifier"
    let regionInMeters = 1_000.00
    var incomeSequeIdentifier = ""
  
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var mapPinImage: UIImageView!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var doneButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addressLabel.text = "" // Присваием Label, про открытии карты, пустую строку
        mapView.delegate = self // делегат для протокола аннотации MapViewController
        setupMapView()
        checkLocationServices()  // Вызываем настройку менеджера
    }
    
    @IBAction func centerViewInUserLocation() {
     showUserLocation()
    }
    
    @IBAction func doneButtonPressed() {
    }
    
    @IBAction func closeCV() {
        dismiss(animated: true)
    }
    
    // Настройка карты в зависимости от значения свойства incomeSequeIdentifier
    private func setupMapView() {
        
        if incomeSequeIdentifier == "showPlace" {
            setupPlaceMark()
            mapPinImage.isHidden = true
            addressLabel.isHidden = true
            doneButton.isHidden = true
        }
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
            // позволяет отложить вызов Alert на определенное время - сейчас +1 сек
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(title: "Your Location is not Availeble",
                               message: "To give permission Go to: Setting -> MyPlaces -> Location")
            }
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
            if incomeSequeIdentifier == "getAdress" { showUserLocation() }
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
    
    private func showUserLocation() {
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
    
    // Определение адреса под маркером
    private func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        
        let latitude = mapView.centerCoordinate.latitude //координаты ширины
        let longitude = mapView.centerCoordinate.longitude //координаты долготы
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    private func showAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        
        alert.addAction(okAction)
        present(alert, animated: true)
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
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        let center = getCenterLocation(for: mapView)
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(center) { (placemarks, error) in
            
            if let error = error {
                print(error)
                return
            }
             
            // Получаем адрес
            // извлекаем метку
            guard let placemarks = placemarks else { return }
            // извлекаем улицу и номер дома
            let placemark = placemarks.first
            let streetName = placemark?.thoroughfare
            let buildNumber = placemark?.subThoroughfare
            
            // передаем текущее значение в Label
            DispatchQueue.main.async {
                
                if streetName != nil && buildNumber != nil {
                    self.addressLabel.text = "\(streetName!), \(buildNumber!)"
                } else if streetName != nil {
                    self.addressLabel.text = "\(streetName!)"
                } else {
                    self.addressLabel.text = ""
                }
            }
        }
    }
}
extension MapViewController: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
}
