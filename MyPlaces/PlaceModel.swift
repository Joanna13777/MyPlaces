//
//  PlaceModel.swift
//  MyPlaces
//
//  Created by Жанна Сергеевна  on 14/03/26.
//

import Foundation

struct Place {
    
    var name: String
    var location: String
    var type: String
    var image: String
    
    
    static let restaurantNames = [
        "Burger Heroes", "Kitchen", "Bonsai", "Дастархан", "Индокитай", "Х.О", "Балкан Гриль",
        "Sherlock Holmes", "Speak Easy", "Morris Pub", "Вкусные истории", "Классик", "Love&Life",
        "Шок", "Бочка"
    ]
    
    static func getPlaces() -> [Place] {
        
        var places = [Place]()
        
        for place in restaurantNames {
            places.append(Place(name: place, location: "Ташкент", type: "Ресторан", image: place))
        }
        
        return places
    }
}
