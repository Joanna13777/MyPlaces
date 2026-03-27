//
//  Town+CoreDataProperties.swift
//  MyPlaces
//
//  Created by Жанна Сергеевна  on 27/03/26.
//
//

import Foundation
import CoreData


extension Town {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Town> {
        return NSFetchRequest<Town>(entityName: "Town")
    }

    @NSManaged public var name: String?
    @NSManaged public var type: String?
    @NSManaged public var location: String?
    @NSManaged public var image: Data?

}

extension Town : Identifiable {

}
