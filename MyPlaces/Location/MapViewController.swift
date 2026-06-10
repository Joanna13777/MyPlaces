
import UIKit
import MapKit
import CoreLocation

protocol MapViewControllerDelegate {
    func getAddress(_ address: String?)
}

class MapViewController: UIViewController {
    
    let mapManager = MapManager()
    var mapViewControllerDelegate: MapViewControllerDelegate? // делегат класса MapVC
    var place = Place()
    
    let annotationIdentifier = "annotationIdentifier" // Объявляем locationManager как свойство класса
    var incomeSegueIdentifier = ""
    
    var previousLocation: CLLocation? { // хранение предидущее местоположение пользователя
        didSet {
            mapManager.startTrackingUserLocation(
                           for: mapView,
                           and: previousLocation) { (currentLocation) in
                               
                               self.previousLocation = currentLocation
                               
                               DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                   self.mapManager.showUserLocation(mapView: self.mapView)
                    }
                }
        }
    }
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var mapPinImage: UIImageView!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var doneButton: UIButton!
    @IBOutlet var goButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addressLabel.text = "" // Присваием Label, про открытии карты, пустую строку
        mapView.delegate = self // делегат для протокола аннотации MapViewController
        setupMapView()
    }
    
    @IBAction func centerViewInUserLocation() {
        mapManager.showUserLocation(mapView: mapView)
    }
    
    @IBAction func doneButtonPressed() {
        mapViewControllerDelegate?.getAddress(addressLabel.text)
        dismiss(animated: true)
    }
    
    @IBAction func goButtonPressed() {
        mapManager.getDirections(for: mapView) { (location) in
                    self.previousLocation = location
        }
    }
    
    @IBAction func closeCV() {
        dismiss(animated: true)
    }
    
    // Настройка карты в зависимости от значения свойства incomeSequeIdentifier
    private func setupMapView() {
        
        goButton.isHidden = true
        
        mapManager.checkLocationServices(mapView: mapView, segueIdentifier: incomeSegueIdentifier) {
            mapManager.locationManager.delegate = self
        }
        
        if incomeSegueIdentifier == "showPlace" {
            mapManager.setupPlaceMark(place: place, mapView: mapView)
            mapPinImage.isHidden = true
            addressLabel.isHidden = true
            doneButton.isHidden = true
            goButton.isHidden = false
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
        
       
        if let imageData = place.imageData {  // проверяем опциональное значение на nil
            
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
        
        let center = mapManager.getCenterLocation(for: mapView)
        let geocoder = CLGeocoder()
        
        if incomeSegueIdentifier == "showPlace" && previousLocation != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.mapManager.showUserLocation(mapView: self.mapView)
            }
        }
        
        geocoder.cancelGeocode()
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
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .blue
        
        return renderer
    }
}
extension MapViewController: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager,
                                               didChanngeAutorization status: CLAuthorizationStatus) {
        mapManager.checkLocationAuthorization(mapView: mapView,
                                                     segueIdentifier: incomeSegueIdentifier)
    }
}
