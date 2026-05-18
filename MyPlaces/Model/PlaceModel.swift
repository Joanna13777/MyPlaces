

import CoreData
import UIKit

@objc(Place)
public class Place: NSManagedObject {

    
    @NSManaged public var name: String?
    @NSManaged public var location: String?
    @NSManaged public var type: String?
    @NSManaged public var imageData: Data?
    @NSManaged public var date: Date?
    @objc dynamic var rating = 0.0

    
    static let restaurantNames = [
            "Burger Heroes", "Kitchen", "Bonsai", "Дастархан",
            "Индокитай", "Х.О.X", "Балкан Гриль", "Sherlock Holmes",
            "Speak Easy", "Morris Pub", "Вкусные истории",
            "Классик", "Love&Life", "Шок", "Бочка"
        ]

    // Cобственный инициализатор
    convenience init(name: String, location: String?, type: String?, image: UIImage?, context: NSManagedObjectContext, rating: Double) {
            let entity = NSEntityDescription.entity(forEntityName: "Place", in: context)!
            self.init(entity: entity, insertInto: context)
        
        self.name = name
        self.location = location
        self.type = type
        self.imageData = image?.pngData()
        self.date = Date()
        self.rating = Double(Int(rating))
    }
 
}

extension Place {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Place> {
        return NSFetchRequest<Place>(entityName: "Place")
    }
}

